//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

public extension View {

  // MARK: - Screen Shield

  /// Prevents this view from appearing in screenshots, screen recordings,
  /// screen sharing, and external display output.
  ///
  /// - On **iOS / visionOS**: Embeds the view inside a UIKit secure text field
  ///   layer. The OS automatically excludes secure layers from all capture paths —
  ///   in-app screenshots, Control Center screen recording, QuickTime iPhone
  ///   mirroring, and AirPlay display mirroring.
  ///
  /// - On **macOS**: Sets the window's `sharingType` to `.none`, which prevents
  ///   the entire window from appearing in screenshots (⌘⇧3/4), screen
  ///   recordings, screen-sharing sessions (Zoom, Teams, etc.), and HDMI / AirPlay
  ///   display output. Because this operates at the window level, all content in
  ///   the same window is protected once any view applies this modifier.
  ///
  /// ```swift
  /// TextField("CVV", text: $cvv)
  ///     .screenShield()
  /// ```
  func screenShield() -> some View {
    modifier(ScreenShieldModifier<EmptyView>(replacement: nil))
  }

  /// Prevents this view from appearing in screenshots, screen recordings,
  /// screen sharing, and external display output, showing a replacement view
  /// in captured output instead.
  ///
  /// On **iOS**, the replacement is layered beneath the protected content in the
  /// live UI (hidden by the opaque secure layer). When capture is attempted the
  /// secure layer is excluded from the output, revealing the replacement view.
  ///
  /// On **macOS** the replacement is not used; the whole window is protected
  /// via `NSWindow.sharingType = .none`.
  ///
  /// ```swift
  /// BankingView()
  ///     .screenShield {
  ///         Label("Content protected", systemImage: "lock.fill")
  ///             .foregroundStyle(.secondary)
  ///     }
  /// ```
  ///
  /// - Parameter replacement: The view shown in captured output on iOS.
  func screenShield<Replacement: View>(
    @ViewBuilder replacement: @escaping () -> Replacement
  ) -> some View {
    modifier(ScreenShieldModifier(replacement: replacement))
  }

  // MARK: - Screen Watermark

  /// Overlays a watermark view on this content when screen capture is detected.
  ///
  /// Unlike `screenShield()` this does **not** block capture — it overlays the
  /// provided view on top of content during screenshots and screen recordings.
  ///
  /// **Platform notes:**
  /// - **iOS**: The watermark appears automatically when `UIScreen.isCaptured`
  ///   becomes `true` (screenshots, Control Center recording, QuickTime, AirPlay).
  /// - **macOS**: macOS has no public API to detect capture state without
  ///   requesting screen recording permission. Set `alwaysVisible: true` for a
  ///   permanent branding watermark on macOS.
  ///
  /// ```swift
  /// DocumentView()
  ///     .screenWatermark {
  ///         Text("CONFIDENTIAL")
  ///             .font(.largeTitle.bold())
  ///             .foregroundStyle(.red.opacity(0.25))
  ///             .rotationEffect(.degrees(-30))
  ///     }
  /// ```
  ///
  /// - Parameters:
  ///   - alwaysVisible: When `true` the watermark shows regardless of capture
  ///     state. Defaults to `false`.
  ///   - overlay: The watermark view to display.
  func screenWatermark<Watermark: View>(
    alwaysVisible: Bool = false,
    @ViewBuilder overlay: @escaping () -> Watermark
  ) -> some View {
    modifier(ScreenWatermarkModifier(alwaysVisible: alwaysVisible, overlay: overlay))
  }
}
