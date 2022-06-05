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
        Text(container.name)
          .navigationTitle(container.name)
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
//                Text("Last seen \(Date.now.formatted())").font(.footnote).foregroundColor(.red) // .foregroundColor(.secondary)
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
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Edit", action: {
          os_log("Edit!")
        }) // .disabled(!vm.isLoaded)
      }
    }
  }
}

struct ContainerView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let container = Container(context: context)
    container.name = "Preview 123"

    return NavigationView { ContainerView(container: container).environment(\.managedObjectContext, context) }
  }
}
