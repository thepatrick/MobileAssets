//
//  LocationViewModel.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
#if canImport(CoreNFC)
  import CoreNFC
#endif
import Combine
import Foundation
import os.log


@MainActor
class ContainerViewModel: ObservableObject {
  @Published var name: String
  @Published var tagID: String?
  
  @Published var containedItems: [ContainerHistory] = []

  @Published var lastScanError: Error?
  @Published var scanning: Bool = false

  let container: Container
  var cancellable: AnyCancellable?

  var canScanTags: Bool { NFCReaderSession.readingAvailable }

  init(container: Container) {
    self.container = container
    name = container.wrappedName

    self.readFromContainer(container: container)
    
    cancellable = container.objectWillChange.sink {
      self.readFromContainer(container: container)
    }

//    container.publisher(for: \.name).map { maybeName in
//      maybeName ?? ""
//    }.assign(to: \.name, on: self)
//
//    let history = ContainerHistory(context: container.managedObjectContext!)
//    history.containedIn = self.container
//    history.item = self.container
  }

  func readFromContainer(container: Container) {
    self.name = container.wrappedName
    self.tagID = container.tagID
    self.containedItems = container.currentContainedItems
  }

  func addTag() async throws {
    do {
      scanning = false

      let tagID = try await AssetTags().verifyOneTag()

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

  func verifyTag() async throws {
    guard let tagID = tagID else {
      os_log("ContainerViewModel.verifyTag() called when tagID is nil, this is not valid.")
      return
    }
    try await AssetTags().verifyOneTagIs(tagID: tagID)
  }
  
  func addToLocation() async throws {
    do {
      scanning = true
      
      let tagID = try await AssetTags().verifyOneTag()
      
      
    } catch {
      lastScanError = error
    }
    
    scanning = false
    // save()
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
