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
// Because MaskingTape is a UI library built on UIViewRepresentable /
// NSViewRepresentable, meaningful behavioural tests require a running app
// process and cannot run in a headless Swift Testing environment.
//
// These tests verify that the public API compiles correctly with all
// supported type signatures and that the modifiers can be composed without
// ambiguity errors.

@MainActor
struct MaskingTapeAPITests {

  // MARK: Chaining

  @Test("maskingTape() and watermark() can be chained")
  func chainedModifiers() {
    // maskingTape prevents capture; watermark adds a capture-reactive brand mark.
    let _ = Text("Sensitive document")
      .maskingTape()
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
        .maskingTape {
          Text("Card number hidden")
        }

      Text("Footer")
        .watermark {
          Image(systemName: "lock.shield")
        }
    }
  }

  // MARK: Primary API

  @Test("maskingTape() compiles with default overlay")
  func maskingTapeDefault() {
    let _ = Text("Secret")
      .maskingTape()
  }

  @Test("maskingTape(overlay:) compiles with custom overlay")
  func maskingTapeCustomOverlay() {
    let _ = Text("Secret")
      .maskingTape {
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
