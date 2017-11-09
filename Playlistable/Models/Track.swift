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
  var albumID: String
  var artistIDs: [String]
  let images: [Image]
  let durationMS: Int
  let name: String
  let previewURL: String
  
  var largeImageURL: URL? {
    get {
      return images.first(where: { $0.height >= 640 })?.url ?? mediumImageURL ?? smallImageURL
    }
  }
  
  var mediumImageURL: URL? {
    get {
      return images.first(where: { $0.height >= 300 && $0.height < 640 })?.url ?? smallImageURL
    }
  }
  
  var smallImageURL: URL? {
    get {
      return images.first(where: {$0.height <= 64 })?.url
    }
  }
}
