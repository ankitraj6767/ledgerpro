import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'rich_text_document.dart';

/// Renders rich text (the Markdown subset in [parseRichText]) as Flutter
/// widgets. Read-only; used to display notes/descriptions in detail views.
///
/// It manages [TapGestureRecognizer]s for links and disposes them properly, so
/// it is safe to embed anywhere.
class RichTextView extends StatefulWidget {
  const RichTextView(
    this.data, {
    super.key,
    this.baseStyle,
    this.blockSpacing = 8,
  });

  final String? data;

  /// Base text style for paragraphs/list items. Headings scale from this.
  final TextStyle? baseStyle;

  /// Vertical space between blocks.
  final double blockSpacing;

  @override
  State<RichTextView> createState() => _RichTextViewState();
}

class _RichTextViewState extends State<RichTextView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    final normalized = uri.hasScheme ? uri : Uri.parse('https://$url');
    try {
      if (await canLaunchUrl(normalized)) {
        await launchUrl(normalized, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Best effort: a malformed URL simply does nothing.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recognizers are rebuilt on every build; clear the previous batch first.
    _disposeRecognizers();

    final blocks = parseRichText(widget.data);
    if (blocks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final base =
        widget.baseStyle ??
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);

    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) children.add(SizedBox(height: widget.blockSpacing));
      children.add(_buildBlock(context, blocks[i], base));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildBlock(BuildContext context, RtBlock block, TextStyle base) {
    switch (block.type) {
      case RtBlockType.h1:
        return _paragraph(block, base.copyWith(fontSize: base.fontSize! + 8, fontWeight: FontWeight.w900));
      case RtBlockType.h2:
        return _paragraph(block, base.copyWith(fontSize: base.fontSize! + 5, fontWeight: FontWeight.w800));
      case RtBlockType.h3:
        return _paragraph(block, base.copyWith(fontSize: base.fontSize! + 2, fontWeight: FontWeight.w800));
      case RtBlockType.bullet:
        return _listItem(block, base, marker: '•  ');
      case RtBlockType.ordered:
        return _listItem(block, base, marker: '${block.orderedNumber ?? 1}.  ');
      case RtBlockType.quote:
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: base.color?.withValues(alpha: 0.35) ?? Colors.grey, width: 3),
            ),
          ),
          child: _paragraph(
            block,
            base.copyWith(fontStyle: FontStyle.italic, color: base.color?.withValues(alpha: 0.85)),
          ),
        );
      case RtBlockType.paragraph:
        return _paragraph(block, base);
    }
  }

  Widget _paragraph(RtBlock block, TextStyle style) {
    return RichText(
      text: TextSpan(children: _spans(block.spans, style)),
    );
  }

  Widget _listItem(RtBlock block, TextStyle base, {required String marker}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(marker, style: base.copyWith(fontWeight: FontWeight.w700)),
        Expanded(
          child: RichText(text: TextSpan(children: _spans(block.spans, base))),
        ),
      ],
    );
  }

  List<InlineSpan> _spans(List<RtSpan> spans, TextStyle base) {
    return spans.map((span) {
      var style = base;
      if (span.bold) style = style.copyWith(fontWeight: FontWeight.w800);
      if (span.italic) style = style.copyWith(fontStyle: FontStyle.italic);
      if (span.code) {
        style = style.copyWith(
          fontFamily: 'monospace',
          backgroundColor: (base.color ?? Colors.black).withValues(alpha: 0.06),
        );
      }
      if (span.link != null) {
        style = style.copyWith(
          color: const Color(0xFF1D74F5),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF1D74F5),
        );
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _openLink(span.link!);
        _recognizers.add(recognizer);
        return TextSpan(text: span.text, style: style, recognizer: recognizer);
      }
      return TextSpan(text: span.text, style: style);
    }).toList();
  }
}
