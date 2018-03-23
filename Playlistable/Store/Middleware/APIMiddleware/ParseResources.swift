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

private struct ResourceType {
  static let artist = "artist"
  static let track = "track"
  static let album = "album"
}

private struct ResourceCollection {
  let artists: [JSON]
  let albums: [JSON]
  let tracks: [JSON]

  func merged(withCollection collection: ResourceCollection) -> ResourceCollection {
    return ResourceCollection(
      artists: artists + collection.artists,
      albums: albums + collection.albums,
      tracks: tracks + collection.tracks
    )
  }
}

func parseResources(fromJSON json: JSON, next: @escaping DispatchFunction) {
  let resources = gatherResources(fromJSON: json)

  next(ResourceActions.ReceiveTracks(tracks:
    TrackFactory.createTracks(fromJSONArray: resources.tracks))
  )
  next(ResourceActions.ReceiveAlbums(albums:
    AlbumFactory.createAlbums(fromJSONArray: resources.albums))
  )
  next(ResourceActions.ReceiveArtists(artists:
    ArtistFactory.createArtists(fromJSONArray: resources.artists))
  )
}

private func gatherResources(fromJSON json: JSON) -> ResourceCollection {
  var resources = ResourceCollection(artists: [], albums: [], tracks: [])

  json.forEach { key, value in
    if let type = value.string, key == "type" {
      resources = parse(type: type, fromJSON: json).merged(withCollection: resources)
    }

    resources = gatherResources(fromJSON: value).merged(withCollection: resources)
  }

  return resources
}

private func parse(type: String, fromJSON json: JSON) -> ResourceCollection {
  switch type {
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
