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
  var trackIDs: [String] {
    didSet { // Storing them for when someone quits out of the app
      UserDefaults.standard.set(trackIDs, forKey: UserDefaultsKeys.storedPlaylistTrackIDs)
    }
  }
  var isGenerating: Bool
  var playlistID: String?
  var seedsUsed: SeedsState? {
    didSet { // Storing them for when someone quits out of the app
      guard let seedsUsed = seedsUsed else { return }

      let artistIDs = seedsUsed.items.compactMap { key, value in
        return value is Artist ? key : nil
      }

      let trackIDs = seedsUsed.items.compactMap { key, value in
        return value is Track ? key : nil
      }

      UserDefaults.standard.set(artistIDs, forKey: UserDefaultsKeys.storedArtistSeedIDs)
      UserDefaults.standard.set(trackIDs, forKey: UserDefaultsKeys.storedTrackSeedIDs)
    }
  }
}

private let initialGeneratedPlaylistState = GeneratedPlaylistState(
  trackIDs: [],
  isGenerating: false,
  playlistID: nil,
  seedsUsed: nil
)

func generatedPlaylistReducer(action: Action, state: GeneratedPlaylistState?) -> GeneratedPlaylistState {
  var state = state ?? initialGeneratedPlaylistState

  switch action {
  case _ as GeneratePlaylistActions.RequestTracksFromSeeds:
    state.isGenerating = true
  case let action as GeneratePlaylistActions.ReceiveTracksFromSeeds:
    state.isGenerating = false
    state.trackIDs = action.response["tracks"].array?.compactMap({ $0["id"].string }) ?? []
  case let action as SeedsActions.GeneratedFromSeeds:
    state.seedsUsed = action.seeds
  case _ as GeneratePlaylistActions.ErrorTracksFromSeeds:
    state.isGenerating = false
  case let action as GeneratePlaylistActions.ReceiveStoredSeedsState:
    state.seedsUsed = action.seeds
  case let action as GeneratePlaylistActions.ReceiveStoredPlaylistTracks:
    state.trackIDs = action.response["tracks"].array?.compactMap({ $0["id"].string }) ?? []
  case let action as GeneratePlaylistActions.ReceiveCreatePlaylist:
    state.playlistID = action.response["id"].string
  default:
    break
  }

  return state
}
