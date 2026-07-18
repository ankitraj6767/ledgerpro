import 'package:flutter/material.dart';

import 'rich_text_document.dart';
import 'rich_text_view.dart';

/// A rich-text ("notes"/"description") editor with a formatting toolbar.
///
/// It edits Markdown text in the supplied [controller] (so callers keep reading
/// `controller.text` exactly as before — the value is just Markdown now). The
/// toolbar applies the same subset understood by [parseRichText]/[RichTextView]
/// and the PDF renderer, so what the user formats here shows identically in the
/// app and in generated reports.
class RichTextEditorField extends StatefulWidget {
  const RichTextEditorField({
    super.key,
    required this.controller,
    this.label,
    this.hintText = 'Write here…',
    this.icon,
    this.minLines = 4,
  });

  final TextEditingController controller;
  final String? label;
  final String hintText;
  final IconData? icon;
  final int minLines;

  @override
  State<RichTextEditorField> createState() => _RichTextEditorFieldState();
}

class _RichTextEditorFieldState extends State<RichTextEditorField> {
  final FocusNode _focusNode = FocusNode();
  bool _preview = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  TextEditingController get _c => widget.controller;

  // --- Formatting actions ---------------------------------------------------

  void _wrap(String left, String right) {
    final text = _c.text;
    final sel = _c.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = (sel.isValid && !sel.isCollapsed)
        ? text.substring(start, end)
        : '';
    final replacement = '$left$selected$right';
    final newText = text.replaceRange(start, end, replacement);
    final cursor = selected.isEmpty
        ? start + left.length
        : start + replacement.length;
    _apply(newText, cursor);
  }

  void _toggleLinePrefix(String prefix) {
    final text = _c.text;
    final sel = _c.selection;
    final caret = sel.isValid ? sel.start : text.length;
    final lineStart = caret <= 0 ? 0 : text.lastIndexOf('\n', caret - 1) + 1;
    var lineEnd = text.indexOf('\n', caret);
    if (lineEnd == -1) lineEnd = text.length;
    final line = text.substring(lineStart, lineEnd);
    final stripped = line.replaceFirst(_blockPrefix, '');
    final hadSame = prefix.isNotEmpty && line.startsWith(prefix);
    final newLine = hadSame ? stripped : '$prefix$stripped';
    final newText = text.replaceRange(lineStart, lineEnd, newLine);
    final delta = newLine.length - line.length;
    final newOffset = (caret + delta).clamp(lineStart, lineStart + newLine.length);
    _apply(newText, newOffset);
  }

  Future<void> _insertLink() async {
    final text = _c.text;
    final sel = _c.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = (sel.isValid && !sel.isCollapsed)
        ? text.substring(start, end)
        : '';

    final result = await showDialog<_LinkResult>(
      context: context,
      builder: (_) => _LinkDialog(initialText: selected),
    );
    if (result == null) return;
    final label = result.text.trim().isEmpty ? result.url.trim() : result.text.trim();
    final md = '[$label](${result.url.trim()})';
    final newText = text.replaceRange(start, end, md);
    _apply(newText, start + md.length);
  }

  void _clearFormatting() {
    final text = _c.text;
    final sel = _c.selection;
    if (sel.isValid && !sel.isCollapsed) {
      final selected = text.substring(sel.start, sel.end);
      final plain = richTextToPlain(selected, joiner: '\n');
      final newText = text.replaceRange(sel.start, sel.end, plain);
      _apply(newText, sel.start + plain.length);
    } else {
      final plain = richTextToPlain(text, joiner: '\n');
      _apply(plain, plain.length);
    }
  }

  void _apply(String newText, int cursor) {
    final offset = cursor.clamp(0, newText.length);
    _c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
    // Keep the field focused so the user can keep typing after formatting.
    _focusNode.requestFocus();
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.dividerColor.withValues(alpha: 0.6);
    final toolbarBg = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.4,
    );

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
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toolbar
              Container(
                decoration: BoxDecoration(
                  color: toolbarBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      _ToolButton(
                        tooltip: 'Normal text',
                        icon: Icons.notes_rounded,
                        onTap: () => _toggleLinePrefix(''),
                      ),
                      _ToolLabel(label: 'H2', tooltip: 'Heading', onTap: () => _toggleLinePrefix('## ')),
                      _ToolLabel(label: 'H3', tooltip: 'Subheading', onTap: () => _toggleLinePrefix('### ')),
                      _divider(border),
                      _ToolButton(tooltip: 'Bold', icon: Icons.format_bold_rounded, onTap: () => _wrap('**', '**')),
                      _ToolButton(tooltip: 'Italic', icon: Icons.format_italic_rounded, onTap: () => _wrap('*', '*')),
                      _ToolButton(tooltip: 'Highlight', icon: Icons.code_rounded, onTap: () => _wrap('`', '`')),
                      _divider(border),
                      _ToolButton(tooltip: 'Bulleted list', icon: Icons.format_list_bulleted_rounded, onTap: () => _toggleLinePrefix('- ')),
                      _ToolButton(tooltip: 'Numbered list', icon: Icons.format_list_numbered_rounded, onTap: () => _toggleLinePrefix('1. ')),
                      _ToolButton(tooltip: 'Quote', icon: Icons.format_quote_rounded, onTap: () => _toggleLinePrefix('> ')),
                      _divider(border),
                      _ToolButton(tooltip: 'Link', icon: Icons.link_rounded, onTap: _insertLink),
                      _ToolButton(tooltip: 'Clear formatting', icon: Icons.format_clear_rounded, onTap: _clearFormatting),
                      _divider(border),
                      _ToolButton(
                        tooltip: _preview ? 'Edit' : 'Preview',
                        icon: _preview ? Icons.edit_rounded : Icons.visibility_rounded,
                        highlighted: _preview,
                        onTap: () => setState(() => _preview = !_preview),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: border),
              // Body: editor or live preview
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: _preview
                    ? _previewBody(theme)
                    : TextField(
                        controller: _c,
                        focusNode: _focusNode,
                        minLines: widget.minLines,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: widget.hintText,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewBody(ThemeData theme) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        if (richTextIsEmpty(_c.text)) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minLines * 20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Nothing to preview yet.',
                style: TextStyle(color: theme.hintColor),
              ),
            ),
          );
        }
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.minLines * 20.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: RichTextView(_c.text),
          ),
        );
      },
    );
  }

  Widget _divider(Color color) => Container(
        width: 1,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        color: color,
      );

  static final RegExp _blockPrefix =
      RegExp(r'^(#{1,3}\s+|>\s+|[-*]\s+|\d+[.)]\s+)');
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      iconSize: 20,
      color: highlighted ? theme.colorScheme.primary : theme.iconTheme.color,
      icon: Icon(icon),
    );
  }
}

class _ToolLabel extends StatelessWidget {
  const _ToolLabel({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkResult {
  const _LinkResult(this.text, this.url);
  final String text;
  final String url;
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({required this.initialText});
  final String initialText;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialText,
  );
  final TextEditingController _url = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _text,
            decoration: const InputDecoration(labelText: 'Text to show'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _url,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_url.text.trim().isEmpty) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pop(_LinkResult(_text.text, _url.text));
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
