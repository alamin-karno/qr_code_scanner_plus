import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner_plus/src/types/features.dart';

void main() {
  group('SystemFeatures.fromJson', () {
    test('parses all true values', () {
      final f = SystemFeatures.fromJson({
        'hasFlash': true,
        'hasBackCamera': true,
        'hasFrontCamera': true,
      });
      expect(f.hasFlash, isTrue);
      expect(f.hasBackCamera, isTrue);
      expect(f.hasFrontCamera, isTrue);
    });

    test('parses all false values', () {
      final f = SystemFeatures.fromJson({
        'hasFlash': false,
        'hasBackCamera': false,
        'hasFrontCamera': false,
      });
      expect(f.hasFlash, isFalse);
      expect(f.hasBackCamera, isFalse);
      expect(f.hasFrontCamera, isFalse);
    });

    test('missing keys default to false', () {
      final f = SystemFeatures.fromJson({});
      expect(f.hasFlash, isFalse);
      expect(f.hasBackCamera, isFalse);
      expect(f.hasFrontCamera, isFalse);
    });

    test('partial map populates missing keys with false', () {
      final f = SystemFeatures.fromJson({'hasFlash': true});
      expect(f.hasFlash, isTrue);
      expect(f.hasBackCamera, isFalse);
      expect(f.hasFrontCamera, isFalse);
    });
  });

  group('SystemFeatures direct constructor', () {
    test('stores values correctly', () {
      final f = SystemFeatures(true, false, true);
      expect(f.hasFlash, isTrue);
      expect(f.hasBackCamera, isFalse);
      expect(f.hasFrontCamera, isTrue);
    });
  });
}
