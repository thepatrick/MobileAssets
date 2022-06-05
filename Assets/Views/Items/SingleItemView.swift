//
//  SingleItemView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 2/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import SwiftUI

struct SingleItemView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @State private var item: Item

  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
    if let item = try? context.existingObject(with: objectID) as? Item {
      self.item = item
    } else {
      item = Item(context: context)
    }
  }

  var body: some View {
    List {
      Section("Title") {
        TextField("Title", text: Binding($item.title)!)
          .textContentType(.name)
      }

      if false {
        Section("Tag") {
          Button("Add Tag") {}.foregroundColor(.red)
        }
      } else {
        Section("Tag") {
          Button {} label: {
            HStack(alignment: .center, spacing: 0) {
              VStack(alignment: .leading) {
                Text("Check").font(.headline)
                Text("Last seen \(Date.now.formatted())").font(.footnote).foregroundColor(.secondary)
              }

              Spacer()

              Image(systemName: "sensor.tag.radiowaves.forward")
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 24, alignment: .center)
                .clipped()
            }
          }

          Button("Remove Tag") {}.foregroundColor(.red)
        }
      }

      Section("Location") {
        Button {} label: {
          HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading) {
              Text("Desk").font(.headline)
              Text("Set \(Date.now.formatted())").font(.footnote).foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "info.circle")
              .resizable()
              .scaledToFill()
              .frame(width: 24, height: 24, alignment: .center)
              .clipped()
          }
        }

        Button("Clear Location") {}.foregroundColor(.red)
        Button("Set New Location") {}.foregroundColor(.red)
      }

      Section("Location") {
        Button("Set New Location") {}.foregroundColor(.red)
      }

      Section {
        if let image = item.photo {
          AnyView(Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
          )
        } else {
          AnyView(Image(systemName: "photo")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
          )
        }
      }.scaleEffect(x: 1.1, y: 1.1, anchor: .center)
    }
//    .listStyle(.plain)
    .navigationTitle(item.title ?? "")
    .navigationBarTitleDisplayMode(.inline)
    .onDisappear {
      try? viewContext.save()
    }
//    .toolbar {
//      toolbar(content: <#T##() -> View#>)
//    }
  }

  var itemImage: some View {
    if let image = item.photo {
      return AnyView(Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: 64, height: 64, alignment: .center)
        .clipped())
    } else {
      return AnyView(Image(systemName: "photo")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 64, height: 64, alignment: .center)
        .foregroundColor(.gray))
    }
  }
}

struct SingleItemView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let item = Item(context: context)
    item.title = "Preview 123"

    return NavigationView {
      SingleItemView(id: item.objectID, in: context).environment(\.managedObjectContext, context)
    }
  }
}
