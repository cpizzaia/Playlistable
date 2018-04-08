//
//  ArtistFactory.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ArtistFactory {
  static func createArtists(fromJSONArray jsonArray: [JSON]) -> [Artist] {
    return jsonArray.compactMap({ createArtist(fromJSON: $0) })
  }

  static func createArtist(fromJSON json: JSON) -> Artist? {
    guard
      let id = json["id"].string,
      let name = json["name"].string else {
        return nil
    }

    return Artist(
      id: id,
      images: ImageFactory.createImages(fromJSONArray: json["images"].array ?? []),
      name: name
    )
  }
}
