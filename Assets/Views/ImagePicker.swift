//
//  ImagePicker.swift
//  Assets
//
//  Created by Apple.
//

import Foundation
import SwiftUI

/// This struct wraps a `UIImagePickerController` for use in SwiftUI.
struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: UIImage?
  @Environment(\.presentationMode) var presentationMode

  func updateUIViewController(_: UIViewControllerType, context _: Context) {}

  func makeUIViewController(context: Context) -> some UIViewController {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = context.coordinator
    return imagePickerController
  }

  func makeCoordinator() -> ImagePicker.Coordinator {
    Coordinator(parent: self)
  }

  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker

    init(parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      DispatchQueue.main.async {
        self.parent.selectedImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        self.parent.presentationMode.wrappedValue.dismiss()
      }
    }
  }
}
