//
//  Container+CoreDataProperties.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 12/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//
//

import CoreData
import Foundation
import os.log

public extension Container {
  @nonobjc class func fetchRequest() -> NSFetchRequest<Container> {
    NSFetchRequest<Container>(entityName: "Container")
  }

  @NSManaged var created: Date?
  @NSManaged var name: String?
  @NSManaged var tagID: String?
  @NSManaged var containedBy: Set<ContainerHistory>?
  @NSManaged var contents: Set<ContainerHistory>?
}

//// MARK: Generated accessors for containedBy

public extension Container {
  @objc(addContainedByObject:)
  @NSManaged func addToContainedBy(_ value: ContainerHistory)

  @objc(removeContainedByObject:)
  @NSManaged func removeFromContainedBy(_ value: ContainerHistory)

  @objc(addContainedBy:)
  @NSManaged func addToContainedBy(_ values: Set<ContainerHistory>)

  @objc(removeContainedBy:)
  @NSManaged func removeFromContainedBy(_ values: Set<ContainerHistory>)
}

// MARK: Generated accessors for contents

public extension Container {
  @objc(addContentsObject:)
  @NSManaged func addToContents(_ value: ContainerHistory)

  @objc(removeContentsObject:)
  @NSManaged func removeFromContents(_ value: ContainerHistory)

  @objc(addContents:)
  @NSManaged func addToContents(_ values: Set<ContainerHistory>)

  @objc(removeContents:)
  @NSManaged func removeFromContents(_ values: Set<ContainerHistory>)
}

extension Container: Identifiable {}

// Custom additions by Patrick

extension Container {
  public var wrappedName: String {
    name ?? "Unknown"
  }

  var previouslyContainedBy: [ContainerHistory] {
    guard let containedBy else {
      return []
    }

    return containedBy.filter { history in
      history.created != nil && history.removed != nil
    }.sorted {
      guard let firstDate = $0.created, let secondDate = $1.created else {
        fatalError("currentlyContainedIn has a created that is nil, desptie the filter")
      }

      return firstDate > secondDate
    }
  }

  private var currentlyContainedBy: [ContainerHistory] {
    guard let containedBy else {
      return []
    }

    return containedBy.filter { history in
      history.created != nil && history.removed == nil
    }.sorted {
      guard let firstDate = $0.created, let secondDate = $1.created else {
        fatalError("currentlyContainedIn has a created that is nil, desptie the filter")
      }

      return firstDate > secondDate
    }
  }

  var location: Container? {
    get {
      currentlyContainedBy.first?.containedIn
    }

    set {
      for history in currentlyContainedBy {
        history.markRemoved()
      }

      if let newValue {
        addToContainedBy(ContainerHistory(context: managedObjectContext, containedIn: newValue, item: self))
      }
    }
  }

  var locationAdded: Date? {
    currentlyContainedBy.first?.created
  }

  var currentContainedItems: [ContainerHistory] {
    guard let contents = contents else {
      return []
    }

    return contents.filter { history in
      history.created != nil && history.removed == nil
    }.sorted {
      guard let firstDate = $0.created, let secondDate = $1.created else {
        fatalError("currentContainedItems has a created that is nil, desptie the filter")
      }

      return firstDate > secondDate
    }
  }

  static func findByTagID(tagID: String, in context: NSManagedObjectContext) throws -> Container? {
    let request = fetchRequest()
    let predicate = NSPredicate(format: "tagID = %@", tagID)
    request.predicate = predicate

    let items = try context.fetch(request)
    return items.first
  }
}
