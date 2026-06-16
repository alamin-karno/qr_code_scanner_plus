import Foundation
import Flutter
import AVFoundation

public class QRView: NSObject, FlutterPlatformView {
    var previewView: UIView
    var scanner: NativeBarcodeScanner?
    var registrar: FlutterPluginRegistrar
    var channel: FlutterMethodChannel
    var cameraFacing: CameraPosition

    // Codabar, maxicode, rss14 & rssexpanded not supported. Replaced with qr.
    // UPCa uses ean13 object.
    let qrCodeTypes: [Int: AVMetadataObject.ObjectType] = [
        0: .aztec,
        1: .qr,
        2: .code39,
        3: .code93,
        4: .code128,
        5: .dataMatrix,
        6: .ean8,
        7: .ean13,
        8: .interleaved2of5,
        9: .qr,
        10: .pdf417,
        11: .qr,
        12: .qr,
        13: .qr,
        14: .ean13,
        15: .upce,
    ]

    public init(withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar,
                withId id: Int64, params: Dictionary<String, Any>) {
        self.registrar = registrar
        previewView = UIView(frame: frame)
        cameraFacing = CameraPosition(rawValue: UInt(Int(params["cameraFacing"] as! Double))) ?? .back
        channel = FlutterMethodChannel(
            name: "net.touchcapture.qr.flutterqr/qrview_\(id)",
            binaryMessenger: registrar.messenger()
        )
    }

    deinit {
        scanner?.stopScanning()
    }

    public func view() -> UIView {
        channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "setDimensions":
                let args = call.arguments as! Dictionary<String, Double>
                self?.setDimensions(result,
                                    width: args["width"] ?? 0,
                                    height: args["height"] ?? 0,
                                    scanAreaWidth: args["scanAreaWidth"] ?? 0,
                                    scanAreaHeight: args["scanAreaHeight"] ?? 0,
                                    scanAreaOffset: args["scanAreaOffset"] ?? 0)
            case "startScan":
                self?.startScan(call.arguments as! Array<Int>, result)
            case "flipCamera":
                self?.flipCamera(result)
            case "toggleFlash":
                self?.toggleFlash(result)
            case "pauseCamera":
                self?.pauseCamera(result)
            case "stopCamera":
                self?.stopCamera(result)
            case "resumeCamera":
                self?.resumeCamera(result)
            case "getCameraInfo":
                self?.getCameraInfo(result)
            case "getFlashInfo":
                self?.getFlashInfo(result)
            case "getSystemFeatures":
                self?.getSystemFeatures(result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        return previewView
    }

    func setDimensions(_ result: @escaping FlutterResult, width: Double, height: Double,
                       scanAreaWidth: Double, scanAreaHeight: Double, scanAreaOffset: Double) {
        previewView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        let midX = previewView.bounds.midX
        let midY = previewView.bounds.midY

        if let sc = scanner {
            sc.getPreviewLayer()?.frame = previewView.bounds
        } else {
            scanner = NativeBarcodeScanner(previewView: previewView, cameraPosition: cameraFacing)
        }

        if scanAreaWidth != 0 && scanAreaHeight != 0 {
            scanner?.onScanningStarted = {
                var rect = CGRect(
                    x: Double(midX) - (scanAreaWidth / 2),
                    y: Double(midY) - (scanAreaHeight / 2),
                    width: scanAreaWidth,
                    height: scanAreaHeight
                )
                if scanAreaOffset != 0 {
                    rect = rect.offsetBy(dx: 0, dy: CGFloat(-scanAreaOffset))
                }
                self.scanner?.scanRect = rect
            }
        }
        result(width)
    }

    func startScan(_ arguments: Array<Int>, _ result: @escaping FlutterResult) {
        var allowedTypes: [AVMetadataObject.ObjectType] = []
        arguments.forEach { arg in
            if let type = qrCodeTypes[arg] { allowedTypes.append(type) }
        }

        NativeBarcodeScanner.requestCameraPermission { [weak self] granted in
            guard let self = self else { return }
            self.channel.invokeMethod("onPermissionSet", arguments: granted)

            if granted {
                do {
                    self.scanner?.onCodesDetected = { [weak self] codes in
                        guard let self = self else { return }
                        for code in codes {
                            guard let typeString = self.metadataTypeString(for: code.type) else { continue }

                            let bytes: Data? = {
                                if #available(iOS 11.0, *) {
                                    switch code.descriptor {
                                    case let d as CIQRCodeDescriptor:     return d.errorCorrectedPayload
                                    case let d as CIAztecCodeDescriptor:  return d.errorCorrectedPayload
                                    case let d as CIPDF417CodeDescriptor: return d.errorCorrectedPayload
                                    case let d as CIDataMatrixCodeDescriptor: return d.errorCorrectedPayload
                                    default: return nil
                                    }
                                }
                                return nil
                            }()

                            var payload: [String: Any]
                            if let value = code.stringValue {
                                payload = bytes != nil
                                    ? ["code": value, "type": typeString, "rawBytes": bytes!]
                                    : ["code": value, "type": typeString]
                            } else if let b = bytes {
                                payload = ["type": typeString, "rawBytes": b]
                            } else {
                                continue
                            }

                            if allowedTypes.isEmpty || allowedTypes.contains(code.type) {
                                self.channel.invokeMethod("onRecognizeQR", arguments: payload)
                            }
                        }
                    }
                    try self.scanner?.startScanning()
                } catch {
                    result(FlutterError(code: "unknown-error", message: "Unable to start scanning", details: error))
                }
            }
        }
    }

    func stopCamera(_ result: @escaping FlutterResult) {
        if scanner?.isScanning() == true { scanner?.stopScanning() }
        result(nil)
    }

    func getCameraInfo(_ result: @escaping FlutterResult) {
        result(cameraFacing.rawValue)
    }

    func flipCamera(_ result: @escaping FlutterResult) {
        guard let sc = scanner else {
            return result(FlutterError(code: "404", message: "No barcode scanner found", details: nil))
        }
        if sc.hasOppositeCamera() {
            sc.flipCamera()
            cameraFacing = sc.camera
        }
        result(sc.camera.rawValue)
    }

    func getFlashInfo(_ result: @escaping FlutterResult) {
        guard let sc = scanner else {
            return result(FlutterError(code: "cameraInformationError",
                                       message: "Could not get flash information", details: nil))
        }
        result(sc.isTorchOn)
    }

    func toggleFlash(_ result: @escaping FlutterResult) {
        guard let sc = scanner else {
            return result(FlutterError(code: "404", message: "No barcode scanner found", details: nil))
        }
        guard sc.hasTorch() else {
            return result(FlutterError(code: "404", message: "This device doesn't support flash", details: nil))
        }
        sc.toggleTorch()
        result(sc.isTorchOn)
    }

    func pauseCamera(_ result: @escaping FlutterResult) {
        guard let sc = scanner else {
            return result(FlutterError(code: "404", message: "No barcode scanner found", details: nil))
        }
        if sc.isScanning() { sc.freezeCapture() }
        result(true)
    }

    func resumeCamera(_ result: @escaping FlutterResult) {
        guard let sc = scanner else {
            return result(FlutterError(code: "404", message: "No barcode scanner found", details: nil))
        }
        if !sc.isScanning() { sc.unfreezeCapture() }
        result(true)
    }

    func getSystemFeatures(_ result: @escaping FlutterResult) {
        guard let sc = scanner else {
            return result(FlutterError(code: "404", message: nil, details: nil))
        }
        var hasBack = false
        var hasFront = false
        if sc.camera == .back {
            hasBack = true
            if sc.hasOppositeCamera() { hasFront = true }
        } else {
            hasFront = true
            if sc.hasOppositeCamera() { hasBack = true }
        }
        result([
            "hasFrontCamera": hasFront,
            "hasBackCamera": hasBack,
            "hasFlash": sc.hasTorch(),
            "activeCamera": sc.camera.rawValue,
        ])
    }

    // MARK: - Private helpers

    private func metadataTypeString(for type: AVMetadataObject.ObjectType) -> String? {
        switch type {
        case .aztec:              return "AZTEC"
        case .code39:             return "CODE_39"
        case .code93:             return "CODE_93"
        case .code128:            return "CODE_128"
        case .dataMatrix:         return "DATA_MATRIX"
        case .ean8:               return "EAN_8"
        case .ean13:              return "EAN_13"
        case .itf14, .interleaved2of5: return "ITF"
        case .pdf417:             return "PDF_417"
        case .qr:                 return "QR_CODE"
        case .upce:               return "UPC_E"
        default:                  return nil
        }
    }
}
