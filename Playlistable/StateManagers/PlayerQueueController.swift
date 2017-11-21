//
//  PlayerQueueController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

class PlayerQueueController: StateManager {
  typealias StoreSubscriberStateType = AppState
  private static var instance: PlayerQueueController?
  
  static func start() {
    instance = PlayerQueueController()
  }
  
  private init() {
    mainStore.subscribe(self)
  }
  
  func newState(state: AppState) {
    let spotifyPlayerState = state.spotifyPlayer
    
    guard let currentTrackID = spotifyPlayerState.playingTrackID else { return }
    
    guard shouldPlayNextTrack(state: state.spotifyPlayer) else { return }
    
    if let action = playTrack(inQueue: spotifyPlayerState.queueTrackIDs, afterTrackID: currentTrackID) {
      mainStore.dispatch(action)
    }
  }
  
  private func shouldPlayNextTrack(state: SpotifyPlayerState) -> Bool {
    return !state.isPlaying &&
      state.isPlayingQueue &&
      !state.isStartingToPlay &&
      !state.isPausing && !state.isPaused
  }
}
