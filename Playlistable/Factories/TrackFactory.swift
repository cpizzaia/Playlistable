//
//  TrackFactory.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TrackFactory {
  static func createTracks(fromJSONArray jsonArray: [JSON]) -> [Track] {
    return jsonArray.compactMap({ createTrack(fromJSON: $0) })
  }

  static func createTrack(fromJSON json: JSON) -> Track? {
    guard
      let id = json["id"].string,
      let durationMS = json["duration_ms"].int,
      let name = json["name"].string else {
        return nil
    }

    return Track(
      id: id,
      albumID: "",
      artistIDs: [],
      images: ImageFactory.createImages(fromJSONArray: json["album"]["images"].array ?? []),
      durationMS: durationMS,
      name: name,
      previewURL: json["preview_url"].string,
      artistNames: json["artists"].array?.compactMap { $0["name"].string } ?? []
    )
  }
}
