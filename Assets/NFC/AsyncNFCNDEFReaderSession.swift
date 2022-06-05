//
//  NFC.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 31/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreNFC
import Foundation
import os.log

final class AsyncNFCNDEFReaderSession: NSObject, NFCNDEFReaderSessionDelegate {
  private var readerSession: NFCNDEFReaderSession?
  private var activeContinuation: CheckedContinuation<(NFCNDEFReaderSession, NFCNDEFTag), Error>?

  override init() {
    super.init()
  }

  func begin(prompt: String = "Hold your iPhone near an NFC tag") async throws -> (NFCNDEFReaderSession, NFCNDEFTag) {
    os_log("OneNFCTag request!")

    guard NFCTagReaderSession.readingAvailable else { throw TagErrors.ReadingUnavailable }

    return try await withCheckedThrowingContinuation { continuation in
      activeContinuation = continuation

      readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
      readerSession!.alertMessage = prompt
      readerSession!.begin()
    }
  }

//  func again() async throws -> (NFCNDEFReaderSession, NFCNDEFTag) {
//    guard readerSession != nil else { throw TagErrors.ReadingUnavailable }
//
//    return try await withCheckedThrowingContinuation { continuation in
//      activeContinuation = continuation
//      readerSession!.restartPolling()
//    }
//  }

  func cancel() {
    os_log("NFCNDEFReaderSessionOneTag cancelled!")
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
        os_log("NFCNDEFReaderSessionOneTag did invalidate with NFCReaderError! \(readerError.localizedDescription)")
        activeContinuation?.resume(throwing: readerError)
      } else {
        activeContinuation?.resume(throwing: TagErrors.NoTagPresented)
      }
    } else {
      os_log("NFCNDEFReaderSession did invalidate with error! \(error.localizedDescription)")
      activeContinuation?.resume(throwing: error)
    }
    activeContinuation = nil
  }

  // This function will not be invoked because `readerSession(_:didDetect:)` is implemented, but is required so must be present. Yay!
  func readerSession(_: NFCNDEFReaderSession, didDetectNDEFs _: [NFCNDEFMessage]) {}

  func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
    os_log("readerSession(didDetect:) with \(tags.count)")
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
