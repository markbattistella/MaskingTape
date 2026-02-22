//
// Project: MaskingTapeExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import MaskingTape

/// Demonstrates reactive and always-visible watermark overlays.
struct WatermarkDemoView: View {

  // Live capture-state indicator for the demo.
  // ScreenWatermarkModifier tracks this internally for production use;
  // here we read it directly to drive the status row.
  @State private var isCapturing = false

  var body: some View {
    List {

      // MARK: - Live status row

      Section {
        Label(
          isCapturing
            ? "Screen is currently being captured"
            : "Screen is not being captured",
          systemImage: isCapturing ? "record.circle.fill" : "circle"
        )
        .foregroundStyle(isCapturing ? .red : .green)
        .animation(.default, value: isCapturing)
      } header: {
        Text("Capture State")
      }
      .task { @MainActor in
#if canImport(UIKit)
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
#else
        isCapturing = false
#endif
      }

      // MARK: - Reactive watermark

      Section {
        callout(
          icon: "camera",
          message: "Start a screen recording, then return here. The CONFIDENTIAL stamp will appear over the document."
        )

        DocumentView()
          .watermark {
            WatermarkStamp()
          }

      } header: {
        Text("Reactive Watermark")
      } footer: {
        Text(
          """
          .watermark { ... } observes UIScreen.capturedDidChangeNotification via \
          an async stream — no polling. The overlay appears the moment capture \
          starts and disappears the moment it stops.
          """
        )
      }

      // MARK: - Always-visible watermark

      Section {
        DocumentView()
          .overlay {
            WatermarkStamp()
          }

      } header: {
        Text("Always-Visible Watermark")
      } footer: {
        Text(
          """
          For a permanent watermark, use native SwiftUI `.overlay { ... }`.
          This keeps MaskingTape focused on capture-aware behavior.
          """
        )
      }

      // MARK: - Combined usage

      Section {
        callout(
          icon: "info.circle",
          message: "You can chain both behaviors: tape over sensitive content in captures and add a normal SwiftUI overlay to the replacement view."
        )

        DocumentView()
          .maskingTape {
            // This replacement is what appears in the capture output.
            // Watermark it too for belt-and-suspenders coverage.
            Color.secondary.opacity(0.1)
              .overlay {
                VStack(spacing: 8) {
                  Image(systemName: "lock.doc")
                    .font(.largeTitle)
                  Text("Protected document")
                    .font(.headline)
                }
                .foregroundStyle(.secondary)
              }
              .overlay {
                WatermarkStamp()
              }
          }

      } header: {
        Text("Combined Usage")
      }
    }
    .navigationTitle("Capture Watermark")
    .exampleLargeNavTitle()
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

#if canImport(UIKit)
@MainActor
/// Resolves the most relevant screen for capture-state checks in the demo app.
private func currentCaptureScreen() -> UIScreen? {
  let windowScenes = UIApplication.shared.connectedScenes.compactMap { scene in
    scene as? UIWindowScene
  }

  return windowScenes.first(where: { $0.activationState == .foregroundActive })?.screen
    ?? windowScenes.first(where: { $0.activationState == .foregroundInactive })?.screen
    ?? windowScenes.first?.screen
}
#endif

// MARK: - Supporting Views

/// Mock document content used for watermark demos.
private struct DocumentView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Image(systemName: "doc.text.fill")
          .foregroundStyle(.blue)
        Text("Confidential Report — Q4 2024")
          .font(.headline)
      }

      Divider()

      row(label: "Total Revenue", value: "$4,200,000")
      row(label: "Net Profit",    value: "$840,000")
      row(label: "Active Users",  value: "128,450")
      row(label: "Churn Rate",    value: "2.4 %")
      row(label: "NPS Score",     value: "72")
    }
    .padding()
    .background(.quaternary, in: .rect(cornerRadius: 12))
    .clipped()
  }

  @ViewBuilder
  private func row(label: String, value: String) -> some View {
    HStack {
      Text(label)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .fontWeight(.medium)
        .fontDesign(.monospaced)
    }
    .font(.subheadline)
  }
}

/// Reusable diagonal watermark stamp used across demos.
private struct WatermarkStamp: View {
  var body: some View {
    Text("CONFIDENTIAL")
      .font(.title.bold())
      .foregroundStyle(.red.opacity(0.22))
      .rotationEffect(.degrees(-30))
      .allowsHitTesting(false)
  }
}

#Preview {
  NavigationStack {
    WatermarkDemoView()
  }
}
