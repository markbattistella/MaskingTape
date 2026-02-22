//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
#if os(iOS) || os(tvOS)
import UIKit
#endif

// MARK: - Watermark Modifier

/// Internal ViewModifier that overlays a watermark during screen capture.
///
/// **iOS / tvOS** — observes `UIScreen.capturedDidChangeNotification` via an
/// async stream so the overlay appears and disappears reactively without polling.
/// The `.task` lifetime is tied to the view; the stream is cancelled automatically
/// when the view leaves the hierarchy.
///
/// **macOS** — no public API exists to detect capture state without prompting the
/// user for screen recording permission. Only `alwaysVisible: true` is supported.
///
/// **watchOS / visionOS** — no screenshot / capture concept applies. Only
/// `alwaysVisible: true` is supported (e.g. for permanent branding overlays).
struct ScreenWatermarkModifier<Watermark: View>: ViewModifier {

  let alwaysVisible: Bool
  let alignment: Alignment
  let overlay: () -> Watermark

  // UIScreen.isCaptured is available on iOS 11+ and tvOS 11+.
  #if os(iOS) || os(tvOS)
  @State private var isCaptured = false
  #endif

  @ViewBuilder
  func body(content: Content) -> some View {
    #if os(iOS) || os(tvOS)
    content
      .overlay(alignment: alignment) {
        if alwaysVisible || isCaptured {
          overlay()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
      }
      .task { @MainActor in
        // Seed the initial capture state.
        if let screen = currentCaptureScreen() {
          isCaptured = screen.isCaptured
        }

        // Stream future changes. The notification object is the affected UIScreen.
        for await notification in NotificationCenter.default.notifications(
          named: UIScreen.capturedDidChangeNotification
        ) {
          if let screen = notification.object as? UIScreen {
            isCaptured = screen.isCaptured
          }
        }
      }

    #else
    // macOS: capture state is undetectable without screen recording permission.
    // watchOS: no capture concept.
    // visionOS: spatial captures work differently.
    // All three fall back to alwaysVisible-only behaviour.
    content
      .overlay(alignment: alignment) {
        if alwaysVisible {
          overlay()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
      }
    #endif
  }
}

#if os(iOS) || os(tvOS)
@MainActor
/// Resolves the most relevant screen for querying `isCaptured` across scenes.
private func currentCaptureScreen() -> UIScreen? {
  #if os(iOS)
  let windowScenes = UIApplication.shared.connectedScenes.compactMap { scene in
    scene as? UIWindowScene
  }

  return windowScenes.first(where: { $0.activationState == .foregroundActive })?.screen
    ?? windowScenes.first(where: { $0.activationState == .foregroundInactive })?.screen
    ?? windowScenes.first?.screen
  #else
  return UIScreen.main
  #endif
}
#endif
