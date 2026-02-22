<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# MaskingTape

![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FMaskingTape%2Fbadge%3Ftype%3Dswift-versions)

![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FMaskingTape%2Fbadge%3Ftype%3Dplatforms)

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

`MaskingTape` is a Swift package for capture protection and capture-aware watermarking in SwiftUI.

It provides:

- `secureCapture()` to hide sensitive views from screenshots/recordings/mirroring (platform dependent)
- `secureCapture { replacement }` to show replacement UI in captured output on iOS
- `watermark { overlay }` to show a watermark only while screen capture is active
- macOS window-level capture protection via `NSWindow.sharingType = .none`
- SwiftUI-first wrappers and modifiers with example patterns for full-screen usage

## Installation

Add `MaskingTape` to your Swift project using Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/markbattistella/MaskingTape", from: "1.0.0")
]
```

Alternatively, add it using Xcode via `File > Add Packages` and entering the package repository URL.

## How Capture Protection Works (iOS)

`MaskingTape` uses the `UITextField.isSecureTextEntry` rendering side-effect.
Content hosted inside the private secure container remains visible in the live app, but iOS omits it from screenshots, screen recordings, and mirroring capture pipelines.

When you provide a replacement overlay with `secureCapture { ... }`, that replacement is placed behind the secure content so it becomes visible in captured output.

## Quick Start

```swift
import MaskingTape
```

### Hide sensitive content in captures

```swift
Text("4111 1111 1111 1111")
  .secureCapture()
```

### Hide content and show replacement UI in captures

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

### Capture-reactive watermark (recording / mirroring)

```swift
DocumentView()
  .watermark {
    Text("CONFIDENTIAL")
      .font(.title.bold())
      .foregroundStyle(.red.opacity(0.22))
      .rotationEffect(.degrees(-30))
  }
```

### Always-visible watermark (use SwiftUI directly)

```swift
DocumentView()
  .overlay {
    Text("CONFIDENTIAL")
      .font(.title.bold())
      .foregroundStyle(.red.opacity(0.22))
      .rotationEffect(.degrees(-30))
  }
```

## Public API (Simplified)

### Capture Protection

- `.secureCapture()`
- `.secureCapture { replacement }`
- `SecureView { ... }`

### Capture-Reactive Watermark

- `.watermark { overlay }`
- `WatermarkView { ... }`

`watermark` is intentionally capture-aware only. If you want a watermark that is always visible, use SwiftUI's built-in `.overlay`.

## Full-Screen Usage (Scrolling Screens)

To keep protection/watermarking tied to the visible viewport while content scrolls, apply the modifier to the outer container (`NavigationStack`, `TabView`, etc.), not the inner `ScrollView` content:

```swift
NavigationStack {
  ScrollView {
    // content
  }
}
.secureCapture {
  Color(uiColor: .systemBackground)
}
```

```swift
NavigationStack {
  ScrollView {
    // content
  }
}
.watermark {
  Text("MASKINGTAPE")
}
```

## Platform Notes

- `iOS`: `secureCapture` uses the secure text-field container technique; `watermark` reacts to `UIScreen.isCaptured`
- `macOS`: `secureCapture` uses `NSWindow.sharingType = .none` (window-wide); capture state for reactive watermarking is not publicly available without extra permissions
- `tvOS`: secure masking is not applied; capture-reactive watermarking is available
- `watchOS`: watermark APIs fall back to always-hidden-unless-explicit behavior (no capture-state concept)
- `visionOS`: secure masking behavior is unverified and currently treated conservatively

## Important Limitations

- iOS does not provide a public "will screenshot" callback
- `UIApplication.userDidTakeScreenshotNotification` fires after the screenshot is already captured
- You cannot insert a watermark into a system screenshot after the capture has occurred
- The iOS secure masking technique depends on UIKit internals and may break if Apple changes the private view hierarchy

## Legacy Compatibility APIs

These remain available for migration but are deprecated:

- `.screenShield()` -> use `.secureCapture()`
- `.screenShield { ... }` -> use `.secureCapture { ... }`
- `.screenWatermark(...)` -> use `.watermark { ... }` (capture-only) or SwiftUI `.overlay { ... }` (always visible)

## Example App

The included example demonstrates:

- `secureCapture()` on individual views
- `secureCapture { replacement }` with custom capture replacement content
- Capture-reactive `.watermark { ... }`
- Full-screen masking and full-screen watermarking on scrolling screens
- A bottom inset watermark pattern for active recording / mirroring sessions

## Contributing

Contributions are welcome. Please open an Issue or PR for fixes, feature proposals, or documentation improvements.

PR titles should follow the format: `YYYY-mm-dd - Title`

## Licence

`MaskingTape` is released under the MIT licence.
