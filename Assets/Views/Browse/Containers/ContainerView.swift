//
//  ContainerView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
import os.log
import SwiftUI

struct ContainerView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @ObservedObject var container: ContainerViewModel

  init(container: Container) {
    self.container = ContainerViewModel(container: container)

    os_log("ContainerView being initialized (\(container.objectID), temporary? \(container.objectID.isTemporaryID ? "Yes" : "No"))")
  }

  var body: some View {
    List {
      Section("Title") {
        Text(container.container.wrappedName)
          .navigationTitle(container.container.wrappedName)
      }
      if let tagID = container.tagID {
        Section("Tag \(tagID)") {
          Button {
            Task { try? await container.verifyTag() }
          } label: {
            HStack(alignment: .center, spacing: 0) {
              VStack(alignment: .leading) {
                Text("Check").font(.headline)
                // TODO: Make this work
                // Text("Last seen \(Date.now.formatted())").font(.footnote).foregroundColor(.red) // .foregroundColor(.secondary)
              }

              Spacer()

              Image(systemName: "sensor.tag.radiowaves.forward")
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 24, alignment: .center)
                .clipped()
            }
          }

          Button("Remove Tag") {
            container.removeTag()
          }
        }
      } else {
        Section("Tag") {
          if !container.canScanTags {
            Text("NFC is not available").font(.footnote).foregroundColor(.secondary).disabled(true)
          } else {
            AsyncButton(action: {
              do {
                try await self.container.addTag()
              } catch {
                print("Some error ocurred etc etc \(error)")
              }
            }) {
              Text("Scan Tag")
            }
          }
        }
      }
      
      Section("Location") {
        if container.containedItems.isEmpty {
          if !container.canScanTags {
            Text("NFC is not available").font(.footnote).foregroundColor(.secondary).disabled(true)
          } else {
            AsyncButton(action: {}) {
              Text("Scan Location")
            }
          }
        } else {
          ForEach(container.containedItems, id: \.self) { history in
            Button {
              // Pop the contained item into our stack
            } label: {
              VStack(alignment: .leading) {
                Text(history.containedIn?.wrappedName ?? "(unknown)").font(.headline)
                Text(history.containedIn?.created?.formatted() ?? "(unknown)").font(.headline)
              }
            }
          }
          
          Button("Remove All") {
//            container.removeTag()
          }
        }
      }
      
//      Section("Location") {
//        Button {} label: {
//          HStack(alignment: .center, spacing: 0) {
//            VStack(alignment: .leading) {
//              Text("Desk").font(.headline)
//              Text("Set \(Date.now.formatted())").font(.footnote).foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            Image(systemName: "info.circle")
//              .resizable()
//              .scaledToFill()
//              .frame(width: 24, height: 24, alignment: .center)
//              .clipped()
//          }
//        }
//
//        Button("Clear Location") {}.foregroundColor(.red)
//        Button("Set New Location") {}.foregroundColor(.red)
//      }
//
//      Section("Location") {
//        Button("Set New Location") {}.foregroundColor(.red)
//      }
      
//      Section {
//        if let image = item.photo {
//          AnyView(Image(uiImage: image)
//            .resizable()
//            .scaledToFill()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .clipped()
//            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
//          )
//        } else {
//          AnyView(Image(systemName: "photo")
//            .resizable()
//            .scaledToFill()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .clipped()
//            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
//          )
//        }
//      }.scaleEffect(x: 1.1, y: 1.1, anchor: .center)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Edit", action: {
          os_log("Edit!")
        }) // .disabled(!vm.isLoaded)
      }
    }
  }
  
//  var itemImage: some View {
//    if let image = item.photo {
//      return AnyView(Image(uiImage: image)
//        .resizable()
//        .scaledToFill()
//        .frame(width: 64, height: 64, alignment: .center)
//        .clipped())
//    } else {
//      return AnyView(Image(systemName: "photo")
//        .resizable()
//        .aspectRatio(contentMode: .fit)
//        .frame(width: 64, height: 64, alignment: .center)
//        .foregroundColor(.gray))
//    }
//  }
}

struct ContainerView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let container = Container(context: context)
    container.name = "Preview 123"
    
    let history = ContainerHistory(context: context)
    history.item = container
    history.containedIn = container
    history.created = Date()
    
    // history.remove = Date()
    
    container.addToContents(history)

    return NavigationView { ContainerView(container: container).environment(\.managedObjectContext, context) }
  }
}
