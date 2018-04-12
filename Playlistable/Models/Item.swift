//
//  BrowsableItem.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/8/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

protocol Item {
  var title: String { get }
  var subTitle: String? { get }
  var images: [Image] { get }
  var id: String { get }
}

extension Item {
  var largeImageURL: URL? {
    return images.first(where: { $0.height >= 800 })?.url ?? mediumImageURL ?? smallImageURL
  }

  var mediumImageURL: URL? {
    return images.first(where: { $0.height >= 300 && $0.height < 800 })?.url ?? smallImageURL
  }

  var smallImageURL: URL? {
    return images.first(where: {$0.height <= 300 })?.url
  }

  var hasImages: Bool {
    return !images.isEmpty
  }
}
