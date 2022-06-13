//
//  RelatedItemView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 13/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct RelatedItemView: View {
  let item: Container
  let created: Date?
  
  var body: some View {
    NavigationLink(value: item) {
      VStack(alignment: .leading) {
        Text(item.wrappedName).font(.headline)
        Text(created?.formatted() ?? "(unknown)").font(.footnote).foregroundColor(.secondary)
      }
    }
  }
}
