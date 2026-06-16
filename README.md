# QR Code Scanner Plus

[![pub package](https://img.shields.io/pub/v/qr_code_scanner_plus)](https://pub.dev/packages/qr_code_scanner_plus)
[![GH Actions](https://github.com/alamin-karno/qr_code_scanner_plus/workflows/dart/badge.svg)](https://github.com/alamin-karno/qr_code_scanner_plus/actions)

A Flutter QR code and barcode scanner that natively embeds the platform camera view inside your widget tree — no Activity or ViewController jumps required. Uses **ZXing** on Android and native **AVFoundation** on iOS.

> **Fork notice:** This package is a maintained fork of [qr_code_scanner](https://pub.dev/packages/qr_code_scanner) by juliuscanute. It applies community bug-fixes and updates compatibility for Dart 3 and Flutter 3.x.

> **Maintenance mode:** The Android ZXing library is no longer actively maintained. Only bug fixes and compatibility updates are accepted in this fork.

## Screenshots

<table>
<tr>
<th colspan="2">Android</th>
</tr>
<tr>
<td>
<p align="center">
<img src="https://raw.githubusercontent.com/juliuscanute/qr_code_scanner/master/.resources/android-app-screen-one.jpg" width="30%" height="30%">
</p>
</td>
<td>
<p align="center">
<img src="https://raw.githubusercontent.com/juliuscanute/qr_code_scanner/master/.resources/android-app-screen-two.jpg" width="30%" height="30%">
</p>
</td>
</tr>
<tr>
<th colspan="2">iOS</th>
</tr>
<tr>
<td>
<p align="center">
<img src="https://raw.githubusercontent.com/juliuscanute/qr_code_scanner/master/.resources/ios-app-screen-one.png" width="30%" height="30%">
</p>
</td>
<td>
<p align="center">
<img src="https://raw.githubusercontent.com/juliuscanute/qr_code_scanner/master/.resources/ios-app-screen-two.png" width="30%" height="30%">
</p>
</td>
</tr>
</table>

## Requirements

| Platform | Minimum                         |
|----------|---------------------------------|
| Dart SDK | >=3.0.0                         |
| Flutter  | >=3.0.0                         |
| Android  | minSdkVersion 20, compileSdk 35 |
| iOS      | iOS 12+                         |

## Installation

```yaml
dependencies:
  qr_code_scanner_plus: ^1.1.0
```

## Usage

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // Pause/resume camera on hot reload to keep it in sync.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: result != null
                  ? Text('Type: ${result!.format.name}   Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
```

## Android Integration

Add to `android/app/build.gradle`:

```gradle
android {
    compileSdk 35

    defaultConfig {
        minSdkVersion 20
    }
}
```

## iOS Integration

Add to `ios/Runner/Info.plist`:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

### Swift Package Manager

This plugin supports **Swift Package Manager** (Flutter 3.22+). No extra steps are needed — Flutter automatically uses `ios/Package.swift` when SPM is enabled in your project.

If your app still uses CocoaPods, the `ios/qr_code_scanner_plus.podspec` continues to work as before.

## Web Integration

Add to `web/index.html` before your app's `<script>` tag:

```html
<script src="https://cdn.jsdelivr.net/npm/jsqr@1.3.1/dist/jsQR.min.js"></script>
```

> **Note:** On web, only QR codes are supported. Flash, camera flip, pause/resume are not implemented.

## Controls

### Flip Camera

```dart
await controller.flipCamera();
```

### Toggle Flash

```dart
await controller.toggleFlash();
```

### Pause / Resume

```dart
await controller.pauseCamera();
await controller.resumeCamera();
```

### Restrict Barcode Formats

```dart
QRView(
  key: qrKey,
  onQRViewCreated: _onQRViewCreated,
  formatsAllowed: [BarcodeFormat.qrcode, BarcodeFormat.ean13],
)
```

### Scan Area Overlay

```dart
QRView(
  key: qrKey,
  onQRViewCreated: _onQRViewCreated,
  overlay: QrScannerOverlayShape(
    borderColor: Colors.red,
    borderRadius: 10,
    borderLength: 30,
    borderWidth: 10,
    cutOutSize: 300,
  ),
)
```

## Credits

- Android scanning: [ZXing](https://github.com/zxing/zxing) via [zxing-android-embedded](https://github.com/journeyapps/zxing-android-embedded)
- iOS scanning: native `AVFoundation` (replaced MTBBarcodeScanner to enable Swift Package Manager support)
- Original plugin: [juliuscanute/qr_code_scanner](https://github.com/juliuscanute/qr_code_scanner)
