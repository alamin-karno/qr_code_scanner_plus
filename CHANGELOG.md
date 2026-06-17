## Unreleased — 1.2.0

#### iOS
* **Fix iOS minimum deployment target** (Package.swift + podspec): raised from 12.0 to 13.0,
  resolving a Swift Package Manager build failure where `FlutterFramework` requires iOS 13.
  (Closes [#5](https://github.com/alamin-karno/qr_code_scanner_plus/issues/5),
  upstream [vespr-wallet#23](https://github.com/vespr-wallet/qr_code_scanner_plus/issues/23))
* **Fix camera preview rotated 90° in landscape-locked apps**: `NativeBarcodeScanner`
  now sets `videoOrientation` on the preview layer connection at session start, using
  `UIWindowScene` for iOS 13+ (SceneDelegate / iOS 26 compatible) and
  `statusBarOrientation` on older systems. Also registers for
  `UIDevice.orientationDidChangeNotification` so the orientation stays correct during
  runtime rotations.
  (Closes [#6](https://github.com/alamin-karno/qr_code_scanner_plus/issues/6),
  upstream [vespr-wallet#19](https://github.com/vespr-wallet/qr_code_scanner_plus/issues/19))
* **Auto-select best camera lens for QR scanning (triple-lens support)**: on iOS 13+,
  `captureDevice(for:)` now prefers `.builtInTripleCamera` over `.builtInWideAngleCamera`,
  letting AVFoundation switch between tele/wide/ultra-wide automatically. This allows
  scanning small QR codes on iPhone 14 Pro / 15 Pro without manual camera switching.
  (Closes [#7](https://github.com/alamin-karno/qr_code_scanner_plus/issues/7),
  upstream [vespr-wallet#17](https://github.com/vespr-wallet/qr_code_scanner_plus/issues/17))
* **Fix duplicate QR detections / `pauseCamera` appearing ineffective**: added a 1-second
  per-code scan cooldown in `NativeBarcodeScanner.metadataOutput(_:didOutput:)`. The same
  code is suppressed within the cooldown window, preventing dozens of identical callbacks
  from firing in the gap between detection and the Flutter side calling `pauseCamera()`.
  Cooldown resets when `resumeCamera()` is called.
  (Closes [#8](https://github.com/alamin-karno/qr_code_scanner_plus/issues/8),
  upstream [vespr-wallet#9](https://github.com/vespr-wallet/qr_code_scanner_plus/issues/9))
* **Fix UI hang on dispose for iOS 18+**: `stopCamera()` now calls `pauseCamera` instead of
  `stopCamera` on iOS 18 and later to avoid a 1–3 second UI freeze when the scanner page is
  dismissed. iOS version is parsed robustly (handles hotfix versions like `26.0.1`).
  (Ported from [vespr-wallet/qr_code_scanner_plus](https://github.com/vespr-wallet/qr_code_scanner_plus))
* **Fix crash when popping page during resume**: `QRViewController` now tracks a `disposed`
  flag and guards against double-dispose; `_QRViewState.dispose()` calls `_disposeImpl()` to
  cleanly stop the camera before teardown.

#### Bug Fixes
* **Fix `getCameraInfo` invoking the platform channel twice**: the second
  `await _channel.invokeMethod('getCameraInfo')` was redundant; now reuses the already-fetched
  value. Closes [#11](https://github.com/alamin-karno/qr_code_scanner_plus/issues/11).
* **Fix `StateError` when a barcode event arrives after dispose**: `_scanUpdateController.sink.add()`
  is now guarded with `isClosed` so in-flight `onRecognizeQR` events after teardown are silently
  dropped instead of crashing.
  Closes [#15](https://github.com/alamin-karno/qr_code_scanner_plus/issues/15).
* **Fix `QrScannerOverlayShape` border-length clamp using wrong dimension**: `min(cutOutHeight, cutOutHeight)`
  typo corrected to `min(cutOutWidth, cutOutHeight)`, preventing corner brackets from overflowing
  the narrow axis of a non-square scan window.
  Closes [#14](https://github.com/alamin-karno/qr_code_scanner_plus/issues/14).

#### Android
* **Fix `isRequestingPermission` guard never engaged**: `isRequestingPermission = true` was
  missing before calling `requestPermissions`, so the `!isRequestingPermission` guard was always
  bypassed and permission dialogs could fire repeatedly.
  Closes [#12](https://github.com/alamin-karno/qr_code_scanner_plus/issues/12).
* **Fix `onPermissionSet` firing on every `startScan` call**: added `hasReportedPermission`
  flag so `onPermissionSet(true)` is sent only once when the permission is first confirmed, not
  on every scan start. The flag resets when permission is revoked.
  Closes [#13](https://github.com/alamin-karno/qr_code_scanner_plus/issues/13).

#### Dart
* **Self-dispose pattern**: `QRViewController` now automatically disposes itself when the
  `QRView` widget is removed from the tree — callers no longer need to call `dispose()`.
  The public `dispose()` method is deprecated and is now a no-op (logs a warning).
  (Ported from [vespr-wallet/qr_code_scanner_plus](https://github.com/vespr-wallet/qr_code_scanner_plus))
* Added platform detection layer (`lib/src/platform/`) using conditional imports so
  `Platform.operatingSystemVersion` is read on mobile/desktop and a user-agent string is
  used on web — enabling the iOS-version check without breaking WASM builds.
* Web conditional import updated to include `dart.library.js_interop` in addition to
  `dart.library.html`, enabling the web scanner on WASM targets.

#### Web
* **Migrated from `dart:html` / `package:js` to `package:web` / `dart:js_interop`** — the
  old APIs are deprecated and unavailable in WASM. `flutter_qr_web.dart`, `jsqr.dart`, and
  `media.dart` all rewritten.
  (Ported from [vespr-wallet/qr_code_scanner_plus](https://github.com/vespr-wallet/qr_code_scanner_plus))
* **Smarter back camera selection on mobile web**: the implementation now enumerates devices
  and prefers a camera whose label contains "main" or "primary" before falling back to any
  back-facing camera or the generic `environment` constraint.
* Web controller now participates in the self-dispose pattern; `dispose()` is deprecated.

#### Android
* Bumped `compileSdk` and `targetSdkVersion` to 36.
* Removed `coreLibraryDesugaringEnabled` and the `desugar_jdk_libs` dependency (no longer
  needed).

#### Dependencies
* Removed `js: ^0.7.1` (deprecated, WASM-incompatible).
* Added `web: ^1.0.0` (required by the `dart:js_interop` web implementation).
* Raised minimum Flutter SDK to `>=3.24.0` and Dart SDK to `>=3.5.0`.
* Added `flutter_test` to `dev_dependencies` to support the new Dart unit test suite.

#### Testing
* **Added Dart unit test suite** (`test/`): 53 tests across 5 files covering `BarcodeFormat`
  (enum values, `formatName`, `fromString` roundtrip and unknown fallback), `Barcode` model,
  `SystemFeatures.fromJson`, `CameraException`, `CameraFacing`, and `QrScannerOverlayShape`
  (construction, assertions, path generation, widget rendering).
* **Expanded iOS Swift tests** to 25 test cases covering freeze/unfreeze idempotency, scan
  rect lifecycle, multiple independent scanner instances, and the iOS 13 deployment target.

#### CI
* Added `flutter test` step to `.github/workflows/dart.yml` so tests run on every push and
  pull request.

#### Example App
* Redesigned example app with a full-screen dark scanner UI, flash toggle in top bar, Pause /
  Flip / History action buttons, a result card with one-tap copy, and a scrollable scan
  history bottom sheet (up to 20 entries).

---

## Unreleased — 1.1.0

#### iOS
* Replaced `MTBBarcodeScanner` (CocoaPods-only, archived upstream) with a purpose-built
  `NativeBarcodeScanner` class backed by `AVFoundation`. Eliminates the only external iOS
  dependency and unblocks Swift Package Manager builds.
  ([upstream #776](https://github.com/juliuscanute/qr_code_scanner/issues/776))
* Added **Swift Package Manager** support. Package manifest at
  `ios/qr_code_scanner_plus/Package.swift` (`swift-tools-version: 5.9`), following the
  official Flutter plugin convention (`ios/<plugin_name>/Package.swift`). Flutter injects
  `FlutterFramework` as a local package at build time; the manifest declares it via
  `.package(name: "FlutterFramework", path: "../FlutterFramework")`.
  Both CocoaPods and SPM share the same Swift source files under
  `ios/qr_code_scanner_plus/Sources/qr_code_scanner_plus/` — single source of truth.
* Bumped iOS deployment target `8.0` → `12.0` (required by modern `AVFoundation` APIs).
* Updated `pluginClass` from `FlutterQrPlugin` (ObjC bridge) to `SwiftFlutterQrPlugin` (Swift)
  so SPM-based plugin registration works without an ObjC shim.
* Removed `ios/qr_code_scanner.podspec`; replaced by `ios/qr_code_scanner_plus.podspec`.

#### Testing
* Added `ios/Tests/QRCodeScannerPlusTests.swift` — 11 unit tests for `NativeBarcodeScanner`
  state, camera-position enum, and torch behaviour. Works with both `pod test` (via
  `test_spec`) and SPM `.testTarget`.

#### Breaking Changes
* Package renamed to `qr_code_scanner_plus`. Update your import:
  ```dart
  import 'package:qr_code_scanner_plus/qr_code_scanner.dart';
  ```
* Dart SDK minimum raised to `>=3.0.0`. Flutter minimum raised to `>=3.0.0`.
* Android `compileSdk` raised to 35, `targetSdkVersion` to 34, JVM target to 17.

#### Bug Fixes
* **[Dart]** Fix `LateInitializationError` crash on `QRView` dispose — `_channel` is now
  nullable and `updateDimensions()` is guarded against uninitialized channel.
  ([upstream PR #696](https://github.com/juliuscanute/qr_code_scanner/pull/696) /
  [#748](https://github.com/juliuscanute/qr_code_scanner/pull/748))
* **[Web]** Fix `Undefined name 'platformViewRegistry'` error caused by the removal of
  `dart:ui.platformViewRegistry` — extracted into `web_view_registry.dart` using
  `dart:ui_web`.
  ([upstream PR #760](https://github.com/juliuscanute/qr_code_scanner/pull/760) /
  [#769](https://github.com/juliuscanute/qr_code_scanner/pull/769) /
  [#771](https://github.com/juliuscanute/qr_code_scanner/pull/771))
* **[Web]** Remove `dart:js_util` import (removed in Dart 3.10) and replace
  `promiseToFuture()` with direct `await` on the JS-annotated `Future<dynamic>`.
* **[Web]** Fix `jsQR()` return type to `Code?` (nullable) to match actual JS behaviour
  where null is returned when no QR code is in frame.
* **[Dart]** Add `AppLifecycleState.hidden` case to `LifecycleEventHandler` to fix
  exhaustive switch warning on Flutter 3.13+.
  ([upstream PR #760](https://github.com/juliuscanute/qr_code_scanner/pull/760))

#### Android
* Bumped `compileSdk` 33 → 35.
  ([upstream PR #756](https://github.com/juliuscanute/qr_code_scanner/pull/756) /
  [#769](https://github.com/juliuscanute/qr_code_scanner/pull/769))
* Bumped `targetSdkVersion` 33 → 34.
* Bumped JVM target 11 → 17 (`jvmTarget`, `sourceCompatibility`, `targetCompatibility`).
  ([upstream PR #769](https://github.com/juliuscanute/qr_code_scanner/pull/769))
* Bumped `kotlin_version` 1.9.0 → 1.9.20.
  ([upstream PR #709](https://github.com/juliuscanute/qr_code_scanner/pull/709))
* Bumped Android Gradle Plugin 8.1.0 → 8.1.4.
  ([upstream PR #716](https://github.com/juliuscanute/qr_code_scanner/pull/716))
* Bumped Gradle wrapper 7.5.1 → 8.4.
  ([upstream PR #730](https://github.com/juliuscanute/qr_code_scanner/pull/730))
* Bumped `desugar_jdk_libs` 2.0.3 → 2.0.4.
  ([upstream PR #708](https://github.com/juliuscanute/qr_code_scanner/pull/708))
* Moved `namespace` declaration unconditionally to top of `android {}` block; removed
  `package` attribute from `AndroidManifest.xml` (required by AGP 8+).
  ([upstream PR #764](https://github.com/juliuscanute/qr_code_scanner/pull/764))
* Example app `compileSdk` bumped to 35; `minSdkVersion` uses `flutter.minSdkVersion`.

#### Dependencies
* Upgraded `js` package `^0.6.3` → `^0.7.1` for Dart 3 compatibility.
  ([upstream PR #739](https://github.com/juliuscanute/qr_code_scanner/pull/739) /
  [#749](https://github.com/juliuscanute/qr_code_scanner/pull/749))

#### CI
* Bumped `actions/checkout` v3 → v4.
  ([upstream PR #695](https://github.com/juliuscanute/qr_code_scanner/pull/695))
* Bumped `subosito/flutter-action` v2.10.0 → v2.12.0.
  ([upstream PR #711](https://github.com/juliuscanute/qr_code_scanner/pull/711))
* Updated CI Java version 11 → 17 to match plugin JVM target.

#### Chore
* Updated `.gitignore` (root and example): added `ios/Flutter/ephemeral/`,
  `key.properties`, `*.jks`, `Flutter.podspec`, `macOS` entries.
* Replaced deprecated `describeEnum()` calls in example with `.name` getter (Dart 3).

---

## 1.0.0
Breaking changes:
Minimum Flutter version is now Flutter 3.0.0 (Dart 2.17.0).

#### Features
* Inverted is now mixed with normal scanning.
* onPermissionSet now works on web aswell.
* [Android] zxing core is updated to 3.5.0.
* [Android] Several code improvements.
* [Android] Several dependencies updated.

## 0.7.0
#### Features
* Add inverted feature for Android. See https://github.com/juliuscanute/qr_code_scanner/issues/403

#### Bugfixes
* Fixed permission error on devices running Android 7 or lower.
* Fixed error being thrown when user declines permission on iOS.
* Updated dependencies

## 0.6.1
* Fix bug which caused build to fail for iOS. (#452)

## 0.6.0
#### Features
* Add support for raw bytes on iOS. (#421)
* Add custom cutout width and height next to cutout size. (#432)

#### Bugfixes
* Fix for calling permission multiple times. (#381)
* Fix for QRView Overlay cutoutbottomoffset. (#383)
* Multiple minor improvements

## 0.5.2
#### Bugfixes
* Increased delay to fix QRView opening zoomed in on some devices by adding small delay to updateDimensions(). (#250)
* Updated ZXING from 3.3.0 to 3.4.1 (#369)
* Fixed permission not being called correctly on Android (#351)

## 0.5.1
Removed web from library export.

## 0.5.0
* Added initial web-support. This function is still under development and not fully tested.
* Fixed permissions on iOS.
* Updated dependencies.

## 0.4.0
Stable null-safety support. (#278)

## 0.3.5
#### Bug fixes
* Fixed QRView opening zoomed in on some devices by adding small delay to updateDimensions(). (#250)
* Changed upc-A to EAN13 on iOS. (#262)
* Fixed null-pointer on BarcodeFormat array on iOS. (#262)
* Added LifecycleEventHandler to dispose(). (#265)

## 0.3.4
#### Bug fixes
* Fixed No barcode view found on Android when calling controller.dispose() (#257)
* Fixed Hot reload not working on Android.

## 0.3.3
#### Bug fixes
* Fixed updateDimensions not being called causing zoom on iOS. (#250)
* Fixed Android permission callback not working. (#251) (#252)
* Fixed null-pointers after declining permission on Android.

## 0.3.2
#### Bug fixes
* Fixed null-pointer when no overlay provided on iOS. (#245)
* Fixed camera not stopping (green dot on iOS 14) when navigating to other page. (#240)

## 0.3.1
#### Bug fixes
* Fixed permission callback on iOS & Android.
* Fixed camera facing not working on Android.
* Fixed scanArea not being honored on Android.
* Updated ShapeBorder to QrScannerOverlayShape.

## 0.3.0
#### Breaking change
Its not necessary anymore to wrap the QRView in a SizeChangedLayoutNotifier because this is handled inside the plugin.
#### New Features
* Added possibility to set allowed barcodes. (#135)
* Added possibility to check what features are supported by device. (hasFlash, hasBackCamera, hasFrontCamera) (#135)
* Added possibility to check if flash is on. (#135)
* Added possibility to check which camera is active. (#135)
* All functions are now async so you can await them. (#135)

See the updated example on how to implement these features.
#### Bug fixes
* Fixed permission handling in Android.
* Native functions now returns results so exceptions can be thrown when an error occurs.

## 0.2.1
* Fixed critical bug where scanner wouldn't open when no scan overlay was configured.

## 0.2.0
#### Breaking change
* The plugin now returns Barcode object instead of QR String. This object includes the type of code, the code itself and on Android devices the raw bytes. (#63)
#### New Features
* Added possibility to provide scanArea on iOS. (#165)
#### Bug fixes
* Fixed preview going black after hot reload. (#76)
* Fixed nullpointer when plugin binding order isn't correct. (#181)
* Fixed permission being asked on startup (#185)

## 0.1.0
* Changed Android minSDKversion from 24 to 21 (#170)
* Fix preview size after iPad rotation (#125)
* Implemented Android Embedding V2 (#132)
* Added cutout bottom offset (#115)
* Fix Android ActivityLifecycleCallbacks (#166)
* Fix some other small bugs

## 0.0.14
* Fix disposing camera on iOS 14 (#113)

## 0.0.13
* Fix misalignment when QRView doesn't start from the top left (#45)
* Fix crash on iOS when scanning returns nil (#69, #72)
* Fix ArithmeticException on Android (#43)

## 0.0.12
* Add optional parameter to use a camera overlay.
* Simplify controller, expose scanDataStream.
* Fix for Android flash toggle.
* Add ability to pause/resume the camera.
* Thanks! to Luis Thein for all the above contributions.

## 0.0.11
* android build break fix

## 0.0.10
* update README.md

## 0.0.9
* update README.md

## 0.0.8
* migrated Android project to androidx (by Felipe César)
* migrated iOS to Swift 5 (by Felipe César)

## 0.0.7
* flash light support added

## 0.0.6
* camera flip added

## 0.0.5
* preview stretching after change screen orientation fix

## 0.0.4
* fix black screen orientation/unlock/focus

## 0.0.3
* iOS library reference fix
* Android pause/resume fix

## 0.0.2
* Added documentation to cover how to use the plugin.

## 0.0.1
* QR Code scanner embedded inside flutter.
