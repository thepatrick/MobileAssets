//
//  TagErrors.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

public enum TagErrors: LocalizedError, CaseIterable {
  case ReadingUnavailable
  case NoTagPresented
  case TagNotSupported
  case TagNotWritable
  case TagNotEmpty
  case TagAlreadyAttached
  case TagEmpty
  case TagAlreadySetup
  case InvalidCallingConvention
  case TagNotAttached

  var localizedDescription: String {
    switch self {
    case .ReadingUnavailable: return "NFC is not supported on this device"
    case .NoTagPresented: return "No Tag found"
    case .TagNotSupported: return "Tag is not supported"
    case .TagNotWritable: return "Tag is not writable"
    case .TagAlreadyAttached: return "Tag is attached to another item"
    case .TagEmpty: return "Tag is not initialised for Assets"
    case .TagNotEmpty: return "Tag is not empty"
    case .TagAlreadySetup: return "Tag is already setup"
    case .InvalidCallingConvention: return "A closure was called with an invalid calling convention, probably (nil, nil)"
    case .TagNotAttached: return "Tag is not associated with anything"
    }
  }
}
