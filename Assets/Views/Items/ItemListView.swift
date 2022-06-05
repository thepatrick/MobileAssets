//
//  ItemListView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 31/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import SwiftUI

struct ItemListView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    animation: .default
  )
  private var items: FetchedResults<Item>

  @State private var isShowingAddView = false

  var body: some View {
    NavigationView {
      List {
        ForEach(items) { item in
          NavigationLink {
            SingleItemView(id: item.objectID, in: viewContext)

//            Text("Item \(item.objectID) at \(item.timestamp!, formatter: itemFormatter)")
          } label: {
            if let image = item.photo {
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64, alignment: .center)
                .clipped()
            } else {
              Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64, alignment: .center)
                .foregroundColor(.gray)
            }

            Text(item.title ?? "(untitled)")
//                        Text(item.timestamp!, formatter: itemFormatter)
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
      .navigationTitle("Assets")
      Text("Select an item")
    }
    .sheet(isPresented: $isShowingAddView) {
      AddItemView(onAdd: { name, image in
        isShowingAddView = false
        addItem(title: name, image: image)
      }) {
        isShowingAddView = false
      }
    }
  }

  private func addItem(title: String, image: UIImage?) {
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.title = title
      newItem.timestamp = Date()
      newItem.photo = image

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
      offsets.map { items[$0] }.forEach(viewContext.delete)

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

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct ItemListView_Previews: PreviewProvider {
  static var previews: some View {
    ItemListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
