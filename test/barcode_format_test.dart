import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner_plus/src/types/barcode_format.dart';

void main() {
  group('BarcodeFormat.asInt', () {
    test('returns enum index', () {
      expect(BarcodeFormat.aztec.asInt(), 0);
      expect(BarcodeFormat.codabar.asInt(), 1);
      expect(BarcodeFormat.qrcode.asInt(), 11);
      expect(BarcodeFormat.unknown.asInt(), BarcodeFormat.unknown.index);
    });
  });

  group('BarcodeTypesExtension.formatName', () {
    const cases = {
      BarcodeFormat.aztec: 'AZTEC',
      BarcodeFormat.codabar: 'CODABAR',
      BarcodeFormat.code39: 'CODE_39',
      BarcodeFormat.code93: 'CODE_93',
      BarcodeFormat.code128: 'CODE_128',
      BarcodeFormat.dataMatrix: 'DATA_MATRIX',
      BarcodeFormat.ean8: 'EAN_8',
      BarcodeFormat.ean13: 'EAN_13',
      BarcodeFormat.itf: 'ITF',
      BarcodeFormat.maxicode: 'MAXICODE',
      BarcodeFormat.pdf417: 'PDF_417',
      BarcodeFormat.qrcode: 'QR_CODE',
      BarcodeFormat.rss14: 'RSS14',
      BarcodeFormat.rssExpanded: 'RSS_EXPANDED',
      BarcodeFormat.upcA: 'UPC_A',
      BarcodeFormat.upcE: 'UPC_E',
      BarcodeFormat.upcEanExtension: 'UPC_EAN_EXTENSION',
      BarcodeFormat.unknown: 'UNKNOWN',
    };

    for (final entry in cases.entries) {
      test('${entry.key} → "${entry.value}"', () {
        expect(entry.key.formatName, entry.value);
      });
    }
  });

  group('BarcodeTypesExtension.fromString', () {
    test('roundtrip: formatName → fromString returns same format', () {
      for (final format in BarcodeFormat.values) {
        final name = format.formatName;
        expect(
          BarcodeTypesExtension.fromString(name),
          format,
          reason: 'fromString("$name") should return $format',
        );
      }
    });

    test('unrecognised string returns unknown', () {
      expect(
          BarcodeTypesExtension.fromString('GARBAGE'), BarcodeFormat.unknown);
      expect(BarcodeTypesExtension.fromString(''), BarcodeFormat.unknown);
      expect(BarcodeTypesExtension.fromString('qrcode'), BarcodeFormat.unknown);
    });

    test('all known string literals are handled', () {
      final known = [
        'AZTEC',
        'CODABAR',
        'CODE_39',
        'CODE_93',
        'CODE_128',
        'DATA_MATRIX',
        'EAN_8',
        'EAN_13',
        'ITF',
        'MAXICODE',
        'PDF_417',
        'QR_CODE',
        'RSS14',
        'RSS_EXPANDED',
        'UPC_A',
        'UPC_E',
        'UPC_EAN_EXTENSION',
      ];
      for (final s in known) {
        expect(
          BarcodeTypesExtension.fromString(s),
          isNot(BarcodeFormat.unknown),
          reason: '"$s" should not map to unknown',
        );
      }
    });
  });
}
