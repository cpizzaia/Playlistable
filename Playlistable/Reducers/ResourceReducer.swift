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

  func albumFor(id: AlbumID) -> Album? {
    return albums[id]
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

private let initialResourceState = ResourceState(
  tracks: [:],
  albums: [:],
  artists: [:]
)

func resourceReducer(action: Action, state: ResourceState?) -> ResourceState {
  var state = state ?? initialResourceState

  switch action {
  case let action as ResourceActions.ReceiveTracks:
    action.tracks.forEach({ state = updateOrAdd(item: $0, toState: state) })
  case let action as ResourceActions.ReceiveAlbums:
    action.albums.forEach({ state = updateOrAdd(item: $0, toState: state)})
  case let action as ResourceActions.ReceiveArtists:
    action.artists.forEach({ state = updateOrAdd(item: $0, toState: state) })
  default: break
  }

  return state
}

private func updateOrAdd(item: Item, toState state: ResourceState) -> ResourceState {
  var state = state

  switch item {
  case let item as Track:
    if shouldUpdate(item: item, forItemInState: state.tracks[item.id]) {
      state.tracks[item.id] = item
    }
  case let item as Album:
    if shouldUpdate(item: item, forItemInState: state.albums[item.id]) {
      state.albums[item.id] = item
    }
  case let item as Artist:
    if shouldUpdate(item: item, forItemInState: state.artists[item.id]) {
      state.artists[item.id] = item
    }
  default:
    break
  }

  return state
}

private func shouldUpdate(item: Item, forItemInState itemInState: Item?) -> Bool {
  guard let itemInState = itemInState else { return true }

  return itemInState.smallImageURL == nil
}
