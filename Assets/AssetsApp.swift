//
//  AssetsApp.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 31/5/2022.
//

import SwiftUI

@main
struct AssetsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
