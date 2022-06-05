//
//  TagHomeView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 5/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreNFC
import SwiftUI

struct MoreView: View {
  var body: some View {
    NavigationView {
      List {
        Section("Tags") {
          if NFCReaderSession.readingAvailable {
            NavigationLink("Scan Tag") {
              ScanTagsView()
            }
            Text("Setup Tags")
          } else {
            Text("NFC not available")
          }
        }
      }
      .navigationTitle("More")
    }
  }
}

struct MoreView_Previews: PreviewProvider {
  static var previews: some View {
    MoreView()
  }
}
