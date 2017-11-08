//
//  ResourceReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct ResourceState {
  typealias TrackID = String
  typealias AlbumID = String
  typealias ArtistID = String
  
  var tracks: [TrackID: Track]
  var albums: [AlbumID: Album]
  var artists: [ArtistID: Artist]
  
  func tracksFor(ids: [TrackID]) -> [Track] {
    return ids.flatMap { id in
      return tracks[id]
    }
  }
  
  func albumsFor(ids: [AlbumID]) -> [Album] {
    return ids.flatMap { id in
      return albums[id]
    }
  }
  
  func artistsFor(ids: [ArtistID]) -> [Artist] {
    return ids.flatMap { id in
      return artists[id]
    }
  }
}

fileprivate let initialResourceState = ResourceState(
  tracks: [:],
  albums: [:],
  artists: [:]
)

func resourceReducer(action: Action, state: ResourceState?) -> ResourceState {
  var state = state ?? initialResourceState
  
  switch action {
  case let action as ReceiveTracks:
    action.tracks.forEach({ state.tracks[$0.id] = $0 })
  case let action as ReceiveAlbums:
    action.albums.forEach({ state.albums[$0.id] = $0 })
  case let action as ReceiveArtists:
    action.artists.forEach({ state.artists[$0.id] = $0 })
  default: break
  }
  
  return state
}
