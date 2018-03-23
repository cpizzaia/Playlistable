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
  var isPausing: Bool
  var isPaused: Bool
  var queueTrackIDs: [String]
  
  // MARK: Selectors
  var isPlayingQueue: Bool {
    get {
      return !queueTrackIDs.isEmpty
    }
  }
  
  var positionOfCurrentTrackInQueue: Int? {
    get {
      guard let trackID = playingTrackID else { return nil }
      return queueTrackIDs.index(of: trackID)
    }
  }
  
  var isPlayingTrackInQueue: Bool {
    get {
      return positionOfCurrentTrackInQueue != nil
    }
  }
  
  var isPlayingFirstTrackInQueue: Bool {
    get {
      return positionOfCurrentTrackInQueue == queueTrackIDs.startIndex
    }
  }
  
  var isPlayingLastTrackInQueue: Bool {
    get {
      guard let currentPosition = positionOfCurrentTrackInQueue else { return false }
      return currentPosition - 1 == queueTrackIDs.endIndex
    }
  }
}

fileprivate let initialSpotifyPlayerState = SpotifyPlayerState(
  isInitialized: false,
  playingTrackID: nil,
  isPlaying: false,
  isStartingToPlay: false,
  isPausing: false,
  isPaused: false,
  queueTrackIDs: []
)

func spotifyPlayerReducer(action: Action, state: SpotifyPlayerState?) -> SpotifyPlayerState{
  var state = state ?? initialSpotifyPlayerState
  
  switch action {
  case _ as SpotifyPlayerActions.InitializedPlayer:
    state.isInitialized = true
  case _ as SpotifyPlayerActions.PlayTrack:
    state.isStartingToPlay = true
  case let action as SpotifyPlayerActions.PlayingTrack:
    state.playingTrackID = action.trackID
    state.isPlaying = true
    state.isStartingToPlay = false
    state.isPaused = false
  case _ as SpotifyPlayerActions.StoppedPlaying:
    state.isPlaying = false
  case let action as SpotifyPlayerActions.PlayQueue:
    state.queueTrackIDs = action.trackIDs
  case _ as SpotifyPlayerActions.Paused:
    state.isPaused = true
    state.isPlaying = false
    state.isPausing = false
  case _ as SpotifyPlayerActions.Pausing:
    state.isPausing = true
  case _ as SpotifyPlayerActions.Resumed:
    state.isPlaying = true
    state.isPaused = false
  default:
    break
  }
  
  return state
}
