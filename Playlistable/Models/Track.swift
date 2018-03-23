//
//  Track.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

struct Track: Item {
  let id: String
  var albumID: String
  var artistIDs: [String]
  let images: [Image]
  let durationMS: Int
  let name: String
  let previewURL: String?
  let artistNames: [String]

  // BrowsableItem Properties
  var title: String {
    return name
  }

  var subTitle: String? {
    return artistNames.joined(separator: " + ")
  }
}
