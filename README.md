<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# MaskingTape

![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FMaskingTape%2Fbadge%3Ftype%3Dswift-versions)

![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FMaskingTape%2Fbadge%3Ftype%3Dplatforms)

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

`MaskingTape` is a Swift package for capture protection and watermarking in SwiftUI.

It provides:

- Secure capture masking for sensitive UI on iOS (screenshots, screen recordings, mirroring)
- Window-level capture protection on macOS via `NSWindow.sharingType = .none`
- Watermark overlays for full-screen or view-level branding
- SwiftUI-first wrappers and modifiers for drop-in usage
- Example patterns for full-screen masking and capture-reactive inset watermarks

## How It Works (iOS)

`MaskingTape` uses the well-known `UITextField.isSecureTextEntry` rendering side-effect.
Content rendered inside the private secure container is visible in the live app but omitted from the system capture pipeline.

That means:

- Put sensitive content inside the secure container -> hidden from captures
- Put a replacement overlay behind it -> replacement appears in the captured image/video

## Installation

Add `MaskingTape` to your Swift project using Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/markbattistella/MaskingTape", from: "1.0.0")
]
```

Alternatively, add it using Xcode via `File > Add Packages` and entering the package repository URL.

## Quick Start

Import the package:

```swift
import MaskingTape
```

### Hide sensitive content in captures

```swift
Text("4111 1111 1111 1111")
  .secureCapture()
```

### Hide content and show a custom replacement in captures

```swift
CardView()
  .secureCapture {
    VStack(spacing: 8) {
      Image(systemName: "lock.fill")
      Text("Protected")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.background)
  }
```

### Add a watermark overlay

```swift
DocumentView()
  .watermark {
    Text("CONFIDENTIAL")
      .font(.title.bold())
      .foregroundStyle(.red.opacity(0.2))
      .rotationEffect(.degrees(-30))
  }
```

## Public API

### Wrappers

- `SecureView` -> hides content from capture (optional captured-output overlay on iOS)
- `WatermarkView` -> overlays visible watermark content

### Modifiers

- `.secureCapture()`
- `.secureCapture { overlay }`
- `.watermark { overlay }`

### Compatibility Modifiers (existing API)

- `.screenShield()`
- `.screenShield { replacement }`
- `.screenWatermark(alwaysVisible:overlay:)`

`screenShield` is the existing capture-protection API and now uses the same internal secure primitive.

## Full-Screen Patterns

To ensure protection or watermarking applies to the visible screen while content scrolls, apply the modifier to a container like `NavigationStack`, not the inner `ScrollView` content:

```swift
NavigationStack {
  ScrollView { /* content */ }
}
.screenShield {
  Color(uiColor: .systemBackground)
}
```

or:

```swift
NavigationStack {
  ScrollView { /* content */ }
}
.watermark {
  Text("MASKINGTAPE")
}
```

## Capture-Reactive Watermarks

`screenWatermark` observes `UIScreen.capturedDidChangeNotification` on iOS/tvOS and shows an overlay when screen capture is active (recording/mirroring).

```swift
DocumentView()
  .screenWatermark {
    Text("RECORDED")
      .foregroundStyle(.red.opacity(0.2))
  }
```

## Platform Notes

- `iOS`: Secure capture masking supported using the secure text field container technique
- `macOS`: Uses `NSWindow.sharingType = .none` (window-wide protection)
- `tvOS`: Secure masking is not applied (UIKit internals differ); watermarking is available
- `watchOS`: No screenshot-protection equivalent; watermarking APIs fall back to normal overlays
- `visionOS`: Pass-through / unverified for secure masking behavior

## Important Limitations

- iOS does **not** provide a public API to intercept a screenshot before capture
- `UIApplication.userDidTakeScreenshotNotification` fires **after** the screenshot is already taken
- You cannot inject a watermark into the system screenshot at capture time after the fact
- The iOS secure masking technique depends on private UIKit view hierarchy behavior and could change in a future OS release

## Example App

The included example demonstrates:

- View-level shielding (`screenShield`)
- Reactive and always-on watermarks (`screenWatermark`)
- Full-screen mask and full-screen watermark tabs
- A bottom inset watermark pattern for active screen recording / mirroring

## Contributing

Contributions are welcome. Please open an Issue or PR for fixes, feature proposals, or documentation improvements.

PR titles should follow the format: `YYYY-mm-dd - Title`

## Licence

`MaskingTape` is released under the MIT licence.
