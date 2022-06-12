//
//  TagHomeView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 5/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

#if canImport(CoreNFC)
  import CoreNFC
#endif

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
            NavigationLink("Setup Tags") {
              SetupTagsView()
            }
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
