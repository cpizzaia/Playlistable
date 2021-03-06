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

  struct Props {
    let playerIsPlaying: Bool
  }

  private static var instance: AudioInterruptionController?

  var props: AudioInterruptionController.Props?

  private var playerWasPlaying = false

  static func start() {
    instance = AudioInterruptionController()
  }

  func mapStateToProps(state: AppState) -> Props {
    return Props(playerIsPlaying: state.spotifyPlayer.isPlaying)
  }

  func didReceiveNewProps(props: Props) {

  }

  private init() {
    mainStore.subscribe(self)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleInterruption),
      name: AVAudioSession.interruptionNotification,
      object: nil
    )
  }

  @objc private func handleInterruption(notification: Notification) {
    guard let info = notification.userInfo,
      let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
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
    playerWasPlaying = props?.playerIsPlaying == true

    if props?.playerIsPlaying == true {
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
