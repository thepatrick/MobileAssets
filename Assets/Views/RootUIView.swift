//
//  RootUIView.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 4/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct RootUIView: View {
  var body: some View {
    TabView {
      ItemListView()
//        .badge(10)
        .tabItem {
          Image(systemName: "tag.fill")
          Text("Items")
        }
      LocationListView()
        .tabItem {
          Image(systemName: "bag.fill")
          Text("Containers")
        }
      MoreView()
        .tabItem {
          Image(systemName: "ellipsis")
          Text("More")
        }
    }
  }
}

struct RootUIView_Previews: PreviewProvider {
  static var previews: some View {
    RootUIView()
  }
}
