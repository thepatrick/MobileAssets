//
//  Tag.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 5/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import Foundation

// static func tagIDInUse(context: NSManagedObjectContext, tagID: String) -> Bool {
//  let request = Item.fetchRequest()
//
//  // create an NSPredicate to get the instance you want to make change
//  let predicate = NSPredicate(format: "tagID = %@", tagID)
//  request.predicate = predicate
//
//  do {
//    let items = try context.fetch(request)
//    return !items.isEmpty
//  } catch let error {
//    print(error.localizedDescription)
//    return false
//  }
// }

extension Container {
  static func findByTagID(tagID: String, in context: NSManagedObjectContext) throws -> Container? {
    let request = fetchRequest()
    let predicate = NSPredicate(format: "tagID = %@", tagID)
    request.predicate = predicate

    let items = try context.fetch(request)
    return items.first
  }
}
