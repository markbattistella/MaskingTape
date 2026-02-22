//
// Project: MaskingTapeExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// Demonstrates a viewport-sized watermark applied to an entire scrolling screen.
struct FullScreenWatermarkDemoView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        header(
          title: "Whole-Screen Watermark",
          subtitle: "Start a screen recording or mirroring session. The capture-reactive watermark is applied at the NavigationStack level, so it stays screen-sized while content scrolls underneath."
        )

        ForEach(1...20, id: \.self) { index in
          VStack(alignment: .leading, spacing: 10) {
            Text("Report Block \(index)")
              .font(.headline)

            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vulputate, erat et gravida volutpat, magna velit congue nisl, non tincidunt velit risus vel mauris."
            )
            .foregroundStyle(.secondary)

            HStack {
              Label("\(Int.random(in: 5...99)) events", systemImage: "chart.line.uptrend.xyaxis")
              Spacer()
              Text("Updated just now")
                .foregroundStyle(.secondary)
            }
            .font(.caption)
          }
          .padding(16)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(.background, in: .rect(cornerRadius: 16))
        }
      }
      .padding()
    }
    .background(groupedBackgroundColor)
    .navigationTitle("Full-Screen Watermark")
    .exampleInlineNavTitle()
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

  private var groupedBackgroundColor: Color {
#if os(macOS)
    Color(nsColor: .windowBackgroundColor)
#else
    Color(uiColor: .systemGroupedBackground)
#endif
  }
}

/// Repeated watermark grid used by the full-screen watermark demo tab.
struct FullScreenWatermarkOverlay: View {
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)

  var body: some View {
    GeometryReader { proxy in
      LazyVGrid(columns: columns, spacing: 22) {
        ForEach(0..<12, id: \.self) { _ in
          Text("MASKINGTAPE")
            .font(.headline.weight(.black))
            .foregroundStyle(.orange.opacity(0.16))
            .rotationEffect(.degrees(-22))
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
    }
    .ignoresSafeArea()
  }
}
