import SwiftUI

/// Example-only compatibility helpers for navigation title display modes.
extension View {
  @ViewBuilder
  func exampleInlineNavTitle() -> some View {
#if os(macOS)
    self
#else
    self.navigationBarTitleDisplayMode(.inline)
#endif
  }

  @ViewBuilder
  func exampleLargeNavTitle() -> some View {
#if os(macOS)
    self
#else
    self.navigationBarTitleDisplayMode(.large)
#endif
  }
}
