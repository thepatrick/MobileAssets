//
//  AssetsApp.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 31/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

@main
struct AssetsApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      RootUIView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
