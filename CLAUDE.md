# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`qr_code_scanner_plus` is a Flutter federated plugin for QR/barcode scanning using native platform embedding (AndroidView / UiKitView). It is in **maintenance mode** — the Android ZXing library is no longer actively maintained. iOS now uses a native AVFoundation implementation (`NativeBarcodeScanner`) with full Swift Package Manager support.

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

## Running Tests

```bash
# Run all Dart unit tests (fast, no device needed)
flutter test

# Run with verbose output
flutter test --reporter=expanded

# Run a single test file
flutter test test/barcode_format_test.dart
```

**iOS Swift tests** live in `ios/qr_code_scanner_plus/Tests/` and are run via Xcode with the full Flutter build. They cannot be run with `swift test` directly because `FlutterFramework` is a local package injected by Flutter at build time. To run them: open `example/ios/Runner.xcworkspace` in Xcode → Product → Test.

CI (`.github/workflows/dart.yml`) runs `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze`, and `flutter test`.

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

## Testing Rules

**For every new feature or bug fix, you MUST:**

1. **Write tests before or alongside the code** — not after. Tests go in:
   - `test/` for Dart unit tests (types, utilities, overlay shape, format parsing)
   - `ios/qr_code_scanner_plus/Tests/` for Swift/iOS unit tests (scanner state, camera position, torch)

2. **Run `flutter test` and confirm all tests pass** before considering the work done. Fix any failures before moving on — never leave tests broken.

3. **Test coverage guidelines by layer:**
   - **Dart types** (`lib/src/types/`): test every constructor, factory, and non-trivial method
   - **`QrScannerOverlayShape`**: test all constructor paths including assertion failures
   - **iOS `NativeBarcodeScanner`**: test state transitions (freeze/unfreeze/stop) and property accessors that don't require a real camera session
   - **New public API**: every new parameter or method needs at least one happy-path test and one edge-case or error-path test

4. **What to avoid testing:**
   - Do not write tests that require a real camera or simulator — those belong in manual verification steps
   - Do not test Flutter framework internals or platform channel plumbing directly
   - Do not write tests that only verify that a line of code runs without asserting a meaningful outcome

5. **Test file naming:** `test/<subject>_test.dart` and `Tests/<Subject>Tests.swift`

## Changelog & README Rules

**After every feature or bug fix, you MUST:**

1. **Update `CHANGELOG.md`** — add the change under the existing `## Unreleased` block (or create one at the top if it doesn't exist). Use the section headings already established in the file: `#### Breaking Changes`, `#### iOS`, `#### Android`, `#### Bug Fixes`, `#### Dependencies`, `#### CI`, `#### Testing`, etc. Be concise but include the what and why.

2. **Update `README.md`** if the change affects any of the following:
   - Requirements (minimum SDK, deployment target, Flutter version)
   - Installation or setup steps
   - Public API or usage examples
   - Platform-specific integration instructions
   - The feature set described in the introduction or Controls sections
   - Credits (e.g. underlying library changes)

3. **Do NOT commit** changelog/README updates until the user explicitly asks to commit. Stage the work in the working tree and let the user review first.

The `## Unreleased` heading format is `## Unreleased — <next-version>` (e.g. `## Unreleased — 1.2.0`). If the unreleased block already exists, add to it rather than creating a duplicate.
