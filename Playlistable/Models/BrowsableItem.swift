//
//  BrowsableItem.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/8/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

protocol BrowsableItem {
  var title: String { get }
  var images: [Image] { get }
}

extension BrowsableItem {
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
