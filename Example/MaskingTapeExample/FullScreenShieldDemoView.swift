//
// Project: MaskingTapeExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// Demonstrates screen-sized capture masking while scroll content moves underneath.
struct FullScreenShieldDemoView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        header(
          title: "Whole-Screen Mask",
          subtitle: "This tab applies .secureCapture() at the NavigationStack level, so captured output is masked for the visible viewport even while scrolling."
        )

        ForEach(1...18, id: \.self) { index in
          RoundedRectangle(cornerRadius: 20)
            .fill(
              LinearGradient(
                colors: index.isMultiple(of: 2)
                  ? [.mint.opacity(0.9), .teal.opacity(0.8)]
                  : [.indigo.opacity(0.9), .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .overlay(alignment: .leading) {
              VStack(alignment: .leading, spacing: 6) {
                Text("Sensitive section \(index)")
                  .font(.headline)
                  .foregroundStyle(.white)
                Text("Scroll anywhere in this screen — the capture mask stays tied to the viewport, not the scroll content.")
                  .font(.subheadline)
                  .foregroundStyle(.white.opacity(0.9))
              }
              .padding(16)
            }
            .frame(height: 140)
        }
      }
      .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
    .navigationTitle("Full-Screen Mask")
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  private func header(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.title2.bold())
      Text(subtitle)
        .foregroundStyle(.secondary)
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.background, in: .rect(cornerRadius: 16))
  }
}

/// Capture replacement overlay shown when the full-screen shield is captured on iOS.
struct FullScreenMaskOverlay: View {
  var body: some View {
    ZStack {
      Color(uiColor: .systemBackground)
        .ignoresSafeArea()

      VStack(spacing: 12) {
        Image(systemName: "lock.shield.fill")
          .font(.system(size: 42))
          .foregroundStyle(.secondary)
        Text("Capture Protected")
          .font(.headline)
        Text("This entire screen is hidden in screenshots and recordings.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      .padding(24)
      .background(.quaternary, in: .rect(cornerRadius: 20))
      .padding(24)
    }
  }
}
