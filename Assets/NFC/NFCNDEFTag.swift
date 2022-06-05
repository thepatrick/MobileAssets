//
//  NFCNDEFTag.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Combine
import CoreNFC
import Foundation

extension NFCNDEFTag {
  func readNDEFWithDefault() async throws -> NFCNDEFMessage {
    do {
      let message = try await readNDEF()

      return message
    } catch let error as NFCReaderError {
      if error.code == NFCReaderError.Code.ndefReaderSessionErrorZeroLengthMessage {
        return NFCNDEFMessage(records: [NFCNDEFPayload.emptyPayload()])
      } else {
        throw error
      }
    }
  }
}
