//
//  Artist.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

struct Artist: Item {
  let id: String
  let images: [Image]
  let name: String

  // BrowsableItem Properties
  var title: String {
    return name
  }

  var subTitle: String? {
    return nil
  }
}
