//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if os(macOS)
  import SwiftUI
  import AppKit

  // MARK: - Window Tape (macOS)

  /// An invisible NSViewRepresentable that applies `sharingType = .none` while it
  /// is attached to a host window.
  ///
  /// `NSWindow.sharingType = .none` is the macOS equivalent of iOS's secure text
  /// field trick. It instructs the Window Server to omit the window from:
  /// - ⌘⇧3 / ⌘⇧4 screenshots
  /// - QuickTime screen recordings
  /// - Screen sharing sessions (Zoom, Teams, Webex, Remote Desktop, etc.)
  /// - AirPlay and HDMI display mirroring
  ///
  /// Because this property applies at the **window** level -- not the view level --
  /// setting it on any one view protects the entire window. Developers should be
  /// aware that all content in the same NSWindow will be hidden from captures while
  /// any view in it applies `maskingTape()`.
  struct WindowTapeView: NSViewRepresentable {
    func makeNSView(context: Context) -> TapeNSView { TapeNSView() }
    func updateNSView(_ nsView: TapeNSView, context: Context) {}
  }

  // MARK: - WindowTapeRegistry

  @MainActor
  final class WindowTapeRegistry {
    static let shared = WindowTapeRegistry()

    private struct Entry {
      weak var window: NSWindow?
      let originalSharingType: NSWindow.SharingType
      var count: Int
    }

    private var entries: [ObjectIdentifier: Entry] = [:]

    private init() {}

    func attach(_ window: NSWindow) {
      let id = ObjectIdentifier(window)

      if var entry = entries[id], entry.window === window {
        entry.count += 1
        entries[id] = entry
      } else {
        entries[id] = Entry(
          window: window,
          originalSharingType: window.sharingType,
          count: 1
        )
      }

      window.sharingType = .none
    }

    func detach(_ window: NSWindow) {
      let id = ObjectIdentifier(window)
      guard var entry = entries[id], entry.window === window else { return }

      entry.count -= 1

      if entry.count > 0 {
        entries[id] = entry
      } else {
        window.sharingType = entry.originalSharingType
        entries[id] = nil
      }
    }

    #if DEBUG
      func attachmentCount(for window: NSWindow) -> Int {
        entries[ObjectIdentifier(window)]?.count ?? 0
      }
    #endif
  }

  // MARK: - TapeNSView

  /// A zero-size NSView whose sole job is to apply masking tape to the host window.
  final class TapeNSView: NSView {
    private weak var protectedWindow: NSWindow?

    override func viewWillMove(toWindow newWindow: NSWindow?) {
      if let protectedWindow, protectedWindow !== newWindow {
        WindowTapeRegistry.shared.detach(protectedWindow)
        self.protectedWindow = nil
      }

      super.viewWillMove(toWindow: newWindow)
    }

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()

      guard let window, protectedWindow !== window else { return }

      WindowTapeRegistry.shared.attach(window)
      protectedWindow = window
    }

  }
#endif
