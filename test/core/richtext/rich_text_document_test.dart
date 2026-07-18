import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/richtext/rich_text_document.dart';

void main() {
  group('parseRichText blocks', () {
    test('empty / whitespace yields no blocks', () {
      expect(parseRichText(null), isEmpty);
      expect(parseRichText(''), isEmpty);
      expect(parseRichText('   \n  '), isEmpty);
      expect(richTextIsEmpty('  \n '), isTrue);
    });

    test('legacy plain text becomes a single paragraph unchanged', () {
      final blocks = parseRichText('Just a normal note.');
      expect(blocks, hasLength(1));
      expect(blocks.first.type, RtBlockType.paragraph);
      expect(blocks.first.spans.map((s) => s.text).join(), 'Just a normal note.');
      expect(blocks.first.spans.single.bold, isFalse);
    });

    test('headings', () {
      expect(parseRichText('# Title').single.type, RtBlockType.h1);
      expect(parseRichText('## Title').single.type, RtBlockType.h2);
      expect(parseRichText('### Title').single.type, RtBlockType.h3);
    });

    test('bullet and ordered lists with running numbers', () {
      final blocks = parseRichText('- a\n- b\n1. first\n2. second\n3. third');
      expect(blocks[0].type, RtBlockType.bullet);
      expect(blocks[1].type, RtBlockType.bullet);
      expect(blocks[2].type, RtBlockType.ordered);
      expect(blocks[2].orderedNumber, 1);
      expect(blocks[3].orderedNumber, 2);
      expect(blocks[4].orderedNumber, 3);
    });

    test('ordered numbering restarts after a blank line', () {
      final blocks = parseRichText('1. a\n2. b\n\n1. x');
      expect(blocks.last.type, RtBlockType.ordered);
      expect(blocks.last.orderedNumber, 1);
    });

    test('blockquote', () {
      expect(parseRichText('> quoted').single.type, RtBlockType.quote);
    });
  });

  group('inline formatting', () {
    List<RtSpan> spansOf(String src) => parseRichText(src).single.spans;

    test('bold', () {
      final spans = spansOf('a **b** c');
      expect(spans.map((s) => s.text).join(), 'a b c');
      expect(spans.firstWhere((s) => s.text == 'b').bold, isTrue);
    });

    test('italic with * and _', () {
      expect(spansOf('*x*').single.italic, isTrue);
      expect(spansOf('_y_').single.italic, isTrue);
    });

    test('bold + italic', () {
      final span = spansOf('***z***').single;
      expect(span.bold, isTrue);
      expect(span.italic, isTrue);
    });

    test('inline code', () {
      expect(spansOf('`code`').single.code, isTrue);
    });

    test('link keeps label and url', () {
      final span = spansOf('[Google](https://google.com)').single;
      expect(span.text, 'Google');
      expect(span.link, 'https://google.com');
    });

    test('unclosed marker is treated as literal text', () {
      final spans = spansOf('a ** b');
      expect(spans.map((s) => s.text).join(), 'a ** b');
      expect(spans.every((s) => !s.bold), isTrue);
    });
  });

  group('richTextToPlain', () {
    test('strips markers and keeps content', () {
      expect(
        richTextToPlain('# Heading\n**bold** and *italic* and `code`'),
        'Heading bold and italic and code',
      );
    });

    test('adds list markers', () {
      expect(richTextToPlain('- one\n- two'), '• one • two');
      expect(richTextToPlain('1. a\n2. b'), '1. a 2. b');
    });

    test('link renders as its label', () {
      expect(richTextToPlain('see [here](https://x.y)'), 'see here');
    });
  });
}
