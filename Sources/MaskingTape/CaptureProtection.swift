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
public struct SecureView<Content: View>: View {

    private let content: () -> Content
    private let overlay: () -> AnyView

    /// Creates a secure view with the default capture replacement (`systemBackground` on iOS).
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.overlay = { AnyView(defaultSecureCaptureOverlay()) }
    }

    /// Creates a secure view with a custom overlay shown in captured output on iOS.
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
            .background(WindowShieldView())
#else
        content()
#endif
    }
}

/// A regular watermark wrapper that renders content and an overlay together.
///
/// - Note: A capture-only watermark cannot be implemented with the iOS secure text
/// field trick because secure-container content is omitted from captures.
public struct WatermarkView<Content: View, Overlay: View>: View {

    private let content: () -> Content
    private let overlay: () -> Overlay
    private let alignment: Alignment

    /// Creates a watermark wrapper that overlays `overlay` on top of `content`.
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
            .overlay(alignment: alignment) {
                overlay()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}

public extension View {
    
    /// Hides this view from screenshots and screen recordings on supported platforms.
    ///
    /// On iOS the default captured-output overlay is `systemBackground`.
    func secureCapture() -> some View {
        SecureView {
            self
        }
    }

    /// Hides this view from screenshots and screen recordings and shows a custom
    /// overlay in captured output on iOS.
    func secureCapture<Overlay: View>(
        @ViewBuilder _ overlay: @escaping () -> Overlay
    ) -> some View {
        SecureView(
            content: { self },
            overlay: overlay
        )
    }

    /// Composites a watermark overlay on top of this view.
    ///
    /// This is a standard overlay (visible in the live UI and in any captured
    /// output). For reactive, capture-state-driven overlays, use `screenWatermark`.
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
/// Default replacement used by `.secureCapture()` when no overlay is supplied.
private func defaultSecureCaptureOverlay() -> some View {
#if os(iOS)
    Color(uiColor: .systemBackground)
#else
    Color.clear
#endif
}
