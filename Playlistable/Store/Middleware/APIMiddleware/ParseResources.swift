//
//  ParseResources.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/5/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReSwift

fileprivate struct ResourceType {
  static let artist = "artist"
  static let track = "track"
  static let album = "album"
}

fileprivate struct ResourceCollection {
  let artists: [JSON]
  let albums: [JSON]
  let tracks: [JSON]
  
  func merge(withCollection collection: ResourceCollection) -> ResourceCollection {
    return ResourceCollection(
      artists: artists + collection.artists,
      albums: albums + collection.albums,
      tracks: tracks + collection.tracks
    )
  }
}

func parseResources(fromJSON json: JSON, next: @escaping DispatchFunction) {
  let resources = gatherResources(fromJSON: json)
  
  next(ReceiveTracks(tracks:
    TrackFactory.createTracks(fromJSONArray: resources.tracks))
  )
  next(ReceiveAlbums(albums:
    AlbumFactory.createAlbums(fromJSONArray: resources.albums))
  )
  next(ReceiveArtists(artists:
    ArtistFactory.createArtists(fromJSONArray: resources.artists))
  )
}

fileprivate func gatherResources(fromJSON json: JSON) -> ResourceCollection {
  var resources = ResourceCollection(artists: [], albums: [], tracks: [])
  
  json.forEach { key, value in
    if let type = value.string, key == "type" {
      resources = parse(type: type, fromJSON: json).merge(withCollection: resources)
    }
    
    resources = gatherResources(fromJSON: value).merge(withCollection: resources)
  }
  
  return resources
}

fileprivate func parse(type: String, fromJSON json: JSON) -> ResourceCollection {
  switch (type) {
  case ResourceType.artist:
    return ResourceCollection(artists: [json], albums: [], tracks: [])
  case ResourceType.album:
    return ResourceCollection(artists: [], albums: [json], tracks: [])
  case ResourceType.track:
    return ResourceCollection(artists: [], albums: [], tracks: [json])
  default:
    return ResourceCollection(artists: [], albums: [], tracks: [])
  }
}
