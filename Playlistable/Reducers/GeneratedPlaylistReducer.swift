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
  var trackIDs: [String]
  var isGenerating: Bool
  var seedsUsed: SeedsState?
}

private let initialGeneratedPlaylistState = GeneratedPlaylistState(trackIDs: [], isGenerating: false, seedsUsed: nil)

func generatedPlaylistReducer(action: Action, state: GeneratedPlaylistState?) -> GeneratedPlaylistState {
  var state = state ?? initialGeneratedPlaylistState

  switch action {
  case _ as GeneratePlaylistActions.RequestGeneratePlaylist:
    state.isGenerating = true
  case let action as GeneratePlaylistActions.ReceiveGeneratePlaylist:
    state.isGenerating = false
    state.trackIDs = action.response["tracks"].array?.compactMap({ $0["id"].string }) ?? []
  case let action as SeedsActions.GeneratedFromSeeds:
    state.seedsUsed = action.seeds
  case _ as GeneratePlaylistActions.ErrorGeneratePlaylist:
    state.isGenerating = false
  default:
    break
  }

  return state
}
