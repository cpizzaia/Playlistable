//
//  SpotifyPlayerActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import Spotify

private let player = SPTAudioStreamingController.sharedInstance()! // swiftlint:disable:this force_unwrapping

enum SpotifyPlayerActions {
  struct StartedPlayer: Action {}

  struct LoggedInPlayer: Action {}

  struct StartPlayerFailed: Action {}

  struct InitializedPlayer: Action {}
  struct InitializingPlayer: Action {}

  struct SettingBitrate: Action {
    let bitrate: SPTBitrate
  }
  struct SetBitrate: Action {
    let bitrate: SPTBitrate
  }
  struct ErrorSettingBitrate: Action {
    let bitrate: SPTBitrate
  }

  struct PlayPlaylist: Action {
    let playlistID: String
  }
  struct PlayingPlaylist: Action {
    let playlistID: String
  }
  struct ErrorPlayingPlaylist: Action {
    let playlistID: String
  }

  struct SkippingToNextTrack: Action {}
  struct SkippedToNextTrack: Action {}
  struct ErrorSkippingToNextTrack: Action {}

  struct SkippingToPreviousTrack: Action {}
  struct SkippedToPreviousTrack: Action {}
  struct ErrorSkippingToPreviousTrack: Action {}

  struct SettingShuffle: Action {}
  struct SetShuffle: Action {}
  struct ErrorSettingShuffle: Action {}

  struct PlayingTrack: Action {
    let trackID: String
  }

  struct StoppedPlaying: Action {
    let trackID: String
  }

  struct Pausing: Action {}
  struct Paused: Action {}
  struct FailedToPause: Action {}

  struct Resuming: Action {}
  struct Resumed: Action {}
  struct FailedToResume: Action {}

  struct NewPreviousTrack: Action {
    let trackID: String?
  }
  struct NewNextTrack: Action {
    let trackID: String?
  }

  static func initializePlayer(clientID: String, accessToken: String) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(InitializingPlayer())
      player.delegate = streamingDelegate
      player.playbackDelegate = playbackDelegate
      dispatch(startPlayer(clientID: clientID))
      loginPlayer(accessToken: accessToken)
      dispatch(InitializedPlayer())
    }
  }

  static func playPlaylist(id: String, startingWithTrack position: Int, shouldShuffle: Bool) -> Action {
    return WrapInDispatch { dispatch, _ in
      if player.playbackState?.isShuffling != shouldShuffle {
        dispatch(setShuffle(shouldShuffle))
      }

      player.playSpotifyURI(
        playlistURI(fromID: id),
        startingWith: UInt(position),
        startingWithPosition: 0,
        callback: { error in
          if error != nil {
            dispatch(ErrorPlayingPlaylist(playlistID: id))
            return
          }

          dispatch(PlayingPlaylist(playlistID: id))
        }
      )

      dispatch(PlayPlaylist(playlistID: id))
    }
  }

  static func setShuffle(_ value: Bool) -> Action {
    // setting is playing to become active device,
    // cause we can't set shuffle without being the active device
    if player.playbackState?.isActiveDevice != true {
      player.setIsPlaying(true, callback: { _ in })
    }

    return WrapInDispatch { dispatch, _ in
      player.setShuffle(value) { error in
        if error != nil {
          dispatch(ErrorSettingShuffle())
          return
        }

        dispatch(SetShuffle())
      }

      dispatch(SettingShuffle())
    }
  }

  static func skipToNextTrack() -> Action {
    return WrapInDispatch { dispatch, _ in
      player.skipNext { error in
        if error != nil {
          dispatch(ErrorSkippingToNextTrack())
          return
        }

        dispatch(SkippedToNextTrack())
      }

      dispatch(SkippingToNextTrack())
    }
  }

  static func skipToPreviousTrack() -> Action {
    return WrapInDispatch { dispatch, _ in
      player.skipPrevious { error in
        if error != nil {
          dispatch(ErrorSkippingToPreviousTrack())
          return
        }

        dispatch(SkippedToPreviousTrack())
      }

      dispatch(SkippingToPreviousTrack())
    }
  }

  static func pause() -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(Pausing())

      player.setIsPlaying(false, callback: { error in
        if error != nil {
          dispatch(FailedToPause())
        } else {

        }
      })
    }
  }

  static func resume() -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(Resuming())

      player.setIsPlaying(true, callback: { error in
        if error != nil {
          dispatch(FailedToResume())
        }
      })
    }
  }

  static func setHighBitrate() -> Action {
    return WrapInDispatch { dispatch, _ in
      let bitrate = SPTBitrate.normal

      dispatch(SettingBitrate(bitrate: bitrate))

      player.setTargetBitrate(bitrate, callback: { error in
        if error != nil {
          dispatch(ErrorSettingBitrate(bitrate: bitrate))
          return
        }

        dispatch(SetBitrate(bitrate: bitrate))
      })
    }
  }

  // FIXME: Not sure how else to expose this, come back and rethink this later.
  static func getCurrentPlayerPosition() -> TimeInterval {
    return player.playbackState.position
  }
}

private func startPlayer(clientID: String) -> Action {

  do {
    try player.start(withClientId: clientID)
  } catch {
    return SpotifyPlayerActions.StartPlayerFailed()
  }

  return SpotifyPlayerActions.StartedPlayer()
}

private func loginPlayer(accessToken: String) {
  player.login(withAccessToken: accessToken)
}

private func id(fromURI uri: String) -> String {
  return String(uri.split(separator: ":").last ?? Substring())
}

private let streamingDelegate = StreamingDelegate()
private let playbackDelegate = PlaybackDelegate()

private class StreamingDelegate: NSObject, SPTAudioStreamingDelegate {
  func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
    mainStore.dispatch(SpotifyPlayerActions.LoggedInPlayer())
  }

  func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {

  }

  func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) {

  }
}

private class PlaybackDelegate: NSObject, SPTAudioStreamingPlaybackDelegate {

  func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
    switch event {
    case SPPlaybackNotifyPlay:
      mainStore.dispatch(SpotifyPlayerActions.Resumed())
    case SPPlaybackNotifyPause:
      mainStore.dispatch(SpotifyPlayerActions.Paused())
    default:
      break
    }
  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
    mainStore.dispatch(SpotifyPlayerActions.StoppedPlaying(trackID: id(fromURI: trackUri)))
  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
    mainStore.dispatch(SpotifyPlayerActions.PlayingTrack(trackID: id(fromURI: trackUri)))
  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
    if let nextTrackURI = metadata?.nextTrack?.uri {
      mainStore.dispatch(SpotifyPlayerActions.NewNextTrack(trackID: id(fromURI: nextTrackURI)))
    } else {
      mainStore.dispatch(SpotifyPlayerActions.NewNextTrack(trackID: nil))
    }

    if let previousTrackURI = metadata?.prevTrack?.uri {
      mainStore.dispatch(SpotifyPlayerActions.NewPreviousTrack(trackID: id(fromURI: previousTrackURI)))
    } else {
      mainStore.dispatch(SpotifyPlayerActions.NewPreviousTrack(trackID: nil))
    }
  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {

  }
}
