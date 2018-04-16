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
  var nextTrackID: String?
  var previousTrackID: String?
  var isPlaying: Bool
  var isStartingToPlay: Bool
  var isPausing: Bool
  var isPaused: Bool
}

private let initialSpotifyPlayerState = SpotifyPlayerState(
  isInitialized: false,
  playingTrackID: nil,
  nextTrackID: nil,
  previousTrackID: nil,
  isPlaying: false,
  isStartingToPlay: false,
  isPausing: false,
  isPaused: false
)

func spotifyPlayerReducer(action: Action, state: SpotifyPlayerState?) -> SpotifyPlayerState {
  var state = state ?? initialSpotifyPlayerState

  switch action {
  case _ as SpotifyPlayerActions.InitializedPlayer:
    state.isInitialized = true
  case _ as SpotifyPlayerActions.PlayPlaylist:
    state.isStartingToPlay = true
  case _ as SpotifyPlayerActions.PlayingPlaylist:
    state.isStartingToPlay = false
  case _ as SpotifyPlayerActions.ErrorPlayingPlaylist:
    state.isStartingToPlay = false
  case let action as SpotifyPlayerActions.PlayingTrack:
    state.playingTrackID = action.trackID
    state.isPlaying = true
    state.isStartingToPlay = false
    state.isPaused = false
  case _ as SpotifyPlayerActions.StoppedPlaying:
    state.isPlaying = false
  case _ as SpotifyPlayerActions.Paused:
    state.isPaused = true
    state.isPlaying = false
    state.isPausing = false
  case _ as SpotifyPlayerActions.Pausing:
    state.isPausing = true
  case _ as SpotifyPlayerActions.Resumed:
    state.isPlaying = true
    state.isPaused = false
  case let action as SpotifyPlayerActions.NewNextTrack:
    state.nextTrackID = action.trackID
  case let action as SpotifyPlayerActions.NewPreviousTrack:
    state.previousTrackID = action.trackID
  default:
    break
  }

  return state
}
