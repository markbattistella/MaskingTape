//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Public Capture Protection API

/// Hides wrapped content from screen captures on supported platforms.
///
/// On iOS this uses the secure text-field container trick internally. The
/// optional overlay is what appears in captured output.
public struct MaskingTapeView<Content: View>: View {

    private let content: () -> Content
    private let overlay: () -> AnyView

    /// Creates a masking-tape view with the default capture replacement (`systemBackground` on iOS).
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.overlay = { AnyView(defaultSecureCaptureOverlay()) }
    }

    /// Creates a masking-tape view with custom "tape" shown in captured output on iOS.
    public init<Overlay: View>(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) {
        self.content = content
        self.overlay = { AnyView(overlay()) }
    }

    public var body: some View {
#if os(iOS)
        CaptureProtectedView(content: content, overlay: overlay)
#elseif os(macOS)
        // macOS capture protection is window-wide; overlay is ignored.
        content()
            .background(WindowTapeView())
#else
        content()
#endif
    }
}

/// A capture-reactive watermark wrapper.
///
/// The overlay is shown only while screen capture is active (for example screen
/// recording or mirroring on iOS/tvOS). For always-visible overlays, use SwiftUI's
/// native `.overlay`.
public struct WatermarkView<Content: View, Overlay: View>: View {

    private let content: () -> Content
    private let overlay: () -> Overlay
    private let alignment: Alignment

    /// Creates a capture-reactive watermark wrapper.
    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) {
        self.alignment = alignment
        self.content = content
        self.overlay = overlay
    }

    public var body: some View {
        content()
            .modifier(
                ScreenWatermarkModifier(
                    alwaysVisible: false,
                    alignment: alignment,
                    overlay: overlay
                )
            )
    }
}

public extension View {
    
    /// Applies masking tape to this view for screen captures.
    ///
    /// On iOS the default captured-output overlay is `systemBackground`.
    func maskingTape() -> some View {
        MaskingTapeView {
            self
        }
    }

    /// Applies masking tape to this view and shows a custom replacement in captured output on iOS.
    func maskingTape<Overlay: View>(
        @ViewBuilder _ overlay: @escaping () -> Overlay
    ) -> some View {
        MaskingTapeView(
            content: { self },
            overlay: overlay
        )
    }

    /// Overlays a watermark only while screen capture is active.
    ///
    /// For always-visible overlays, use SwiftUI's `.overlay`.
    func watermark<Overlay: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ overlay: @escaping () -> Overlay
    ) -> some View {
        WatermarkView(
            alignment: alignment,
            content: { self },
            overlay: overlay
        )
    }
}

// MARK: - Helpers

@ViewBuilder
/// Default "tape" used by `.maskingTape()` when no replacement is supplied.
private func defaultSecureCaptureOverlay() -> some View {
#if os(iOS)
    Color(uiColor: .systemBackground)
#else
    Color.clear
#endif
}
