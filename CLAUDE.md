# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`qr_code_scanner_plus` is a Flutter federated plugin for QR/barcode scanning using native platform embedding (AndroidView / UiKitView). It is in **maintenance mode** — the underlying libraries (ZXing for Android, MTBBarcodeScanner for iOS) are no longer actively maintained.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Analyze (lint)
flutter analyze

# Check formatting (CI enforces this)
dart format --set-exit-if-changed .

# Auto-fix formatting
dart format .

# Run the example app
cd example && flutter run

# Run on a specific platform
cd example && flutter run -d <device_id>
```

There are no automated tests in this plugin. CI (`.github/workflows/dart.yml`) runs `flutter pub get`, `dart format --set-exit-if-changed .`, and `flutter analyze`.

## Architecture

### Plugin Structure

```
lib/
  qr_code_scanner.dart          # Public API entry point (re-exports)
  src/
    qr_code_scanner.dart        # QRView widget + QRViewController
    lifecycle_event_handler.dart # Pauses/resumes camera on app lifecycle
    qr_scanner_overlay_shape.dart# Custom ShapeBorder for scan overlay UI
    types/                      # barcode.dart, barcode_format.dart, camera.dart, features.dart
    web/                        # jsQR JS interop (Web-only)
android/src/main/kotlin/net/touchcapture/qr/flutterqr/
  FlutterQrPlugin.kt            # Plugin entry point, registers factory
  QRViewFactory.kt              # PlatformViewFactory
  QRView.kt                     # Core Android implementation (ZXing)
  CustomFramingRectBarcodeView.kt
  QrShared.kt                   # Static Activity reference + CAMERA_REQUEST_ID constant
ios/Classes/
  SwiftFlutterQrPlugin.swift    # Plugin entry, registers factory
  QRViewFactory.swift           # FlutterPlatformViewFactory
  QRView.swift                  # Core iOS implementation (MTBBarcodeScanner)
example/lib/main.dart           # Full usage demonstration
```

### Communication Model

Each `QRView` widget instance creates a `MethodChannel` keyed by view ID:
`net.touchcapture.qr.flutterqr/qrview_{id}`

Dart calls native methods (`startScan`, `flipCamera`, `toggleFlash`, `pauseCamera`, `resumeCamera`, `stopCamera`, `setDimensions`, `getSystemFeatures`) and native sends scan results back via `onRecognizeQR` channel invocations.

Scan results arrive via `QRViewController.scannedDataStream` (a `StreamController<Barcode>`), not a return value.

### Platform-Specific Behaviors

**Android**:
- Camera permissions are handled manually via `ActivityPluginBinding` using `CAMERA_REQUEST_ID = 513469796`
- Camera pauses automatically on app lifecycle pause via `QrActivityLifecycleCallbacks`
- Hot reload requires calling `controller.pauseCamera()` then `controller.resumeCamera()`

**iOS**:
- Permission is handled internally by MTBBarcodeScanner
- `setDimensions` is called with a 300ms delay after mount to ensure the render box is ready
- Hot reload requires calling `controller.resumeCamera()`

**Web**:
- Uses jsQR JavaScript library (only QR codes — no barcode format support)
- Flash, camera flip, and many features are unsupported stubs

### Scan Area / Overlay

`QRScannerOverlayShape` is a `ShapeBorder` used as the `overlay` parameter. The scan cutout dimensions are passed to native as `setDimensions(width, height, scanArea, cutOutBottomOffset)` so the native decoder restricts recognition to that region.

### Adding Barcode Formats

`BarcodeFormat` in `lib/src/types/barcode_format.dart` maps to:
- Android: index in the enum → `BarcodeFormat` list passed to ZXing
- iOS: index position → `AVMetadataObject.ObjectType` list in `QRView.swift`

Both lists must stay in sync with the Dart enum order.

## Host App Requirements

**Android** (`android/app/build.gradle`):
```gradle
android { defaultConfig { minSdkVersion 20 } }
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>io.flutter.embedded_views_preview</key><true/>
<key>NSCameraUsageDescription</key><string>Camera access required for QR scanning</string>
```

**Web** (`web/index.html`): Must include jsQR script before app bundle.
