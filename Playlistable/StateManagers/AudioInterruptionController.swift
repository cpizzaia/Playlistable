//
//  AudioInterruptionController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/15/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import AVFoundation

class AudioInterruptionController: StateManager {
  typealias StoreSubscriberStateType = AppState

  private static var instance: AudioInterruptionController?

  private var playerIsPlaying = false
  private var playerWasPlaying = false

  static func start() {
    instance = AudioInterruptionController()
  }

  func newState(state: AppState) {
    playerIsPlaying = state.spotifyPlayer.isPlaying
  }

  private init() {
    mainStore.subscribe(self)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInterruption),
      name: Notification.Name.AVAudioSessionInterruption,
      object: nil
    )
  }

  @objc private func handleInterruption(notification: Notification) {
    guard let info = notification.userInfo,
      let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
        return
    }

    switch type {
    case .began:
      handleInterruptionStarted()

    case .ended:
      handleInterruptionEnded()
    }
  }

  private func handleInterruptionStarted() {
    playerWasPlaying = playerIsPlaying

    if playerIsPlaying {
      mainStore.dispatch(SpotifyPlayerActions.pause())
    }
  }

  private func handleInterruptionEnded() {
    if playerWasPlaying {
      playerWasPlaying = false
      mainStore.dispatch(SpotifyPlayerActions.resume())
    }
  }
}
