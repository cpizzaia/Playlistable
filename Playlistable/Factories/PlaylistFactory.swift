//
//  PlaylistFactory.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/14/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PlaylistFactory {
  static func createPlaylists(fromJSONArray jsonArray: [JSON]) -> [Playlist] {
    return jsonArray.compactMap(createPlaylist)
  }

  static func createPlaylist(fromJSON json: JSON) -> Playlist? {
    guard
      let id = json["id"].string,
      let tracks = json["tracks"]["items"].array
    else {
      return nil
    }

    return Playlist(
      trackIDs: tracks.compactMap { $0["track"]["id"].string },
      name: json["name"].string ?? "",
      id: id,
      images: ImageFactory.createImages(fromJSONArray: json["images"].array ?? [])
    )
  }
}
