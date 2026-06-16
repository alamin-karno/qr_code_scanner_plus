import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner_plus/src/types/camera_exception.dart';

void main() {
  group('CameraException', () {
    test('stores code and description', () {
      final e =
          CameraException('PERMISSION_DENIED', 'Camera access was denied');
      expect(e.code, 'PERMISSION_DENIED');
      expect(e.description, 'Camera access was denied');
    });

    test('description can be null', () {
      final e = CameraException('UNKNOWN', null);
      expect(e.code, 'UNKNOWN');
      expect(e.description, isNull);
    });

    test('toString includes code and description', () {
      final e = CameraException('ERR', 'details');
      expect(e.toString(), 'CameraException(ERR, details)');
    });

    test('toString with null description', () {
      final e = CameraException('ERR', null);
      expect(e.toString(), 'CameraException(ERR, null)');
    });

    test('implements Exception', () {
      final e = CameraException('code', 'desc');
      expect(e, isA<Exception>());
    });

    test('fields are mutable', () {
      final e = CameraException('old', 'old desc');
      e.code = 'new';
      e.description = 'new desc';
      expect(e.code, 'new');
      expect(e.description, 'new desc');
    });
  });
}
