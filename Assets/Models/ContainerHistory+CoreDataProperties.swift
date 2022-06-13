//
//  ContainerHistory+CoreDataProperties.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 12/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//
//

import CoreData
import Foundation

public extension ContainerHistory {
  @nonobjc class func fetchRequest() -> NSFetchRequest<ContainerHistory> {
    NSFetchRequest<ContainerHistory>(entityName: "ContainerHistory")
  }

  @NSManaged var created: Date?
  @NSManaged var removed: Date?
  @NSManaged var containedIn: Container?
  @NSManaged var item: Container?
}

extension ContainerHistory: Identifiable {}

extension ContainerHistory {
  convenience init(context: NSManagedObjectContext?, containedIn: Container, item: Container) {
    if let context {
      self.init(context: context)
    } else {
      self.init()
    }

    created = Date()
    self.containedIn = containedIn
    self.item = item
  }

  func markRemoved() {
    removed = Date()
  }
}
