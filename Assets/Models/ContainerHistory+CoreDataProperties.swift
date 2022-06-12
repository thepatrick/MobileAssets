//
//  ContainerHistory+CoreDataProperties.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 12/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//
//

import Foundation
import CoreData


extension ContainerHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContainerHistory> {
        return NSFetchRequest<ContainerHistory>(entityName: "ContainerHistory")
    }

    @NSManaged public var created: Date?
    @NSManaged public var removed: Date?
    @NSManaged public var containedIn: Container?
    @NSManaged public var item: Container?

}

extension ContainerHistory : Identifiable {

}
