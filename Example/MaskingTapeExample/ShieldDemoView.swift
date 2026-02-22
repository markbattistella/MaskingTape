//
// Project: MaskingTapeExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import MaskingTape

/// Demonstrates view-level capture shielding with and without a replacement view.
struct ShieldDemoView: View {
  var body: some View {
    List {

      // MARK: - Basic shield

      Section {
        callout(
          icon: "camera",
          message: "Take a screenshot or start a screen recording — this card will appear blank."
        )

        CardView()
          .screenShield()

      } header: {
        Text("Basic Shield")
      } footer: {
        Text(
          """
          .screenShield() embeds the view inside a UIKit secure text field layer. \
          iOS automatically excludes that layer from screenshots, Control Centre \
          recordings, QuickTime mirroring, and AirPlay output.
          """
        )
      }

      // MARK: - Shield with replacement

      Section {
        callout(
          icon: "camera",
          message: "Screenshot or record — a lock message appears instead of the card."
        )

        CardView()
          .screenShield {
            HStack(spacing: 12) {
              Image(systemName: "lock.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
              VStack(alignment: .leading) {
                Text("Content protected")
                  .font(.headline)
                Text("This view is hidden from capture")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
            .background(.quaternary, in: .rect(cornerRadius: 16))
          }

      } header: {
        Text("Shield with Replacement")
      } footer: {
        Text(
          """
          The replacement view sits behind the secure layer in the live UI \
          (covered by the opaque shield). When captured, the secure layer is \
          excluded from the output and the replacement is revealed instead.
          """
        )
      }

      // MARK: - Stacking note

      Section {
        callout(
          icon: "exclamationmark.triangle",
          message: "On macOS, screenShield() sets the entire window's sharing type — all content in the window is protected, not just the modified view."
        )
      } header: {
        Text("macOS Note")
      }
    }
    .navigationTitle("screenShield()")
    .navigationBarTitleDisplayMode(.large)
  }

  // MARK: - Helpers

  @ViewBuilder
  private func callout(icon: String, message: String) -> some View {
    Label(message, systemImage: icon)
      .font(.callout)
      .foregroundStyle(.secondary)
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets())
      .padding(.vertical, 4)
  }
}

// MARK: - Demo Card

/// Mock payment card used to demonstrate capture protection.
private struct CardView: View {
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      RoundedRectangle(cornerRadius: 16)
        .fill(
          LinearGradient(
            colors: [.blue, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .aspectRatio(1.586, contentMode: .fill)   // standard card ratio

      VStack(alignment: .leading, spacing: 6) {
        Spacer()

        // Chip icon placeholder
        RoundedRectangle(cornerRadius: 4)
          .fill(.yellow.opacity(0.8))
          .frame(width: 36, height: 28)

        Text("4111  1111  1111  1111")
          .font(.title3.monospaced().bold())
          .foregroundStyle(.white)
          .tracking(1)

        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text("CARDHOLDER")
              .font(.system(size: 9))
              .foregroundStyle(.white.opacity(0.6))
            Text("MARK BATTISTELLA")
              .font(.caption.bold())
              .foregroundStyle(.white)
          }

          Spacer()

          VStack(alignment: .trailing, spacing: 2) {
            Text("EXPIRES")
              .font(.system(size: 9))
              .foregroundStyle(.white.opacity(0.6))
            Text("12/27")
              .font(.caption.bold())
              .foregroundStyle(.white)
          }
        }
      }
      .padding(20)
    }
  }
}

#Preview {
  NavigationStack {
    ShieldDemoView()
  }
}
