//
//  SavedBits.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 12/6/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

//            if let image = item.photo {
//              Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 64, height: 64, alignment: .center)
//                .clipped()
//            } else {
//              Image(systemName: "person.circle")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 64, height: 64, alignment: .center)
//                .foregroundColor(.gray)
//            }

//  var itemImage: some View {
//    if let image = item.photo {
//      return AnyView(Image(uiImage: image)
//        .resizable()
//        .scaledToFill()
//        .frame(width: 64, height: 64, alignment: .center)
//        .clipped())
//    } else {
//      return AnyView(Image(systemName: "photo")
//        .resizable()
//        .aspectRatio(contentMode: .fit)
//        .frame(width: 64, height: 64, alignment: .center)
//        .foregroundColor(.gray))
//    }
//  }

//      Section("Location") {
//        Button {} label: {
//          HStack(alignment: .center, spacing: 0) {
//            VStack(alignment: .leading) {
//              Text("Desk").font(.headline)
//              Text("Set \(Date.now.formatted())").font(.footnote).foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            Image(systemName: "info.circle")
//              .resizable()
//              .scaledToFill()
//              .frame(width: 24, height: 24, alignment: .center)
//              .clipped()
//          }
//        }
//
//        Button("Clear Location") {}.foregroundColor(.red)
//        Button("Set New Location") {}.foregroundColor(.red)
//      }
//
//      Section("Location") {
//        Button("Set New Location") {}.foregroundColor(.red)
//      }

//      Section {
//        if let image = item.photo {
//          AnyView(Image(uiImage: image)
//            .resizable()
//            .scaledToFill()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .clipped()
//            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
//          )
//        } else {
//          AnyView(Image(systemName: "photo")
//            .resizable()
//            .scaledToFill()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .clipped()
//            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
//          )
//        }
//      }.scaleEffect(x: 1.1, y: 1.1, anchor: .center)
