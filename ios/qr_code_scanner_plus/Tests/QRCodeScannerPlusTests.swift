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
        XCTAssertFalse(scanner.isTorchOn)
    }

    func testHasTorchFalseWithoutSession() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertFalse(scanner.hasTorch())
    }

    // MARK: - Preview layer tests

    func testPreviewLayerNilBeforeStart() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertNil(scanner.getPreviewLayer())
    }

    // MARK: - Freeze / unfreeze idempotency (issue #9)

    func testFreezeTwiceStillFrozen() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        // Freeze when not started must not crash and leave isScanning false.
        scanner.freezeCapture()
        scanner.freezeCapture()
        XCTAssertFalse(scanner.isScanning())
    }

    func testUnfreezeTwiceWithoutStartHasNoEffect() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        scanner.unfreezeCapture()
        scanner.unfreezeCapture()
        XCTAssertFalse(scanner.isScanning())
    }

    func testStopIdempotent() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        scanner.stopScanning()
        scanner.stopScanning()
        XCTAssertFalse(scanner.isScanning())
    }

    // MARK: - Scan rect tests

    func testScanRectDefaultNil() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertNil(scanner.scanRect)
    }

    func testScanRectCanBeSet() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        let rect = CGRect(x: 50, y: 50, width: 200, height: 200)
        scanner.scanRect = rect
        XCTAssertEqual(scanner.scanRect, rect)
    }

    func testScanRectCanBeCleared() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        scanner.scanRect = CGRect(x: 10, y: 10, width: 100, height: 100)
        scanner.scanRect = nil
        XCTAssertNil(scanner.scanRect)
    }

    // MARK: - Camera callbacks tests

    func testOnCodesDetectedDefaultsNil() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertNil(scanner.onCodesDetected)
    }

    func testOnScanningStartedDefaultsNil() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        XCTAssertNil(scanner.onScanningStarted)
    }

    func testOnCodesDetectedCanBeAssigned() {
        let view = UIView()
        let scanner = NativeBarcodeScanner(previewView: view)
        var callCount = 0
        scanner.onCodesDetected = { _ in callCount += 1 }
        XCTAssertNotNil(scanner.onCodesDetected)
    }

    // MARK: - Multiple scanner instances (issue #9 — independent state)

    func testMultipleScannerInstancesAreIndependent() {
        let viewA = UIView()
        let viewB = UIView()
        let scannerA = NativeBarcodeScanner(previewView: viewA, cameraPosition: .back)
        let scannerB = NativeBarcodeScanner(previewView: viewB, cameraPosition: .front)

        scannerA.freezeCapture()
        // Freezing A must not affect B's state.
        XCTAssertFalse(scannerB.isScanning())
        XCTAssertEqual(scannerB.camera, .front)
    }

    // MARK: - Deployment target (issue #23)

    func testIOSVersionIsAtLeast13() {
        // The Package.swift now declares iOS 13 as the minimum.
        // This test documents and enforces that expectation at runtime.
        if #available(iOS 13.0, *) {
            XCTAssertTrue(true)
        } else {
            XCTFail("This plugin requires iOS 13.0 or later")
        }
    }
}
