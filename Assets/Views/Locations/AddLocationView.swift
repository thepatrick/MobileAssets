//
//  AddLocationView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct AddLocationView: View {
  @State private var name: String = ""

  /// Callback after user selects to add contact with given name and image.
  let onAdd: ((String) -> Void)?

  /// Callback after user cancels.
  let onCancel: (() -> Void)?

  var body: some View {
    NavigationView {
      List {
        Section {
          TextField("Name", text: $name)
            .textContentType(.name)
        }

//        Section("Tag") {
//          Button("Add Tag") {}.foregroundColor(.red)
//        }
//
//        Section("Tag") {
//          Button {} label: {
//            HStack(alignment: .center, spacing: 0) {
//              VStack(alignment: .leading) {
//                Text("Check").font(.headline)
//                Text("Last seen \(Date.now.formatted())").font(.footnote).foregroundColor(.secondary)
//              }
//
//              Spacer()
//
//              Image(systemName: "sensor.tag.radiowaves.forward")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 36, height: 24, alignment: .center)
//                .clipped()
//            }
//          }
//
//          Button("Remove Tag") {}.foregroundColor(.red)
//        }
      }
      .navigationTitle("Add Container")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: { onCancel?() })
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add", action: { onAdd?(name) })
            .disabled(name.isEmpty)
        }
      }
    }
  }
}

struct AddLocationView_Previews: PreviewProvider {
  static var previews: some View {
    AddLocationView { _ in

    } onCancel: {}
  }
}
