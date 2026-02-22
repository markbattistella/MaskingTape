//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if os(macOS)
import SwiftUI
import AppKit

// MARK: - Window Shield (macOS)

/// An invisible NSViewRepresentable that sets `sharingType = .none` on its host
/// window the moment it enters the view hierarchy.
///
/// `NSWindow.sharingType = .none` is the macOS equivalent of iOS's secure text
/// field trick. It instructs the Window Server to omit the window from:
/// - ⌘⇧3 / ⌘⇧4 screenshots
/// - QuickTime screen recordings
/// - Screen sharing sessions (Zoom, Teams, Webex, Remote Desktop, etc.)
/// - AirPlay and HDMI display mirroring
///
/// Because this property applies at the **window** level — not the view level —
/// setting it on any one view protects the entire window. Developers should be
/// aware that all content in the same NSWindow will be hidden from captures once
/// any view in it applies `screenShield()`.
struct WindowShieldView: NSViewRepresentable {
  func makeNSView(context: Context) -> ShieldNSView { ShieldNSView() }
  func updateNSView(_ nsView: ShieldNSView, context: Context) {}
}

// MARK: - ShieldNSView

/// A zero-size NSView whose sole job is to shield the window when it joins one.
final class ShieldNSView: NSView {
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    window?.sharingType = .none
  }
}
#endif
