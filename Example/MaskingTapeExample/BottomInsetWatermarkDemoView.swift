//
// Project: MaskingTapeExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import UIKit

/// Demonstrates a capture-reactive bottom inset watermark that compresses content while recording/mirroring.
struct BottomInsetWatermarkDemoView: View {
  @State private var isCapturing = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        header

        ForEach(1...22, id: \.self) { index in
          HStack(alignment: .top, spacing: 12) {
            Image(systemName: "doc.plaintext")
              .foregroundStyle(.blue)
              .font(.title3)
              .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
              Text("Document line item \(index)")
                .font(.headline)
              Text("When capture is active, this screen reserves space at the bottom and places the watermark in that padded inset.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
          }
          .padding(14)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(.background, in: .rect(cornerRadius: 14))
        }
      }
      .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
    .safeAreaInset(edge: .bottom, spacing: 0) {
      if isCapturing {
        CaptureInsetWatermarkBar()
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .animation(.spring(duration: 0.28), value: isCapturing)
    .task { @MainActor in
      if let screen = currentCaptureScreen() {
        isCapturing = screen.isCaptured
      }

      for await note in NotificationCenter.default.notifications(
        named: UIScreen.capturedDidChangeNotification
      ) {
        if let screen = note.object as? UIScreen {
          isCapturing = screen.isCaptured
        }
      }
    }
    .navigationTitle("Inset Watermark")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Bottom Inset Watermark")
        .font(.title2.bold())
      Text("Start a screen recording or mirroring session. The content area is compressed (bottom inset added) and the watermark sits in that padded area.")
        .foregroundStyle(.secondary)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.background, in: .rect(cornerRadius: 16))
  }
}

/// Bottom inset bar shown while screen capture is active.
private struct CaptureInsetWatermarkBar: View {
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "record.circle.fill")
        .foregroundStyle(.red)

      VStack(alignment: .leading, spacing: 2) {
        Text("SCREEN CAPTURE ACTIVE")
          .font(.caption2.weight(.black))
        Text("MASKINGTAPE • INTERNAL USE")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
      }

      Spacer()

      Text(timeStamp)
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity)
    .background(.ultraThinMaterial)
    .overlay(alignment: .top) {
      Divider()
    }
  }

  private var timeStamp: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    return formatter.string(from: .now)
  }
}

@MainActor
/// Resolves the active screen used for capture-state checks in the inset watermark demo.
private func currentCaptureScreen() -> UIScreen? {
  let windowScenes = UIApplication.shared.connectedScenes.compactMap { scene in
    scene as? UIWindowScene
  }

  return windowScenes.first(where: { $0.activationState == .foregroundActive })?.screen
    ?? windowScenes.first(where: { $0.activationState == .foregroundInactive })?.screen
    ?? windowScenes.first?.screen
}
