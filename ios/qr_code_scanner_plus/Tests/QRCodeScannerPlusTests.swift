import XCTest
@testable import qr_code_scanner_plus

final class QRCodeScannerPlusTests: XCTestCase {

    // MARK: - NativeBarcodeScanner state tests

    func testScannerInitiallyNotScanning() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let scanner = NativeBarcodeScanner(previewView: view, cameraPosition: .back)
        XCTAssertFalse(scanner.isScanning())
    }

    func testScannerDefaultCameraIsBack() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertEqual(scanner.camera, .back)
    }

    func testScannerFrontCameraInit() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view, cameraPosition: .front)
        XCTAssertEqual(scanner.camera, .front)
    }

    func testFreezeBeforeStartHasNoEffect() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        // Calling freezeCapture before startScanning must not crash or change state.
        scanner.freezeCapture()
        XCTAssertFalse(scanner.isScanning())
    }

    func testUnfreezeBeforeStartHasNoEffect() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        scanner.unfreezeCapture()
        XCTAssertFalse(scanner.isScanning())
    }

    func testStopBeforeStartHasNoEffect() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        scanner.stopScanning()
        XCTAssertFalse(scanner.isScanning())
    }

    // MARK: - CameraPosition enum tests

    func testCameraPositionRawValues() {
        XCTAssertEqual(CameraPosition.back.rawValue, 0)
        XCTAssertEqual(CameraPosition.front.rawValue, 1)
    }

    func testCameraPositionCaptureMapping() {
        XCTAssertEqual(CameraPosition.back.capturePosition, .back)
        XCTAssertEqual(CameraPosition.front.capturePosition, .front)
    }

    func testCameraPositionFromRawValue() {
        XCTAssertEqual(CameraPosition(rawValue: 0), .back)
        XCTAssertEqual(CameraPosition(rawValue: 1), .front)
        XCTAssertNil(CameraPosition(rawValue: 99))
    }

    // MARK: - Torch state tests

    func testTorchDefaultsOff() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        // No active session means no torch device, so isTorchOn should be false.
        XCTAssertFalse(scanner.isTorchOn)
    }

    func testHasTorchFalseWithoutSession() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        // Without an active capture session there is no input device.
        XCTAssertFalse(scanner.hasTorch())
    }

    // MARK: - Preview layer tests

    func testPreviewLayerNilBeforeStart() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertNil(scanner.getPreviewLayer())
    }
}
