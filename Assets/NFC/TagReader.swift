//
//  TagReader.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 8/10/19.
//  Copyright © 2019-2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreNFC
import Foundation
import os.log

func generateTagIDURL(_ tagID: String) -> NFCNDEFPayload {
  return NFCNDEFPayload.wellKnownTypeURIPayload(string: String(format: "https://%@/%@", "a.twopats.live", tagID))!
}

struct StuffTagReader {
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

  private func getTagID(_ record: NFCNDEFPayload) throws -> (String, Bool) {
    if record.typeNameFormat == NFCTypeNameFormat.empty {
      let _tagID = UUID().uuidString

      return (_tagID, true)
    }

    guard let uri = record.wellKnownTypeURIPayload() else {
      print("* Something else: identifier: \(record.identifier); typeNameFormat: \(record.typeNameFormat.rawValue); type: \(record.type); payload: \(record.payload)")
      throw TagErrors.TagNotEmpty
    }

    let tagID = uri.pathComponents[1]

    return (tagID, false)
  }

  private func processTag(session: NFCNDEFReaderSession, tag: NFCNDEFTag) async throws -> String {
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
        print("Tag has capacity \(capacity)")
      }

      let message = try await tag.readNDEFWithDefault()
      print("\(message.records.count) records:")

      let record = message.records.first ?? NFCNDEFPayload.emptyPayload()

      let (tagId, needsWrite) = try getTagID(record)
      if needsWrite {
        session.alertMessage = "Writing tag ID..."
        try await tag.writeNDEF(NFCNDEFMessage(records: [generateTagIDURL(tagId)]))
      }

      await MainActor.run {
        session.alertMessage = "Found tag"
      }

      print("* got tagId \(tagId), invalidating...")
      return tagId

    } catch {
      print("* catch error \(error), invalidating...")
      session.invalidate(errorMessage: invalidateMessage(forError: error))
      throw error
    }
  }

  func scanOneTag() async throws -> String {
    print("** startNDEFScan5: OneNFCTag.get()...")

    let (session, tag) = try await NFCNDEFReaderSessionOneTag().begin()

    let tagID = try await processTag(session: session, tag: tag)

    session.invalidate()

    return tagID
  }

  func verifyOneTag() async throws -> String {
    os_log("Verify one tag....")

    let (session, tag) = try await NFCNDEFReaderSessionOneTag().begin()

    let tagID: String

    do {
      try await session.connect(to: tag)
      print("Connected to tag! \(tag)")

      let (ndefStatus, capacity) = try await tag.queryNDEFStatus()

      switch ndefStatus {
      case .notSupported:
        throw TagErrors.TagNotSupported
      default:
        print("Tag has capacity \(capacity)")
      }

      let message: NFCNDEFMessage

      do {
        message = try await tag.readNDEF()
      } catch let error as NFCReaderError {
        if error.code == NFCReaderError.Code.ndefReaderSessionErrorZeroLengthMessage {
          throw TagErrors.TagEmpty
        } else {
          throw error
        }
      }

      guard let record = message.records.first else {
        os_log("Tag has NDEF content, but has an empty records arrays")
        throw TagErrors.TagEmpty
      }

      tagID = try getTagIDFrom(record)

    } catch {
      session.invalidate(errorMessage: invalidateMessage(forError: error))
      throw error
    }

    session.invalidate()

    return tagID
  }
}
