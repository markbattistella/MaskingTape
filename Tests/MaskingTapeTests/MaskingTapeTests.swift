//
// Project: MaskingTape
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Testing
import SwiftUI
@testable import MaskingTape

// MARK: - Compilation Tests
//
// Because ScreenShield is a UI library built on UIViewRepresentable /
// NSViewRepresentable, meaningful behavioural tests require a running app
// process and cannot run in a headless Swift Testing environment.
//
// These tests verify that the public API compiles correctly with all
// supported type signatures and that the modifiers can be composed without
// ambiguity errors.

@MainActor
struct MaskingTapeAPITests {

  // MARK: screenShield()

  @Test("screenShield() compiles on any View")
  func screenShieldNoReplacement() {
    let _ = Text("Sensitive")
      .screenShield()
  }

  @Test("screenShield(replacement:) compiles with a ViewBuilder closure")
  func screenShieldWithReplacement() {
    let _ = Text("Sensitive")
      .screenShield {
        Text("Protected")
      }
  }

  @Test("screenShield(replacement:) accepts complex view hierarchies")
  func screenShieldWithComplexReplacement() {
    let _ = VStack {
      Text("Card number")
      Text("1234 5678 9012 3456")
    }
    .screenShield {
      Label("Content hidden for security", systemImage: "lock.fill")
    }
  }

  // MARK: Legacy screenWatermark()

  @Test("screenWatermark(overlay:) compiles with default alwaysVisible")
  func screenWatermarkDefault() {
    let _ = Text("Document")
      .screenWatermark {
        Text("CONFIDENTIAL")
      }
  }

  @Test("screenWatermark(alwaysVisible:overlay:) compiles with explicit flag (legacy)")
  func screenWatermarkAlwaysVisible() {
    let _ = Text("Document")
      .screenWatermark(alwaysVisible: true) {
        Text("CONFIDENTIAL")
      }
  }

  @Test("screenWatermark(alwaysVisible:overlay:) compiles when disabled (legacy)")
  func screenWatermarkNotVisible() {
    let _ = Text("Document")
      .screenWatermark(alwaysVisible: false) {
        Text("CONFIDENTIAL")
      }
  }

  // MARK: Chaining

  @Test("secureCapture() and watermark() can be chained")
  func chainedModifiers() {
    // secureCapture prevents capture; watermark adds a capture-reactive brand mark.
    let _ = Text("Sensitive document")
      .secureCapture()
      .watermark {
        Text("© Acme Corp")
          .foregroundStyle(.secondary)
      }
  }

  @Test("Modifiers compose inside standard SwiftUI containers")
  func composedInContainer() {
    let _ = VStack {
      Text("Name")

      Text("4111 1111 1111 1111")
        .secureCapture {
          Text("Card number hidden")
        }

      Text("Footer")
        .watermark {
          Image(systemName: "lock.shield")
        }
    }
  }

  // MARK: New API

  @Test("secureCapture() compiles with default overlay")
  func secureCaptureDefault() {
    let _ = Text("Secret")
      .secureCapture()
  }

  @Test("secureCapture(overlay:) compiles with custom overlay")
  func secureCaptureCustomOverlay() {
    let _ = Text("Secret")
      .secureCapture {
        Text("Protected")
      }
  }

  @Test("watermark(overlay:) compiles as a capture-reactive overlay")
  func watermarkOverlay() {
    let _ = Text("Shareable")
      .watermark {
        Text("CONFIDENTIAL")
      }
  }

  @Test("Always-visible watermark uses native SwiftUI overlay")
  func alwaysVisibleWatermarkViaOverlay() {
    let _ = Text("Shareable")
      .overlay {
        Text("CONFIDENTIAL")
      }
  }
}
