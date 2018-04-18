//
//  LockscreenController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer

class LockScreenController: NSObject, StateManager {
  var props: Props?

  typealias StoreSubscriberStateType = AppState

  struct Props {
    let isPlaying: Bool
    let isPaused: Bool
    let nextTrackExists: Bool
    let previousTrackExists: Bool
    let currentTrack: Track?
  }

  private static var instance: LockScreenController?
  private let commandCenter = MPRemoteCommandCenter.shared()
  private let infoCenter = MPNowPlayingInfoCenter.default()

  static func start() {
    instance = LockScreenController()
  }

  private override init() {
    super.init()

    mainStore.subscribe(self)
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.playCommand.isEnabled = true
    commandCenter.nextTrackCommand.isEnabled = true
    commandCenter.previousTrackCommand.isEnabled = true

    commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrackCommand))
    commandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrackCommand))
    commandCenter.playCommand.addTarget(self, action: #selector(playCommand))
    commandCenter.pauseCommand.addTarget(self, action: #selector(pauseCommand))

    UIApplication.shared.beginReceivingRemoteControlEvents()
  }

  @objc func nextTrackCommand() {
    mainStore.dispatch(SpotifyPlayerActions.skipToNextTrack())
  }

  @objc func previousTrackCommand() {
    mainStore.dispatch(SpotifyPlayerActions.skipToPreviousTrack())
  }

  @objc func playCommand() {
    mainStore.dispatch(SpotifyPlayerActions.resume())
  }

  @objc func pauseCommand() {
    mainStore.dispatch(SpotifyPlayerActions.pause())
  }

  func mapStateToProps(state: AppState) -> Props {
    let currentTrack: Track?

    if let trackID = state.spotifyPlayer.playingTrackID,
      let track = state.resources.trackFor(id: trackID)
    {
      currentTrack = track
    } else {
      currentTrack = nil
    }

    return Props(
      isPlaying: state.spotifyPlayer.isPlaying,
      isPaused: state.spotifyPlayer.isPaused,
      nextTrackExists: state.spotifyPlayer.nextTrackID != nil,
      previousTrackExists: state.spotifyPlayer.previousTrackID != nil,
      currentTrack: currentTrack
    )
  }

  func didReceiveNewProps(props: LockScreenController.Props) {
    commandCenter.nextTrackCommand.isEnabled = isNextTrackCommandEnabled(props: props)
    commandCenter.previousTrackCommand.isEnabled = isPreviousTrackCommandEnabled(props: props)

    commandCenter.playCommand.isEnabled = isPlayCommanedEnabled(props: props)
    commandCenter.pauseCommand.isEnabled = isPauseCommanedEnabled(props: props)

    guard self.props?.currentTrack?.id != props.currentTrack?.id else { return }

    guard let track = props.currentTrack else { return }

    updateNowPlayingInfo(forTrack: track)
  }

  private func isNextTrackCommandEnabled(props: Props) -> Bool {
    return props.nextTrackExists
  }

  private func isPreviousTrackCommandEnabled(props: Props) -> Bool {
    return props.previousTrackExists
  }

  private func isPlayCommanedEnabled(props: Props) -> Bool {
    return !props.isPlaying
  }

  private func isPauseCommanedEnabled(props: Props) -> Bool {
    return !props.isPaused
  }

  private func updateNowPlayingInfo(forTrack track: Track) {
    DispatchQueue.main.async {
      var info = [
        MPMediaItemPropertyMediaType: 1 as AnyObject,
        MPMediaItemPropertyIsCloudItem: false as AnyObject,
        MPMediaItemPropertyAlbumTitle: "" as AnyObject,
        MPMediaItemPropertyAlbumArtist: "" as AnyObject,
        MPMediaItemPropertyTitle: track.name as AnyObject,
        MPMediaItemPropertyAlbumTrackCount: 1 as AnyObject,
        MPMediaItemPropertyAlbumTrackNumber: 0 as AnyObject,
        MPMediaItemPropertyPlaybackDuration: Double(track.durationMS) / 1000.0 as AnyObject,
        MPNowPlayingInfoPropertyPlaybackQueueIndex: 0 as AnyObject,
        MPNowPlayingInfoPropertyPlaybackQueueCount: 1 as AnyObject,
        MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: SpotifyPlayerActions.getCurrentPlayerPosition()) as AnyObject
      ]

      if let imageURL = track.mediumImageURL {

        let data = try? Data(contentsOf: imageURL)
        let image = UIImage(data: data ?? Data()) ?? UIImage()

        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ -> UIImage in
          return image
        })
      }

      self.infoCenter.nowPlayingInfo = info
    }

  }
}
