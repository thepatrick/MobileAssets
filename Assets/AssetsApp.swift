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
      #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
      #endif
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    // #if os(macOS)
    // .commands {
    //    SidebarCommands()
    // }
    // #endif
  }
}
