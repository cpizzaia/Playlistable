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
  typealias PlaylistID = String

  var tracks: [TrackID: Track]
  var albums: [AlbumID: Album]
  var artists: [ArtistID: Artist]
  var playlists: [PlaylistID: Playlist]

  func trackFor(id: TrackID) -> Track? {
    return tracks[id]
  }

  func tracksFor(ids: [TrackID]) -> [Track] {
    return ids.compactMap(trackFor)
  }

  func albumFor(id: AlbumID) -> Album? {
    return albums[id]
  }

  func albumsFor(ids: [AlbumID]) -> [Album] {
    return ids.compactMap(albumFor)
  }

  func artistFor(id: ArtistID) -> Artist? {
    return artists[id]
  }

  func artistsFor(ids: [ArtistID]) -> [Artist] {
    return ids.compactMap(artistFor)
  }

  func playlistFor(id: PlaylistID) -> Playlist? {
    return playlists[id]
  }

  func playlistsFor(ids: [PlaylistID]) -> [Playlist] {
    return ids.compactMap(playlistFor)
  }
}

private let initialResourceState = ResourceState(
  tracks: [:],
  albums: [:],
  artists: [:],
  playlists: [:]
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
  case let action as ResourceActions.ReceivePlaylists:
    action.playlists.forEach({ state = updateOrAdd(item: $0, toState: state) })
  case let action as ResourceActions.UpdatePlaylist:
    state.playlists[action.playlist.id] = action.playlist
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
  case let item as Playlist:
    if shouldUpdate(item: item, forItemInState: state.playlists[item.id]) {
      state.playlists[item.id] = item
    }
  default:
    break
  }

  return state
}

private func shouldUpdate(item: Item, forItemInState itemInState: Item?) -> Bool {
  guard let itemInState = itemInState else { return true }

  return !itemInState.hasImages
}
