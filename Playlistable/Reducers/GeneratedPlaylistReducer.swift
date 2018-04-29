//
//  GeneratedPlaylistReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct GeneratedPlaylistState {
  var isGenerating: Bool
  var trackIDsGeneratedFromSeeds: [String]
  var playlistID: String? {
    didSet {
      if playlistID == nil { return }

      MyUserDefaults.storedGeneratedPlaylistID = playlistID
    }
  }
  var seedsUsed: SeedsState? {
    didSet { // Storing them for when someone quits out of the app
      guard let seedsUsed = seedsUsed else { return }

      let artistIDs = seedsUsed.items.compactMap { key, value in
        return value is Artist ? key : nil
      }

      let trackIDs = seedsUsed.items.compactMap { key, value in
        return value is Track ? key : nil
      }

      MyUserDefaults.storedArtistSeedIDs = artistIDs
      MyUserDefaults.storedTrackSeedIDs = trackIDs
    }
  }
}

private let initialGeneratedPlaylistState = GeneratedPlaylistState(
  isGenerating: false,
  trackIDsGeneratedFromSeeds: [],
  playlistID: nil,
  seedsUsed: nil
)

func generatedPlaylistReducer(action: Action, state: GeneratedPlaylistState?) -> GeneratedPlaylistState {
  var state = state ?? initialGeneratedPlaylistState

  switch action {
  case let action as GeneratePlaylistActions.ReceiveTracksFromSeeds:
    state.trackIDsGeneratedFromSeeds = action.response["tracks"].array?.compactMap({ $0["id"].string }) ?? []
  case _ as GeneratePlaylistActions.GeneratingPlaylist:
    state.isGenerating = true
  case _ as GeneratePlaylistActions.GeneratedPlaylist:
    state.isGenerating = false
  case let action as SeedsActions.GeneratedFromSeeds:
    state.seedsUsed = action.seeds
  case let action as GeneratePlaylistActions.ReceiveCreateGeneratedPlaylist:
    state.playlistID = action.response["id"].string
  case let action as GeneratePlaylistActions.ReceiveStoredPlaylist:
    state.playlistID = action.response["id"].string
  case let action as GeneratePlaylistActions.ReceiveStoredSeedsState:
    state.seedsUsed = action.seeds
  default:
    break
  }

  return state
}
