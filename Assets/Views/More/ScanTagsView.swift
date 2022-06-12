//
//  ScanTagsView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 5/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import CoreData
#if canImport(CoreNFC)
import CoreNFC
#endif
import SwiftUI

struct ScannedTags: Identifiable {
  let id = UUID()
  let tagID: String
  let object: RelatedObject

  enum RelatedObject {
    case container(container: Container)
    case none
  }

  init(context: NSManagedObjectContext, tagID: String) {
    self.tagID = tagID

    if let container = try? Container.findByTagID(tagID: tagID, in: context) {
      object = .container(container: container)
    } else {
      object = .none
    }
  }
}

// TODO: Make ScannedTags look to see if they are attached to an item or location, and if so link to that

struct ScanTagsView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State var scannedTags: [ScannedTags] = []
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
        if scannedTags.isEmpty {
          Text("No Tags Scanned Yet").foregroundColor(.secondary)
        }
        ForEach(scannedTags.reversed()) { tag in
          switch tag.object {
          case let .container(container):
            Text("Container: \(container.name ?? "(no name)")")
          case .none:
            Text("Tag: \(tag.tagID)")
          }
        }
      }
    }
    .navigationTitle("Scan Tags")
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
      let thing = try await AssetTags().verifyOneTag()
      lastError = nil
      scannedTags.append(ScannedTags(context: viewContext, tagID: thing))
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

struct ScanTagsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ScanTagsView()
    }
  }
}
