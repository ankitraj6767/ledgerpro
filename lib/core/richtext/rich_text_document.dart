/// A tiny, self-contained Markdown-subset parser used for rich "notes" and
/// "description" fields across the app.
///
/// It is intentionally dependency-free and pure Dart (no Flutter imports) so
/// the exact same parsed model can be rendered both to Flutter widgets
/// (in-app) and to `pdf` widgets (reports) — guaranteeing the formatting looks
/// identical in both places.
///
/// Supported syntax (a safe, common subset of Markdown / "basic HTML"):
///   # / ## / ###      headings
///   **bold**          bold
///   *italic* / _it_   italic
///   ***both***        bold + italic
///   `code`            inline highlight / monospace
///   - item  / * item  bullet list
///   1. item           numbered list
///   > quote           block quote
///   [text](url)       link
///
/// Legacy plain text (no markers) parses to plain paragraphs unchanged, so
/// existing saved notes/descriptions keep rendering exactly as before.
library;

import 'dart:convert';

enum RtBlockType { paragraph, h1, h2, h3, bullet, ordered, quote }

/// An inline run of text with formatting flags.
class RtSpan {
  const RtSpan(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool code;

  /// Non-null when this run is a hyperlink.
  final String? link;
}

/// A block-level element (paragraph, heading, list item, quote).
class RtBlock {
  const RtBlock(this.type, this.spans, {this.orderedNumber});

  final RtBlockType type;
  final List<RtSpan> spans;

  /// The number to render for an ordered-list item (1-based).
  final int? orderedNumber;

  bool get isHeading =>
      type == RtBlockType.h1 || type == RtBlockType.h2 || type == RtBlockType.h3;
}

/// Parses [source] into a list of [RtBlock]s. Never throws: malformed markup is
/// treated as literal text.
///
/// [source] may be either:
///  * a Parchment/Quill **Delta JSON** string (produced by the rich editor), or
///  * legacy plain text / a small Markdown subset.
///
/// Both are supported so existing saved notes/descriptions keep rendering, and
/// so the in-app view and the PDF renderer share a single code path.
List<RtBlock> parseRichText(String? source) {
  final text = source ?? '';
  if (text.trim().isEmpty) return const [];

  final deltaOps = _tryDeltaOps(text);
  if (deltaOps != null) {
    // Structurally a Delta document: a lone newline / whitespace-only doc has
    // no renderable content.
    final plain = deltaOps
        .map((e) => (e as Map)['insert'])
        .whereType<String>()
        .join();
    if (plain.trim().isEmpty) return const [];
    return _blocksFromDelta(deltaOps);
  }

  return _parseMarkdown(text);
}

/// Returns the Delta ops list when [text] is a structurally valid Delta JSON
/// document, otherwise null. A fast prefix check avoids JSON-decoding ordinary
/// notes.
List<dynamic>? _tryDeltaOps(String text) {
  final trimmed = text.trimLeft();
  if (!trimmed.startsWith('[')) return null;
  try {
    final decoded = jsonDecode(text);
    if (decoded is List &&
        decoded.isNotEmpty &&
        decoded.every((e) => e is Map && e.containsKey('insert'))) {
      return decoded;
    }
  } catch (_) {
    // Not JSON -> treat as markdown/plain text.
  }
  return null;
}

/// Converts a Parchment/Quill Delta ops list into [RtBlock]s.
List<RtBlock> _blocksFromDelta(List<dynamic> ops) {
  final blocks = <RtBlock>[];
  var pending = <RtSpan>[];
  var orderedRun = 0;

  for (final op in ops) {
    if (op is! Map) continue;
    final insert = op['insert'];
    if (insert is! String) continue; // skip embeds
    final attributes = op['attributes'];
    final inline = attributes is Map ? attributes : const {};

    final segments = insert.split('\n');
    for (var s = 0; s < segments.length; s++) {
      final segment = segments[s];
      if (segment.isNotEmpty) {
        pending.add(_deltaSpan(segment, inline));
      }
      final isLast = s == segments.length - 1;
      if (!isLast) {
        // The newline carries this line's block attributes.
        final type = _deltaLineType(inline);
        int? number;
        if (type == RtBlockType.ordered) {
          orderedRun += 1;
          number = orderedRun;
        } else {
          orderedRun = 0;
        }
        blocks.add(
          RtBlock(
            type,
            pending.isEmpty ? const [RtSpan('')] : pending,
            orderedNumber: number,
          ),
        );
        pending = <RtSpan>[];
      }
    }
  }

  if (pending.isNotEmpty) {
    blocks.add(RtBlock(RtBlockType.paragraph, pending));
  }
  return blocks;
}

RtSpan _deltaSpan(String text, Map inline) {
  final link = inline['a'];
  return RtSpan(
    text,
    bold: inline['b'] == true,
    italic: inline['i'] == true,
    code: inline['c'] == true,
    link: link is String ? link : null,
  );
}

RtBlockType _deltaLineType(Map attributes) {
  final heading = attributes['heading'];
  if (heading == 1) return RtBlockType.h1;
  if (heading == 2) return RtBlockType.h2;
  if (heading is int && heading >= 3) return RtBlockType.h3;

  final block = attributes['block'];
  if (block == 'ul' || block == 'cl') return RtBlockType.bullet;
  if (block == 'ol') return RtBlockType.ordered;
  if (block == 'quote') return RtBlockType.quote;
  return RtBlockType.paragraph;
}

/// Parses the legacy plain-text / Markdown-subset form.
List<RtBlock> _parseMarkdown(String text) {
  final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final blocks = <RtBlock>[];
  var orderedRun = 0; // running counter for consecutive ordered items

  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    final trimmed = line.trimLeft();

    if (trimmed.isEmpty) {
      // Blank line ends any ordered-list run and adds spacing between blocks.
      orderedRun = 0;
      continue;
    }

    if (trimmed.startsWith('### ')) {
      orderedRun = 0;
      blocks.add(RtBlock(RtBlockType.h3, _parseInline(trimmed.substring(4))));
    } else if (trimmed.startsWith('## ')) {
      orderedRun = 0;
      blocks.add(RtBlock(RtBlockType.h2, _parseInline(trimmed.substring(3))));
    } else if (trimmed.startsWith('# ')) {
      orderedRun = 0;
      blocks.add(RtBlock(RtBlockType.h1, _parseInline(trimmed.substring(2))));
    } else if (trimmed.startsWith('> ')) {
      orderedRun = 0;
      blocks.add(RtBlock(RtBlockType.quote, _parseInline(trimmed.substring(2))));
    } else if (trimmed == '>') {
      orderedRun = 0;
      blocks.add(const RtBlock(RtBlockType.quote, [RtSpan('')]));
    } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      orderedRun = 0;
      blocks.add(RtBlock(RtBlockType.bullet, _parseInline(trimmed.substring(2))));
    } else {
      final ordered = _orderedListPattern.firstMatch(trimmed);
      if (ordered != null) {
        orderedRun += 1;
        blocks.add(
          RtBlock(
            RtBlockType.ordered,
            _parseInline(trimmed.substring(ordered.end)),
            orderedNumber: orderedRun,
          ),
        );
      } else {
        orderedRun = 0;
        blocks.add(RtBlock(RtBlockType.paragraph, _parseInline(trimmed)));
      }
    }
  }

  return blocks;
}

/// Whether [source] has any renderable content.
bool richTextIsEmpty(String? source) => parseRichText(source).isEmpty;

/// Flattens rich text to a single-line (or joined) plain string, used where a
/// compact representation is needed (narrow PDF table cells, search, etc.).
String richTextToPlain(String? source, {String joiner = ' '}) {
  final blocks = parseRichText(source);
  if (blocks.isEmpty) return '';
  final parts = <String>[];
  for (final block in blocks) {
    final text = block.spans.map((s) => s.text).join();
    switch (block.type) {
      case RtBlockType.bullet:
        parts.add('• $text');
        break;
      case RtBlockType.ordered:
        parts.add('${block.orderedNumber ?? 1}. $text');
        break;
      default:
        parts.add(text);
    }
  }
  return parts.join(joiner).trim();
}

final RegExp _orderedListPattern = RegExp(r'^\d+[.)]\s+');

/// Parses inline formatting within a single logical line.
List<RtSpan> _parseInline(String input) {
  if (input.isEmpty) return const [RtSpan('')];
  final spans = <RtSpan>[];
  final buffer = StringBuffer();
  var i = 0;

  void flushPlain() {
    if (buffer.isNotEmpty) {
      spans.add(RtSpan(buffer.toString()));
      buffer.clear();
    }
  }

  while (i < input.length) {
    final rest = input.substring(i);

    // Link: [text](url)
    final link = _linkPattern.matchAsPrefix(rest);
    if (link != null) {
      flushPlain();
      final label = link.group(1) ?? '';
      final url = link.group(2) ?? '';
      // The label itself may contain bold/italic; render its inline runs but
      // carry the link across all of them.
      for (final inner in _parseInline(label)) {
        spans.add(
          RtSpan(
            inner.text,
            bold: inner.bold,
            italic: inner.italic,
            code: inner.code,
            link: url,
          ),
        );
      }
      i += link.group(0)!.length;
      continue;
    }

    // Bold + italic: ***text***
    final bi = _wrap(rest, '***');
    if (bi != null) {
      flushPlain();
      spans.add(RtSpan(bi, bold: true, italic: true));
      i += bi.length + 6;
      continue;
    }

    // Bold: **text**
    final bold = _wrap(rest, '**');
    if (bold != null) {
      flushPlain();
      spans.add(RtSpan(bold, bold: true));
      i += bold.length + 4;
      continue;
    }

    // Italic: *text*
    final italicStar = _wrap(rest, '*');
    if (italicStar != null) {
      flushPlain();
      spans.add(RtSpan(italicStar, italic: true));
      i += italicStar.length + 2;
      continue;
    }

    // Italic: _text_
    final italicUnderscore = _wrap(rest, '_');
    if (italicUnderscore != null) {
      flushPlain();
      spans.add(RtSpan(italicUnderscore, italic: true));
      i += italicUnderscore.length + 2;
      continue;
    }

    // Inline code / highlight: `text`
    final code = _wrap(rest, '`');
    if (code != null) {
      flushPlain();
      spans.add(RtSpan(code, code: true));
      i += code.length + 2;
      continue;
    }

    buffer.write(input[i]);
    i += 1;
  }

  flushPlain();
  return spans.isEmpty ? const [RtSpan('')] : spans;
}

/// If [rest] starts with [marker], returns the content up to the next
/// (non-empty) closing [marker]; otherwise null. Never matches empty content.
String? _wrap(String rest, String marker) {
  if (!rest.startsWith(marker)) return null;
  final start = marker.length;
  final closeIndex = rest.indexOf(marker, start);
  if (closeIndex <= start) return null; // no closing marker or empty content
  return rest.substring(start, closeIndex);
}

final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)\s]+)\)');
