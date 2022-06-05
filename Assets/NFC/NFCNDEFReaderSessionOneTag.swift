//
//  NFC.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 31/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreNFC
import Foundation

final class NFCNDEFReaderSessionOneTag: NSObject, NFCNDEFReaderSessionDelegate {
  private var readerSession: NFCNDEFReaderSession?
  private var activeContinuation: CheckedContinuation<(NFCNDEFReaderSession, NFCNDEFTag), Error>?

  override init() {
    super.init()
  }

  func begin() async throws -> (NFCNDEFReaderSession, NFCNDEFTag) {
    print("OneNFCTag request!")

    guard NFCTagReaderSession.readingAvailable else { throw TagErrors.ReadingUnavailable }

    return try await withCheckedThrowingContinuation { continuation in
      activeContinuation = continuation

      readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
      readerSession!.alertMessage = "Hold your iPhone near an NFC tag"
      readerSession!.begin()
    }
  }

  func cancel() {
    print("CombinedNFCNDEFReaderSessionSubscription cancelled! \(String(describing: readerSession))")
    // readerSession?.alertMessage = "Cancelling..."
    readerSession?.invalidate()
    readerSession = nil
  }

  // This function is here to silence a message that gets logged if it isn't. YOLO.
  func readerSessionDidBecomeActive(_: NFCNDEFReaderSession) {}

  func readerSession(_: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    if let readerError = error as? NFCReaderError {
      if readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
         readerError.code != .readerSessionInvalidationErrorUserCanceled,
         readerError.code != .readerSessionInvalidationErrorSessionTimeout
      {
        print("NFCNDEFReaderSession did invalidate with NFCReaderError! \(error)")
        activeContinuation?.resume(throwing: readerError)
      } else {
        activeContinuation?.resume(throwing: TagErrors.NoTagPresented)
      }
    } else {
      print("NFCNDEFReaderSession did invalidate with error! \(error)")
      activeContinuation?.resume(throwing: error)
    }
    activeContinuation = nil
  }

  // This function will not be invoked because `readerSession(_:didDetect:)` is implemented, but is required so must be present. Yay!
  func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs _: [NFCNDEFMessage]) {}

  func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    print("readerSession(didDetect:) with \(tags.count)")
    if tags.count > 1 {
      session.invalidate(errorMessage: "More than 1 tag was found. Please present only 1 tag.")
      return
    }

    guard let firstTag = tags.first else {
      session.invalidate(errorMessage: "Unable to get first tag")
      return
    }

    activeContinuation?.resume(returning: (session, firstTag))
    activeContinuation = nil
  }
}
