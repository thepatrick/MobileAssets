//
//  TagReader.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 8/10/19.
//  Copyright © 2019-2022 Patrick Quinn-Graham. All rights reserved.
//

#if canImport(CoreNFC)
  import CoreNFC
#endif

import Foundation
import os.log

#if canImport(UIKit)
  import UIKit
#endif

func generateTagIDURL(_ tagID: String) -> NFCNDEFPayload {
  NFCNDEFPayload.wellKnownTypeURIPayload(string: String(format: "https://%@/%@", "a.twopats.live", tagID))!
}

struct AssetTags {
  private func invalidateMessage(forError error: Error) -> String {
    if let error = error as? TagErrors {
      return error.localizedDescription
    }

    return "Connection error. Please try again."
  }

  private func getTagIDFrom(_ record: NFCNDEFPayload) throws -> String {
    if record.typeNameFormat == NFCTypeNameFormat.empty {
      throw TagErrors.TagEmpty
    }

    guard let uri = record.wellKnownTypeURIPayload() else {
      print("* Something else: identifier: \(record.identifier); typeNameFormat: \(record.typeNameFormat.rawValue); type: \(record.type); payload: \(record.payload)")
      throw TagErrors.TagNotEmpty
    }

    let tagID = uri.pathComponents[1]

    return tagID
  }

  func myDeviceType() -> String {
    #if canImport(UIKit)
      return UIDevice.current.localizedModel
    #else
      return "Mac"
    #endif
  }

  func setupOneTag() async throws -> String {
    os_log("Verify one tag....")

    let (session, tag) = try await AsyncNFCNDEFReaderSession().begin(prompt: "Hold your \(myDeviceType()) near a new tag")
    let tagID: String

    do {
      try await session.connect(to: tag)
      print("Connected to tag! \(tag)")

      let (ndefStatus, capacity) = try await tag.queryNDEFStatus()

      switch ndefStatus {
      case .notSupported:
        throw TagErrors.TagNotSupported
      case .readOnly:
        throw TagErrors.TagNotWritable
      default:
        os_log("Tag has capacity \(capacity)")
      }

      let message: NFCNDEFMessage

      do {
        message = try await tag.readNDEF()
      } catch let error as NFCReaderError {
        if error.code != NFCReaderError.Code.ndefReaderSessionErrorZeroLengthMessage {
          throw error
        }
        message = NFCNDEFMessage(records: [])
      }

      if let record = message.records.first {
        do {
          let _ = try getTagIDFrom(record)

          throw TagErrors.TagAlreadySetup
        } catch let error as TagErrors {
          if error != .TagEmpty {
            throw error
          }
        }
      }

      tagID = UUID().uuidString

      session.alertMessage = "Writing tag ID..."
      try await tag.writeNDEF(NFCNDEFMessage(records: [generateTagIDURL(tagID)]))

    } catch {
      session.invalidate(errorMessage: invalidateMessage(forError: error))
      throw error
    }

    session.invalidate()

    return tagID
  }

  private func getTagIDFromTag(_ tag: NFCNDEFTag) async throws -> String {
    let (ndefStatus, capacity) = try await tag.queryNDEFStatus()

    if ndefStatus == .notSupported {
      throw TagErrors.TagNotSupported
    }

    os_log(OSLogType.debug, "Tag has capacity \(capacity)")

    let message: NFCNDEFMessage

    do {
      message = try await tag.readNDEF()
    } catch let error as NFCReaderError {
      if error.code == NFCReaderError.Code.ndefReaderSessionErrorZeroLengthMessage {
        throw TagErrors.TagEmpty
      }
      throw error
    }

    guard let record = message.records.first else {
      os_log("Tag has NDEF content, but has an empty records arrays")
      throw TagErrors.TagEmpty
    }

    return try getTagIDFrom(record)
  }

  func verifyOneTag() async throws -> String {
    os_log("Verify one tag....")

    let (session, tag) = try await AsyncNFCNDEFReaderSession().begin()

    let tagID: String

    do {
      try await session.connect(to: tag)
      os_log(OSLogType.info, "Connected to tag! \(tag.description)")

      tagID = try await getTagIDFromTag(tag)

    } catch {
      session.invalidate(errorMessage: invalidateMessage(forError: error))
      throw error
    }

    session.invalidate()

    return tagID
  }

  @discardableResult func verifyOneTagIs(tagID expectedTagID: String) async throws -> Bool {
    os_log("Verify one tag....")

    let (session, tag) = try await AsyncNFCNDEFReaderSession().begin()

    let readTagID: String

    do {
      try await session.connect(to: tag)
      os_log(OSLogType.info, "Connected to tag! \(tag.description)")

      readTagID = try await getTagIDFromTag(tag)

    } catch {
      session.invalidate(errorMessage: invalidateMessage(forError: error))
      throw error
    }

    if expectedTagID != readTagID {
      session.invalidate(errorMessage: "Not the expected tag")
    } else {
      session.alertMessage = "Excellent, that is the right tag!"
      session.invalidate()
    }

    return expectedTagID == readTagID
  }
}
