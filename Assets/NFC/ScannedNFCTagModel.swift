//
//  ScannedNFCTagModel.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 28/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Combine
import CoreNFC
import Foundation
import SwiftUI

@MainActor
class ScannedNFCTagModel: ObservableObject {
  @Published var lastScanError: Error?
  @Published var tagID: String?
  @Published var scanning: Bool = false

  func beginScan() async throws {
    do {
      scanning = false

      let tagID = try await StuffTagReader().scanOneTag()

      self.tagID = tagID
      lastScanError = nil
    } catch {
      lastScanError = error
    }

    scanning = false
  }
}
