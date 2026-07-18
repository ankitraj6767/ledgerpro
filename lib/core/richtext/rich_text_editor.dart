import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'rich_text_document.dart';

/// A true WYSIWYG rich-text ("notes"/"description") editor.
///
/// Formatting is applied live (clicking **Bold** makes the selected text bold,
/// pressing Enter inside a numbered list continues it, etc.) using the
/// Fleather editor. The document is persisted as a Parchment/Quill **Delta
/// JSON** string written into the supplied [controller] — so callers keep
/// reading `controller.text` exactly as before and the form/repository save
/// path is unchanged. The shared [parseRichText] renderer understands this
/// Delta JSON (and still renders legacy plain-text/markdown), so the same
/// content displays identically in-app and in generated PDFs.
class RichTextEditorField extends StatefulWidget {
  const RichTextEditorField({
    super.key,
    required this.controller,
    this.label,
    this.hintText = 'Write here…',
    this.icon,
    this.minLines = 4,
  });

  /// Plain [TextEditingController] whose `.text` holds the stored value
  /// (Delta JSON, or legacy plain text / markdown when first opened).
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final IconData? icon;
  final int minLines;

  @override
  State<RichTextEditorField> createState() => _RichTextEditorFieldState();
}

class _RichTextEditorFieldState extends State<RichTextEditorField> {
  late final FleatherController _fleather;
  final FocusNode _focusNode = FocusNode();
  String _lastEncoded = '';

  @override
  void initState() {
    super.initState();
    _fleather = FleatherController(
      document: _documentFromStored(widget.controller.text),
    );
    _lastEncoded = widget.controller.text;
    _fleather.addListener(_syncToController);
  }

  @override
  void dispose() {
    _fleather.removeListener(_syncToController);
    _fleather.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Mirrors the Fleather document back into the plain controller as Delta JSON
  /// (or an empty string when the document has no text), so existing save
  /// logic keeps working untouched.
  void _syncToController() {
    final document = _fleather.document;
    final plain = document.toPlainText().trim();
    final encoded = plain.isEmpty ? '' : jsonEncode(document.toJson());
    if (encoded == _lastEncoded) return;
    _lastEncoded = encoded;
    widget.controller.value = TextEditingValue(
      text: encoded,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  /// Builds a Parchment document from the stored value:
  /// - valid Delta JSON  -> parsed as-is
  /// - anything else      -> treated as plain text (legacy notes/descriptions)
  ParchmentDocument _documentFromStored(String stored) {
    if (stored.trim().isEmpty) return ParchmentDocument();
    final trimmed = stored.trimLeft();
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is List &&
            decoded.isNotEmpty &&
            decoded.every((e) => e is Map && e.containsKey('insert'))) {
          return ParchmentDocument.fromJson(
            decoded.cast<Map<String, dynamic>>(),
          );
        }
      } catch (_) {
        // Fall through to plain-text handling.
      }
    }
    return _documentFromPlainText(stored);
  }

  ParchmentDocument _documentFromPlainText(String text) {
    final normalized = text.endsWith('\n') ? text : '$text\n';
    try {
      return ParchmentDocument.fromJson([
        {'insert': normalized},
      ]);
    } catch (_) {
      return ParchmentDocument();
    }
  }

  Future<void> _openLink(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) return;
    final uri = parsed.hasScheme ? parsed : Uri.parse('https://${url.trim()}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Best effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: theme.hintColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        FleatherField(
          controller: _fleather,
          focusNode: _focusNode,
          minHeight: widget.minLines * 24.0,
          maxHeight: 360,
          padding: const EdgeInsets.all(12),
          onLaunchUrl: _openLink,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          toolbar: FleatherToolbar.basic(
            controller: _fleather,
            // Keep a focused, "basic HTML"-style toolbar; hide the advanced
            // buttons that don't apply to simple notes.
            hideBackgroundColor: true,
            hideForegroundColor: true,
            hideListChecks: true,
            hideCodeBlock: true,
            hideHorizontalRule: true,
            hideDirection: true,
            hideAlignment: true,
          ),
        ),
      ],
    );
  }
}
