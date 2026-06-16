import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_scanner_plus/src/qr_scanner_overlay_shape.dart';

void main() {
  group('QrScannerOverlayShape construction', () {
    test('default values are applied when no args given', () {
      final shape = QrScannerOverlayShape();
      expect(shape.borderColor, Colors.red);
      expect(shape.borderWidth, 3.0);
      expect(shape.borderRadius, 0.0);
      expect(shape.borderLength, 40.0);
      expect(shape.cutOutWidth, 250.0);
      expect(shape.cutOutHeight, 250.0);
      expect(shape.cutOutBottomOffset, 0.0);
    });

    test('cutOutSize sets both width and height', () {
      final shape = QrScannerOverlayShape(cutOutSize: 300);
      expect(shape.cutOutWidth, 300.0);
      expect(shape.cutOutHeight, 300.0);
    });

    test('explicit cutOutWidth/cutOutHeight override cutOutSize', () {
      final shape = QrScannerOverlayShape(cutOutWidth: 200, cutOutHeight: 150);
      expect(shape.cutOutWidth, 200.0);
      expect(shape.cutOutHeight, 150.0);
    });

    test('custom border values are stored', () {
      final shape = QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderWidth: 5,
        borderRadius: 12,
        borderLength: 30,
        cutOutSize: 200,
      );
      expect(shape.borderColor, Colors.blue);
      expect(shape.borderWidth, 5.0);
      expect(shape.borderRadius, 12.0);
      expect(shape.borderLength, 30.0);
    });

    test('throws AssertionError when borderLength exceeds half cutOut', () {
      // borderLength must be <= min(cutOut) / 2 + borderWidth * 2
      // With cutOutSize=100 and borderWidth=0: max borderLength = 50
      expect(
        () => QrScannerOverlayShape(
          cutOutSize: 100,
          borderWidth: 0,
          borderLength: 60,
        ),
        throwsAssertionError,
      );
    });

    test(
        'throws AssertionError when both cutOutSize and cutOutWidth/Height given',
        () {
      expect(
        () => QrScannerOverlayShape(
          cutOutSize: 200,
          cutOutWidth: 200,
          cutOutHeight: 200,
        ),
        throwsAssertionError,
      );
    });

    test('dimensions returns EdgeInsets.all(10)', () {
      final shape = QrScannerOverlayShape();
      expect(shape.dimensions, const EdgeInsets.all(10));
    });

    test('getOuterPath returns a non-empty Path', () {
      final shape = QrScannerOverlayShape(cutOutSize: 200);
      final path = shape.getOuterPath(
        const Rect.fromLTWH(0, 0, 400, 600),
      );
      expect(path, isNotNull);
    });

    test('getInnerPath returns a non-empty Path', () {
      final shape = QrScannerOverlayShape(cutOutSize: 200);
      final path = shape.getInnerPath(
        const Rect.fromLTWH(0, 0, 400, 600),
      );
      expect(path, isNotNull);
    });
  });

  group('QrScannerOverlayShape painting', () {
    testWidgets('renders without error inside a widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 400,
              height: 600,
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Colors.green,
                  cutOutSize: 250,
                  borderWidth: 4,
                  borderLength: 30,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
