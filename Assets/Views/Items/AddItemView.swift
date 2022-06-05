//
//  AddItemView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 2/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct AddItemView: View {
  @State private var image: UIImage?
  @State private var isShowingImagePicker: Bool = false
  @State private var titleInput: String = ""

  /// Callback after user selects to add contact with given name and image.
  let onAdd: ((String, UIImage?) -> Void)?

  /// Callback after user cancels.
  let onCancel: (() -> Void)?

  var body: some View {
    NavigationView {
      VStack {
        HStack {
          contactImage.onTapGesture {
            self.isShowingImagePicker = true
          }
          TextField("Title", text: $titleInput)
            .textContentType(.name)
        }
        Spacer()
      }
      .padding()
      .navigationTitle("Add Item")
      .navigationBarTitleDisplayMode(.large)
      .sheet(isPresented: $isShowingImagePicker) {
        isShowingImagePicker = false
      } content: {
        ImagePicker(selectedImage: $image)
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: { onCancel?() })
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add", action: { onAdd?(titleInput, image) })
            .disabled(titleInput.isEmpty)
        }
//        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
//                Label("", systemImage: "icloud.and.arrow.up.fill")
//                    .foregroundColor(.white)
//                    .frame(width: 30, height: 30, alignment: .center)
//            }
//        ToolbarItem(placement: .) {
//          Button("AddX", action: { onAdd?(titleInput, image) })
//            .disabled(titleInput.isEmpty)
//        }
      }
    }
  }

  var contactImage: some View {
    if let image = image {
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

struct AddItemView_Previews: PreviewProvider {
  static var previews: some View {
    AddItemView(onAdd: { _, _ in }, onCancel: {})
  }
}
