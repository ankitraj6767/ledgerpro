import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'rich_text_document.dart';

/// Renders rich text (the Markdown subset / Delta JSON understood by
/// [parseRichText]) as read-only Flutter widgets. Used to display
/// notes/descriptions in detail views and lists.
///
/// Hardened so it can never crash the screen:
///  * no null-assertions on text metrics,
///  * link [TapGestureRecognizer]s are disposed *after* the frame (never
///    during build, which is a documented cause of "used after dispose"
///    crashes), and
///  * any unexpected error falls back to plain text.
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
  /// Recognizers created during the current build.
  List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers = [];
    super.dispose();
  }

  Future<void> _openLink(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return;
    final normalized = uri.hasScheme ? uri : Uri.parse('https://$trimmed');
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
    try {
      return _buildContent(context);
    } catch (_) {
      // Never let a rendering edge-case crash the surrounding screen.
      return Text(
        _plainFallback(),
        style: widget.baseStyle,
      );
    }
  }

  String _plainFallback() {
    try {
      return richTextToPlain(widget.data);
    } catch (_) {
      return widget.data ?? '';
    }
  }

  Widget _buildContent(BuildContext context) {
    // Retire the previous frame's recognizers *after* this frame commits, so a
    // recognizer that is still referenced by the current render tree / gesture
    // arena is never disposed while in use.
    final previous = _recognizers;
    _recognizers = <TapGestureRecognizer>[];
    if (previous.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final r in previous) {
          r.dispose();
        }
      });
    }

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
      children.add(_buildBlock(blocks[i], base));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildBlock(RtBlock block, TextStyle base) {
    // Never assert on fontSize; fall back to a sensible default.
    final baseSize = base.fontSize ?? 14.0;
    switch (block.type) {
      case RtBlockType.h1:
        return _paragraph(
          block,
          base.copyWith(fontSize: baseSize + 8, fontWeight: FontWeight.w900),
        );
      case RtBlockType.h2:
        return _paragraph(
          block,
          base.copyWith(fontSize: baseSize + 5, fontWeight: FontWeight.w800),
        );
      case RtBlockType.h3:
        return _paragraph(
          block,
          base.copyWith(fontSize: baseSize + 2, fontWeight: FontWeight.w800),
        );
      case RtBlockType.bullet:
        return _listItem(block, base, marker: '•  ');
      case RtBlockType.ordered:
        return _listItem(block, base, marker: '${block.orderedNumber ?? 1}.  ');
      case RtBlockType.quote:
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: base.color?.withValues(alpha: 0.35) ?? Colors.grey,
                width: 3,
              ),
            ),
          ),
          child: _paragraph(
            block,
            base.copyWith(
              fontStyle: FontStyle.italic,
              color: base.color?.withValues(alpha: 0.85),
            ),
          ),
        );
      case RtBlockType.paragraph:
        return _paragraph(block, base);
    }
  }

  Widget _paragraph(RtBlock block, TextStyle style) {
    return RichText(text: TextSpan(children: _spans(block.spans, style)));
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
      final link = span.link;
      if (link != null) {
        style = style.copyWith(
          color: const Color(0xFF1D74F5),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF1D74F5),
        );
        final recognizer = TapGestureRecognizer()..onTap = () => _openLink(link);
        _recognizers.add(recognizer);
        return TextSpan(text: span.text, style: style, recognizer: recognizer);
      }
      return TextSpan(text: span.text, style: style);
    }).toList();
  }
}
