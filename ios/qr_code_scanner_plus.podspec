#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'qr_code_scanner_plus'
  s.version          = '1.1.0'
  s.summary          = 'A Flutter QR & barcode scanner plugin using native platform views.'
  s.description      = <<-DESC
A Flutter QR & barcode scanner plugin using ZXing on Android and a native AVFoundation
implementation on iOS. Fork of qr_code_scanner with Dart 3 / Flutter 3.x compatibility
fixes and Swift Package Manager support.
                       DESC
  s.homepage         = 'https://github.com/alamin-karno/qr_code_scanner_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'alamin-karno' => 'shadman.sakib@vivasoftltd.com' }
  s.source           = { :path => '.' }

  # Shared Swift sources used by both CocoaPods and Swift Package Manager.
  s.source_files     = 'Sources/qr_code_scanner_plus/**/*.swift'
  s.dependency 'Flutter'
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'
  end
end
