//
//  NavigationModel.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 12/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

final class NavigationModel: ObservableObject, Codable {
//  @Published var selectedCategory: Category?
  @Published var containerPath: [Container]

  @Published var columnVisibility: NavigationSplitViewVisibility

  private lazy var decoder = JSONDecoder()
  private lazy var encoder = JSONEncoder()
  
  var managedObjectContext: NSManagedObjectContext?

  init(
    columnVisibility: NavigationSplitViewVisibility = .automatic,
    selectedCategory _: Category? = nil,
    containerPath: [Container] = []
  ) {
    self.columnVisibility = columnVisibility
//      self.selectedCategory = selectedCategory
    self.containerPath = containerPath
  }

  var selectedContainer: Container? {
    get { containerPath.first }
    set { containerPath = [newValue].compactMap { $0 } }
  }

  var jsonData: Data? {
    get { try? encoder.encode(self) }
    set {
      decoder.userInfo[CodingUserInfoKey.managedObjectContext] = self.managedObjectContext
      
      guard let data = newValue,
            let model = try? decoder.decode(Self.self, from: data)
      else { return }
      containerPath = model.containerPath
      columnVisibility = model.columnVisibility
    }
  }

  var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
    objectWillChange
      .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
      .values
  }

  required init(from decoder: Decoder) throws {
    guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
      throw DecoderConfigurationError.missingManagedObjectContext
    }
    
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let containerPathIds = try container.decode([URL].self, forKey: .containerPathIds)
    containerPath = containerPathIds.compactMap {
      guard let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0),
            let object = context.object(with: objectID) as? Container
      else {
        return nil
      }

      return object
    }
    columnVisibility = try container.decode(
      NavigationSplitViewVisibility.self, forKey: .columnVisibility
    )
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(containerPath.map(\.objectID).map { $0.uriRepresentation() }, forKey: .containerPathIds)
    try container.encode(columnVisibility, forKey: .columnVisibility)
  }

  enum CodingKeys: String, CodingKey {
    case containerPathIds
    case columnVisibility
  }
}
