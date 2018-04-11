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

  struct PlayQueue: Action {
    let trackIDs: [String]
  }

  struct PlayTrack: Action {
    let trackID: String
  }

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

  static func initializePlayer(clientID: String, accessToken: String) -> Action {
    return WrapInDispatch { dispatch, _ in
      player.delegate = streamingDelegate
      player.playbackDelegate = playbackDelegate
      dispatch(startPlayer(clientID: clientID))
      loginPlayer(accessToken: accessToken)
      dispatch(InitializedPlayer())
    }
  }

  static func playTrack(id: String) -> Action {
    player.playSpotifyURI(
      trackURI(fromID: id),
      startingWith: 0,
      startingWithPosition: 0,
      callback: { _ in

    })

    return PlayTrack(trackID: id)
  }

  static func playQueue(trackIDs: [String], startingWithTrackID trackID: String) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(PlayQueue(trackIDs: trackIDs))

      dispatch(playTrack(id: trackID))
    }
  }

  static func playTrack(inQueue queue: [String], afterTrackID trackID: String) -> Action? {
    guard let currentTrackIndex = queue.index(of: trackID) else { return nil }
    let nextTrackIndex = queue.index(after: currentTrackIndex)

    if nextTrackIndex <= queue.endIndex {
      return playTrack(id: queue[nextTrackIndex])
    } else {
      return nil
    }
  }

  static func playTrack(inQueue queue: [String], beforeTrackID trackID: String) -> Action? {
    guard let currentTrackIndex = queue.index(of: trackID) else { return nil }
    let nextTrackIndex = queue.index(before: currentTrackIndex)

    if nextTrackIndex >= queue.startIndex {
      return playTrack(id: queue[nextTrackIndex])
    } else {
      return nil
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
        } else {

        }
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

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {

  }

  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {

  }
}
