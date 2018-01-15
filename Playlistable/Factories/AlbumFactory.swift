//
//  AlbumFactory.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AlbumFactory {
  static func createAlbums(fromJSONArray jsonArray: [JSON]) -> [Album] {
    return jsonArray.flatMap({ createAlbum(fromJSON: $0) })
  }
  
  static func createAlbum(fromJSON json: JSON) -> Album? {
    guard let id = json["id"].string, let name = json["name"].string else {
      return nil
    }
    
    return Album(
      id: id,
      artistIDs: [],
      trackIDs: json["tracks"]["items"].array?.flatMap { $0["id"].string } ?? [],
      images: ImageFactory.createImages(fromJSONArray: json["images"].array ?? []),
      name: name
    )
  }
}
