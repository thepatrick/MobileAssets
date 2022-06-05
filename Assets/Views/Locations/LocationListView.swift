//
//  LocationListView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import SwiftUI

struct LocationListView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Container.name, ascending: true)],
    animation: .default
  )
  private var containers: FetchedResults<Container>

  @State private var isShowingAddView = false

  var body: some View {
    NavigationView {
      List {
        ForEach(containers) { container in
          NavigationLink {
//            SingleItemView(id: container.objectID, in: viewContext)
            ContainerView(container: container)

          } label: {
//            if let image = item.photo {
//              Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 64, height: 64, alignment: .center)
//                .clipped()
//            } else {
//              Image(systemName: "person.circle")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 64, height: 64, alignment: .center)
//                .foregroundColor(.gray)
//            }

            Text(container.name ?? "(untitled)")
          }
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
      .navigationTitle("Containers")
      Text("Select an item")
    }
    .sheet(isPresented: $isShowingAddView) {
      AddLocationView { name in
        addContainer(name: name)
        isShowingAddView = false
      } onCancel: {
        isShowingAddView = false
      }

//      AddItemView(onAdd: { name, image in
//        isShowingAddView = false
//        addItem(title: name, image: image)
//      }) {
//        isShowingAddView = false
//      }
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

struct LocationListView_Previews: PreviewProvider {
  static var previews: some View {
    LocationListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
