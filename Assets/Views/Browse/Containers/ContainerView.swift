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

struct StatusRow: View {
  
  var feature: String
  
  var isOK: Bool
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      VStack(alignment: .leading) {
        
        Text(feature).foregroundColor(.secondary)
        
        // Text("Last seen \(Date.now.formatted())").font(.footnote).foregroundColor(.red) // .foregroundColor(.secondary)
      }

      Spacer()

      Image(systemName: isOK ? "checkmark.circle" : "x.circle")
        .resizable()
        .scaledToFill()
        .frame(width: 24, height: 24, alignment: .center)
        .clipped()
        .foregroundColor(isOK ? .green : .red)
    }
  }
  
}

struct ContainerView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @ObservedObject var container: ContainerViewModel

  init(container: Container) {
    self.container = ContainerViewModel(container: container)

    os_log("ContainerView being initialized (\(container.objectID), temporary? \(container.objectID.isTemporaryID ? "Yes" : "No"))")
  }

  var body: some View {
    List {
      Section {
        Text(container.container.wrappedName)
          .navigationTitle(container.container.wrappedName)
          .font(.headline)
      }
      
      Section {
        StatusRow(feature: "Tag attached", isOK: container.tagID != nil)
        
        StatusRow(feature: "Purchase data recorded", isOK: false)
        
        StatusRow(feature: "Has location", isOK: !container.containedBy.isEmpty)
      }

      if container.tagID == nil {
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
        if container.containedBy.isEmpty {
          if !container.canScanTags {
            Text("NFC is not available").font(.footnote).foregroundColor(.secondary).disabled(true)
          } else {
            AsyncButton(action: {
              do {
                try await container.addToLocation()
              } catch {
                os_log("Error? \(error)")
              }
            }) {
              Text("Scan Location")
            }
          }
        } else {
          ForEach(container.containedBy, id: \.self) { history in
            if let c = history.containedIn {
              NavigationLink(value: c) {
                VStack(alignment: .leading) {
                  Text(c.wrappedName).font(.headline)
                  Text(history.created?.formatted() ?? "(unknown)").font(.footnote).foregroundColor(.secondary)
                }
              }
            }
          }
        }
      }

      Section("Contains") {
        if !container.containedItems.isEmpty {
          ForEach(container.containedItems, id: \.self) { history in
            if let c = history.item {
              NavigationLink(value: c) {
                VStack(alignment: .leading) {
                  Text(c.wrappedName).font(.headline)
                  Text(history.created?.formatted() ?? "(unknown)").font(.footnote).foregroundColor(.secondary)
                }
              }
            }
          }
        }
        
        if !container.canScanTags {
          Text("NFC is not available").font(.footnote).foregroundColor(.secondary).disabled(true)
        } else {
          AsyncButton(action: {
            do {
              try await container.addContainedItem()
            } catch {
              os_log("Error? \(error)")
            }
          }) {
            Text("Scan to add an item")
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
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
          
          Section {
            
            if container.canScanTags {
              Button {
                Task { try? await container.verifyTag() }
              } label: {
                HStack(alignment: .center, spacing: 0) {
                  VStack(alignment: .leading) {
                    Text("Check Tag").font(.headline)
                  }
                  Spacer()
                  Image(systemName: "sensor.tag.radiowaves.forward")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36, alignment: .center)
                    .clipped()
                }
              }
            }
            
            Button("Remove Tag") {
              container.removeTag()
            }
          }
          
          Section {
            Button("Change Location") {}
            Button("Remove from Location") {}
          }
          
          if container.canScanTags {
            Section {
              Button("Add to Contents") {
                Task {
                  do {
                    try await container.addContainedItem()
                  } catch {
                    os_log("Error? \(error)")
                  }
                }
              }
            }
          }
          
        } label: {
          Image(systemName: "ellipsis.circle")
        }
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
    let previewItem = Container(context: context)
    previewItem.name = "Preview 123"
    previewItem.tagID = "test"

    let fakeLocation = Container(context: context)
    fakeLocation.name = "Location"

    let fakeItem = Container(context: context)
    fakeItem.name = "Item"

    let containedHistory = ContainerHistory(context: context)
    containedHistory.item = previewItem
    containedHistory.containedIn = fakeLocation
    containedHistory.created = Date()

    let containsHistory = ContainerHistory(context: context)
    containsHistory.item = fakeItem
    containsHistory.containedIn = previewItem
    containsHistory.created = Date()

    return NavigationView { ContainerView(container: previewItem).environment(\.managedObjectContext, context) }
  }
}
