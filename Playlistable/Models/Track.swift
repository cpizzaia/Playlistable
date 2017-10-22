//
//  Track.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

struct Track {
  let id: String
  let albumID: String
  let artistIDs: [String]
  let images: [Image]
  let durationMS: Int
  let name: String
  let previewURL: String
}
