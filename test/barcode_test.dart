import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner_plus/src/types/barcode.dart';
import 'package:qr_code_scanner_plus/src/types/barcode_format.dart';

void main() {
  group('Barcode', () {
    test('stores code, format, and rawBytes', () {
      final barcode =
          Barcode('https://example.com', BarcodeFormat.qrcode, [1, 2, 3]);
      expect(barcode.code, 'https://example.com');
      expect(barcode.format, BarcodeFormat.qrcode);
      expect(barcode.rawBytes, [1, 2, 3]);
    });

    test('code can be null', () {
      final barcode = Barcode(null, BarcodeFormat.unknown, null);
      expect(barcode.code, isNull);
    });

    test('rawBytes can be null', () {
      final barcode = Barcode('hello', BarcodeFormat.code128, null);
      expect(barcode.rawBytes, isNull);
    });

    test('accepts all BarcodeFormat values', () {
      for (final format in BarcodeFormat.values) {
        final b = Barcode('data', format, null);
        expect(b.format, format);
      }
    });

    test('rawBytes holds arbitrary byte values', () {
      final bytes = List.generate(256, (i) => i);
      final barcode = Barcode('test', BarcodeFormat.dataMatrix, bytes);
      expect(barcode.rawBytes, bytes);
      expect(barcode.rawBytes!.length, 256);
    });
  });
}
