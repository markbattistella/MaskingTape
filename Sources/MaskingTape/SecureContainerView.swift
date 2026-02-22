//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

#if os(iOS)
import SwiftUI
import UIKit

// MARK: - Capture-Protected Primitive

/// Internal primitive used by `MaskingTapeView` / `.maskingTape(...)`.
///
/// Content hosted inside the private secure container is visible in the live app
/// and omitted from screenshots/recordings. The `overlay` is hosted in a normal
/// container behind it so captured output reveals the overlay instead.
///
/// - Note: This relies on UIKit's private secure text field view hierarchy.
struct CaptureProtectedView<Content: View, Overlay: View>: UIViewRepresentable {

  // MARK: Coordinator

  /// Holds strong references to the UIHostingControllers so SwiftUI state and
  /// environment flow through correctly after the views are reparented.
  @MainActor
  final class Coordinator {
    var contentController: UIHostingController<AnyView>?
    var overlayController: UIHostingController<AnyView>?
  }

  // MARK: Properties

  private let content: () -> Content
  private let overlay: (() -> Overlay)?

  // MARK: Init

  init(
    @ViewBuilder content: @escaping () -> Content,
    overlay: (() -> Overlay)?
  ) {
    self.content = content
    self.overlay = overlay
  }

  // MARK: UIViewRepresentable

  func makeCoordinator() -> Coordinator { Coordinator() }

  func makeUIView(context: Context) -> UIView {

    // 1. Build a secure text field – this establishes the protected rendering
    //    context. The order matters: set isSecureTextEntry BEFORE reading subviews.
    let secureField = UITextField()
    secureField.isSecureTextEntry = true
    secureField.isUserInteractionEnabled = false

    // 2. Extract the internal secure layer. If it doesn't exist (API changed)
    //    fall back to a plain, unprotected hosting view.
    guard let secureLayer = secureContainer(from: secureField) else {
      return makeFallbackView(coordinator: context.coordinator)
    }

    // 3. Detach from the text field so we can place it freely, then clear any
    //    existing internal subviews.
    secureLayer.removeFromSuperview()
    secureLayer.subviews.forEach { $0.removeFromSuperview() }

    // 4. Host our protected content inside the secure layer.
    let contentHost = UIHostingController(rootView: AnyView(content()))
    contentHost.view.backgroundColor = .clear
    contentHost.view.translatesAutoresizingMaskIntoConstraints = false
    context.coordinator.contentController = contentHost

    secureLayer.addSubview(contentHost.view)
    NSLayoutConstraint.activate([
      contentHost.view.topAnchor.constraint(equalTo: secureLayer.topAnchor),
      contentHost.view.bottomAnchor.constraint(equalTo: secureLayer.bottomAnchor),
      contentHost.view.leadingAnchor.constraint(equalTo: secureLayer.leadingAnchor),
      contentHost.view.trailingAnchor.constraint(equalTo: secureLayer.trailingAnchor)
    ])

    // 5. If there is no capture overlay, return the bare secure layer.
    guard let overlay else { return secureLayer }

    // 6. Build the replacement host and create a container.
    //    Stack order: replacement (bottom) → secureLayer (top).
    //    Normal app usage: secureLayer is opaque and covers the replacement.
    //    Captured output: secureLayer is excluded; replacement is visible.
    let overlayHost = UIHostingController(rootView: AnyView(overlay()))
    overlayHost.view.backgroundColor = .clear
    overlayHost.view.translatesAutoresizingMaskIntoConstraints = false
    context.coordinator.overlayController = overlayHost

    secureLayer.translatesAutoresizingMaskIntoConstraints = false

    let container = UIView()
    container.backgroundColor = .clear
    container.addSubview(overlayHost.view)
    container.addSubview(secureLayer)

    NSLayoutConstraint.activate([
      overlayHost.view.topAnchor.constraint(equalTo: container.topAnchor),
      overlayHost.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      overlayHost.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      overlayHost.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),

      secureLayer.topAnchor.constraint(equalTo: container.topAnchor),
      secureLayer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      secureLayer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      secureLayer.trailingAnchor.constraint(equalTo: container.trailingAnchor)
    ])

    return container
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    context.coordinator.contentController?.rootView = AnyView(content())
    if let overlay {
      context.coordinator.overlayController?.rootView = AnyView(overlay())
    }
  }

  func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: UIView,
    context: Context
  ) -> CGSize? {
    guard let controller = context.coordinator.contentController else { return nil }

    // `List` and other containers may ask for an estimate before width is known.
    // Returning `nil` here lets SwiftUI compute a sane fallback instead of using
    // an "expanded" width that can inflate aspect-ratio based content.
    guard proposal.width != nil || proposal.height != nil else { return nil }

    let size = CGSize(
      width: proposal.width ?? UIView.layoutFittingCompressedSize.width,
      height: proposal.height ?? UIView.layoutFittingCompressedSize.height
    )
    return controller.sizeThatFits(in: size)
  }

  // MARK: Private helpers

  private func makeFallbackView(coordinator: Coordinator) -> UIView {
    let host = UIHostingController(rootView: AnyView(content()))
    coordinator.contentController = host
    return host.view
  }

  private func secureContainer(from field: UITextField) -> UIView? {
    // Preferred extraction path used by many implementations.
    if let secureView = field.layer.sublayers?.first?.delegate as? UIView {
      return secureView
    }

    // Fallback if UIKit internals differ on a given iOS release.
    return field.subviews.first
  }
}

#endif
