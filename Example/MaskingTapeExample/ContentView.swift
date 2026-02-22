//
// Project: MaskingTapeExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import MaskingTape

/// Root tab view for the example app.
struct ContentView: View {
  var body: some View {
    TabView {
      NavigationStack {
        ShieldDemoView()
      }
      .tabItem {
        Label("Shield", systemImage: "lock.shield.fill")
      }

      NavigationStack {
        WatermarkDemoView()
      }
      .tabItem {
        Label("Watermark", systemImage: "pencil.tip.crop.circle")
      }

      NavigationStack {
        FullScreenShieldDemoView()
      }
      .screenShield {
        FullScreenMaskOverlay()
      }
      .tabItem {
        Label("Full Mask", systemImage: "rectangle.slash")
      }

      NavigationStack {
        FullScreenWatermarkDemoView()
      }
      .watermark {
        FullScreenWatermarkOverlay()
      }
      .tabItem {
        Label("Full Mark", systemImage: "drop.halffull")
      }

      NavigationStack {
        BottomInsetWatermarkDemoView()
      }
      .tabItem {
        Label("Inset Mark", systemImage: "arrow.down.to.line")
      }
    }
  }
}

#Preview {
  ContentView()
}
