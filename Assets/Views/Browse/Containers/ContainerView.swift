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

        StatusRow(feature: "Serial number", isOK: false)

        StatusRow(feature: "Has location", isOK: container.currentLocation != nil)
      }

      if container.canScanTags, container.tagID == nil {
        Section("Tag") {
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

      Section("Location") {
        if let location = container.currentLocation {
          RelatedItemView(item: location, created: container.currentLocationAdded)
        } else {
          if container.canScanTags {
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
          Text("TODO: Allow adding by search").font(.footnote).foregroundColor(.secondary).disabled(true)
        }
      }

      Section("Contains") {
        if !container.containedItems.isEmpty {
          ForEach(container.containedItems, id: \.self) { history in
            if let c = history.item {
              RelatedItemView(item: c, created: history.created)
            }
          }
        }

        if container.canScanTags {
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
        Text("TODO: Allow adding by search").font(.footnote).foregroundColor(.secondary).disabled(true)
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Edit", action: {
          os_log("Edit!")
        })
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
          Section("Tag") {
            if container.tagID == nil {
              if container.canScanTags {
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

            } else {
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
          }

          Section {
            if let containedIn = container.currentLocation {
              Button("Remove from \(containedIn.wrappedName)") {
                container.removeFromCurrentLocation()
              }
            } else if container.canScanTags {
              AsyncButton(action: {
                do {
                  try await container.addToLocation()
                } catch {
                  os_log("Error? \(error)")
                }
              }) {
                Text("Add Location")
              }
            }
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

    previewItem.location = fakeLocation

    let containsHistory = ContainerHistory(context: context)
    containsHistory.item = fakeItem
    containsHistory.containedIn = previewItem
    containsHistory.created = Date()

    return NavigationView {
      ContainerView(container: previewItem).environment(\.managedObjectContext, context)
    }
  }
}
