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
  var isStartingToPlay: Bool
  var queueTrackIDs: [String]
  
  var isPlayingQueue: Bool {
    get {
      return !queueTrackIDs.isEmpty
    }
  }
}

fileprivate let initialSpotifyPlayerState = SpotifyPlayerState(
  isInitialized: false,
  playingTrackID: nil,
  isPlaying: false,
  isStartingToPlay: false,
  queueTrackIDs: []
)

func spotifyPlayerReducer(action: Action, state: SpotifyPlayerState?) -> SpotifyPlayerState{
  var state = state ?? initialSpotifyPlayerState
  
  switch action {
  case _ as InitializedPlayer:
    state.isInitialized = true
  case _ as PlayTrack:
    state.isStartingToPlay = true
  case let action as PlayingTrack:
    state.playingTrackID = action.trackID
    state.isPlaying = true
    state.isStartingToPlay = false
  case _ as StoppedPlaying:
    state.isPlaying = false
  case let action as PlayQueue:
    state.queueTrackIDs = action.trackIDs
  default:
    break
  }
  
  return state
}
