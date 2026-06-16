import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner_plus/src/types/camera.dart';

void main() {
  group('CameraFacing', () {
    test('has three values: back, front, unknown', () {
      expect(CameraFacing.values.length, 3);
      expect(
          CameraFacing.values,
          containsAll([
            CameraFacing.back,
            CameraFacing.front,
            CameraFacing.unknown,
          ]));
    });

    test('back is index 0', () {
      expect(CameraFacing.back.index, 0);
    });

    test('front is index 1', () {
      expect(CameraFacing.front.index, 1);
    });

    test('unknown is index 2', () {
      expect(CameraFacing.unknown.index, 2);
    });

    test('name property matches declaration', () {
      expect(CameraFacing.back.name, 'back');
      expect(CameraFacing.front.name, 'front');
      expect(CameraFacing.unknown.name, 'unknown');
    });
  });
}
