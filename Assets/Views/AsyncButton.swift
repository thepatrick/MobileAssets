//
//  AsyncButton.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
  var action: () async -> Void
  @ViewBuilder var label: () -> Label

  @State private var isPerformingTask = false

  var body: some View {
    Button(
      action: {
        isPerformingTask = true

        Task {
          await action()
          isPerformingTask = false
        }
      },
      label: {
        ZStack {
          // We hide the label by setting its opacity
          // to zero, since we don't want the button's
          // size to change while its task is performed:
          label().opacity(isPerformingTask ? 0 : 1)

          if isPerformingTask {
            ProgressView()
          }
        }
      }
    )
    .disabled(isPerformingTask)
  }
}

struct AsyncButton_Previews: PreviewProvider {
  static var previews: some View {
    AsyncButton {
      print("button clicked")
    } label: {
      Text("Button")
    }
  }
}
