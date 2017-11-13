//
//  SpotifyPlayerReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct SpotifyPlayerState {
  var isInitialized: Bool
  var playingTrackID: String?
  var isPlaying: Bool
}

fileprivate let initialSpotifyPlayerState = SpotifyPlayerState(isInitialized: false, playingTrackID: nil, isPlaying: false)

func spotifyPlayerReducer(action: Action, state: SpotifyPlayerState?) -> SpotifyPlayerState{
  var state = state ?? initialSpotifyPlayerState
  
  switch action {
  case _ as InitializedPlayer:
    state.isInitialized = true
  case let action as PlayingTrack:
    state.playingTrackID = action.trackID
    state.isPlaying = true
  default:
    break
  }
  
  return state
}
