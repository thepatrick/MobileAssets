//
//  SetupTagsView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 5/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

#if canImport(CoreNFC)
import CoreNFC
#endif
import os.log
import SwiftUI

struct SetupTagsView: View {
  @State var scannedTags: Int = 0
  @State var lastError: String?

  var body: some View {
    List {
      if let lastError = lastError {
        Section {
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
            VStack(alignment: .leading, spacing: 0) {
              Text(lastError)
            }
          }
        }
      }

      Section {
        if scannedTags == 0 {
          Text("No Tags Scanned Yet").foregroundColor(.secondary)
        } else {
          Text("Setup \(scannedTags) tags")
        }
      }
    }
    .navigationTitle("Setup Tags")
    .toolbar {
      ToolbarItem {
        AsyncButton {
          await self.scanTag()
        } label: {
          Text("Scan")
        }
      }
    }
    .onAppear {
      Task {
        await scanTag()
      }
    }
  }

  func scanTag() async {
    var cancelled = false
    do {
      let thing = try await AssetTags().setupOneTag()
      os_log("Added tag \(thing)")
      lastError = nil
      scannedTags += 1
    } catch let error as NFCReaderError {
      lastError = error.localizedDescription
    } catch let error as TagErrors {
      if error == TagErrors.NoTagPresented {
        cancelled = true
      } else {
        lastError = error.localizedDescription
      }
    } catch {
      lastError = "An unexpected error ocurred, try again."
    }
    if !cancelled {
      Task.delayed(byTimeInterval: 4) {
        await scanTag()
      }
    }
  }
}

struct SetupTagsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SetupTagsView()
    }
  }
}
