//
//  Playlist.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/14/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation

struct Playlist: Item {
  let trackIDs: [String]
  let name: String
  let id: String

  // Item Protocol
  var title: String {
    return name
  }

  var subTitle: String? {
    return nil
  }

  var images: [Image]
}
