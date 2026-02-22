//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// Internal ViewModifier that routes to the appropriate platform implementation.
struct ScreenShieldModifier<Replacement: View>: ViewModifier {

  /// Optional view to reveal in captured output (iOS only).
  let replacement: (() -> Replacement)?

  @ViewBuilder
  func body(content: Content) -> some View {
    #if os(iOS)
    // iOS: UITextField isSecureTextEntry trick — the OS excludes the secure
    // sublayer from all capture paths (screenshots, recordings, mirroring).
    CaptureProtectedView(
      content: { content },
      overlay: replacement
    )
    #elseif os(macOS)
    // macOS: window-level protection. WindowShieldView sets sharingType = .none
    // on the host NSWindow, excluding it from all capture consumers.
    content
      .background(WindowShieldView())
    #else
    // tvOS: UITextField internal layout differs; the secure-layer trick is
    //        unreliable. Pass through — use watermark() instead.
    // watchOS: No screenshots exist on Apple Watch. Pass through.
    // visionOS: Spatial captures work differently. Pass through.
    content
    #endif
  }
}
