//
//  Album.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

struct Album: Item {
  let id: String
  let artistIDs: [String]
  let trackIDs: [String]
  let images: [Image]
  let name: String
  let artistNames: [String]

  // BrowsableItem Properties
  var title: String {
    return name
  }

  var subTitle: String? {
    return artistNames.joined(separator: " + ")
  }
}
