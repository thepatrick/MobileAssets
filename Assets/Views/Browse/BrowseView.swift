//
//  BrowseView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import os.log
import SwiftUI

struct BrowseView: View {
  @Environment(\.managedObjectContext) private var viewContext

//  @SceneStorage("experience") private var experience: Experience?
  @SceneStorage("navigation") private var navigationData: Data?
  @StateObject private var navigationModel = NavigationModel()

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Container.name, ascending: true)],
    animation: .default
  )
  private var containers: FetchedResults<Container>

  @State private var isShowingAddView = false
  @State private var searchText = ""

  @State private var selection: Container?

  var body: some View {
    NavigationSplitView(columnVisibility: $navigationModel.columnVisibility) {
      List(selection: $selection) {
        ForEach(containers) { container in
          NavigationLink(container.wrappedName, value: container)
        }
        .onDelete(perform: deleteItems)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: { isShowingAddView = true }) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .navigationTitle("Browse")
    } detail: {
      NavigationStack(path: $navigationModel.containerPath) {
        if let container = selection {
          ContainerView(container: container)
        } else {
          Text("Hello")
        }
      }
      .navigationDestination(for: Container.self) { container in
        ContainerView(container: container)
      }
    }
    .sheet(isPresented: $isShowingAddView) {
      AddContainerView { name in
        addContainer(name: name)
        isShowingAddView = false
      } onCancel: {
        isShowingAddView = false
      }
    }
    .environmentObject(navigationModel)
    .task {
      navigationModel.managedObjectContext = viewContext
      if let jsonData = navigationData {
        navigationModel.jsonData = jsonData
      }
      for await _ in navigationModel.objectWillChangeSequence {
        let jsonData = navigationModel.jsonData
        os_log("JSON DATA: \(jsonData?.debugDescription ?? "Oh well")")
        navigationData = jsonData
      }
    }
  }

  private func addContainer(name: String) {
    withAnimation {
      let newContainer = Container(context: viewContext)
      newContainer.name = name
      newContainer.created = Date()

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { containers[$0] }.forEach(viewContext.delete)

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

private let containerFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct BrowseView_Previews: PreviewProvider {
  static var previews: some View {
    BrowseView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
