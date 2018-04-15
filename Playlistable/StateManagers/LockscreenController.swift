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
  typealias StoreSubscriberStateType = AppState
  private static var instance: LockScreenController?
  private let commandCenter = MPRemoteCommandCenter.shared()
  private let infoCenter = MPNowPlayingInfoCenter.default()
  private var currentTrack: Track?
  private var currentQueue = [String]()

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

  func newState(state: AppState) {
    guard
      let trackID = state.spotifyPlayer.playingTrackID,
      let track = state.resources.trackFor(id: trackID)
    else { return }

    commandCenter.nextTrackCommand.isEnabled = isNextTrackCommandEnabled(state: state)
    commandCenter.previousTrackCommand.isEnabled = isPreviousTrackCommandEnabled(state: state)

    commandCenter.playCommand.isEnabled = isPlayCommanedEnabled(state: state.spotifyPlayer)
    commandCenter.pauseCommand.isEnabled = isPauseCommanedEnabled(state: state.spotifyPlayer)

    guard currentTrack?.id != track.id else { return }

    currentTrack = track

    updateNowPlayingInfo(forTrack: track)
  }

  private func isNextTrackCommandEnabled(state: AppState) -> Bool {
    guard
      let playlistID =  state.generatedPlaylist.playlistID,
      let playlist = state.resources.playlistFor(id: playlistID),
      let trackID = state.spotifyPlayer.playingTrackID
    else { return false }

    return playlist.trackIDs.index(of: trackID) != playlist.trackIDs.endIndex - 1
  }

  private func isPreviousTrackCommandEnabled(state: AppState) -> Bool {
    guard
      let playlistID =  state.generatedPlaylist.playlistID,
      let playlist = state.resources.playlistFor(id: playlistID),
      let trackID = state.spotifyPlayer.playingTrackID
      else { return false }

    return playlist.trackIDs.index(of: trackID) != playlist.trackIDs.startIndex
  }

  private func isPlayCommanedEnabled(state: SpotifyPlayerState) -> Bool {
    return !state.isPlaying
  }

  private func isPauseCommanedEnabled(state: SpotifyPlayerState) -> Bool {
    return !state.isPaused
  }

  private func updateNowPlayingInfo(forTrack track: Track) {
    DispatchQueue.main.async {
      var info = [
        MPMediaItemPropertyPersistentID: track.id as AnyObject,
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
