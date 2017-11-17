//
//  PlayerQueueManager.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

class PlayerQueueManager: StateManager {
  typealias StoreSubscriberStateType = AppState
  private static var instance: PlayerQueueManager?
  
  static func start() {
    instance = PlayerQueueManager()
  }
  
  private init() {
    mainStore.subscribe(self)
  }
  
  func newState(state: AppState) {
    let spotifyPlayerState = state.spotifyPlayer
    
    guard let currentTrackID = spotifyPlayerState.playingTrackID else { return }
    
    guard !spotifyPlayerState.isPlaying && spotifyPlayerState.isPlayingQueue && !spotifyPlayerState.isStartingToPlay else { return }
    
    if let action = playTrack(inQueue: spotifyPlayerState.queueTrackIDs, afterTrackID: currentTrackID) {
      mainStore.dispatch(action)
    }
  }
}
