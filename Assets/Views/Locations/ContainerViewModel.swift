//
//  LocationViewModel.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import CoreNFC
import Foundation
import os.log

@MainActor
class ContainerViewModel: ObservableObject {
  @Published var name: String
  @Published var tagID: String?

  @Published var lastScanError: Error?
  @Published var scanning: Bool = false

  let container: Container

  var canScanTags: Bool { NFCReaderSession.readingAvailable }

  init(container: Container) {
    self.container = container
    name = container.name ?? ""
    tagID = container.tagID
  }

  func addTag() async throws {
    do {
      scanning = false

      let tagID = try await StuffTagReader().scanOneTag()

      self.tagID = tagID
      lastScanError = nil
    } catch {
      lastScanError = error
    }

    scanning = false

    save()
  }

  func removeTag() {
    tagID = nil

    save()
  }

  func save() {
    container.name = name
    container.tagID = tagID

    do {
      try container.managedObjectContext?.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
}

// @MainActor
// final class LocationViewModel: ObservableObject {
//  enum State {
//    case idle
//    case loading
//    case loaded(container: ContainerVM)
//    case notFound
//  }
//
//  @Published private(set) var state = State.idle
//
//  nonisolated init() {
//    os_log("LoctaionViewModel init...")
//  }
//
//  func initialize(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
//    os_log("initialize called with \(objectID) (temporary? \(objectID.isTemporaryID ? "Yes" : "No"))")
//    state = .loading
//    if let container = try? context.existingObject(with: objectID) as? Container {
//      state = .loaded(container: ContainerVM(container: container))
//    } else {
//      state = .notFound
//    }
//  }
//
//  var isLoaded: Bool {
//    switch state {
//    case .loaded:
//      return true
//    default:
//      return false
//    }
//  }
// }
