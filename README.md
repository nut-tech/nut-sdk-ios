# nut-sdk-ios
nut SDK for iOS

## Current release: v1.5.1

- Ship a single `framwork/nutble.xcframework` (`ios-arm64` + `ios-arm64-simulator`) for local debugging and App Store submission. The simulator slice is arm64 only.
- The previous `framwork/Debug` / `framwork/Release` packages are removed. Embed & Sign the XCFramework; Archive keeps the device slice only.
- **Minimum OS is iOS 15.0** (was iOS 8 / demo 13). Apps must raise their deployment target to 15.0 or later before linking this package.
- Find My / Find Hub coexist device APIs, battery estimate, and Telink OTA headers are included in the public SDK.
- The demo uses a scene delegate so it launches on current iOS, links Nordic DFU (`iOSDFULibrary` / `ZIPFoundation`) only for device builds, and surfaces coexist-device limits in the detail screen.

See `doc/Nut iOS SDK 文档.docx` and `doc/Nut iOS SDK Document.docx` for the integration guide.

## Earlier versions

### v1.4.3
- Support to New DeviceName.

### v1.4.2
- Fix Read Battery.
- Fix Xcode12.5 build issue.

### v1.4.0
- Support to Beacon/DFU API.

### v1.2.0
- Support to Nut mini.
- Fix bugs.

### v1.0.0
- First release.
