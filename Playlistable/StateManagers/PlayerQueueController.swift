//
//  PlayerQueueController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import AVFoundation

class PlayerQueueController: StateManager {
  typealias StoreSubscriberStateType = AppState
  private static var instance: PlayerQueueController?

  static func start() {
    instance = PlayerQueueController()
  }

  private var isPlaying = false
  private var handlingAudioInterruption = false

  private init() {
    mainStore.subscribe(self)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAudioInterruption),
      name: Notification.Name.AVAudioSessionInterruption,
      object: nil
    )
  }

  func newState(state: AppState) {
    let spotifyPlayerState = state.spotifyPlayer

    isPlaying = state.spotifyPlayer.isPlaying

    guard let currentTrackID = spotifyPlayerState.playingTrackID else { return }

    guard shouldPlayNextTrack(state: state.spotifyPlayer) else { return }

    if let action = SpotifyPlayerActions.playTrack(inQueue: spotifyPlayerState.queueTrackIDs, afterTrackID: currentTrackID) {
      mainStore.dispatch(action)
    }
  }

  private func shouldPlayNextTrack(state: SpotifyPlayerState) -> Bool {
    return !state.isPlaying &&
      state.isPlayingQueue &&
      !state.isStartingToPlay &&
      !state.isPausing && !state.isPaused
  }

  @objc private func handleAudioInterruption(notification: Notification) {
    guard let info = notification.userInfo,
      let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
        return
    }

    switch type {
    case .began:
      handleAudioInterruptionStarted()
    case .ended:
      handleAudioInterruptionEnded()
    }
  }

  private func handleAudioInterruptionStarted() {
    if isPlaying {
      handlingAudioInterruption = true
      mainStore.dispatch(SpotifyPlayerActions.pause())
    }
  }

  private func handleAudioInterruptionEnded() {
    if handlingAudioInterruption {
      handlingAudioInterruption = false
      mainStore.dispatch(SpotifyPlayerActions.resume())
    }
  }
}
