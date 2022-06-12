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

// MARK: Generated accessors for containedBy

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

  var currentContainedItems: [ContainerHistory] {
    guard let contents = contents else {
      return []
    }

    return contents.filter { history in
      history.created != nil && history.removed == nil
    }.sorted {
      ($0.created ?? Date()) > ($1.created ?? Date())
    }
  }
}
