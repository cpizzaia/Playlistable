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

fileprivate let player = SPTAudioStreamingController.sharedInstance()!

fileprivate class QueuePlayer: StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  static let shared = QueuePlayer()
  
  init() {
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
  
  // FIXME: Blank function to get it to init without calling shared and storing nothing.
  func start() {}
}

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

fileprivate func startPlayer(clientID: String) -> Action {
  
  do {
    try player.start(withClientId: clientID)
  } catch {
    return StartPlayerFailed()
  }
  
  return StartedPlayer()
}

fileprivate func loginPlayer(accessToken: String) {
  player.login(withAccessToken: accessToken)
}

func initializePlayer(clientID: String, accessToken: String) -> Action {
  return WrapInDispatch { dispatch in
    player.delegate = streamingDelegate
    player.playbackDelegate = playbackDelegate
    QueuePlayer.shared.start()
    dispatch(startPlayer(clientID: clientID))
    loginPlayer(accessToken: accessToken)
    dispatch(InitializedPlayer())
  }
}

func playTrack(id: String) -> Action {
  player.playSpotifyURI(
    "spotify:track:\(id)",
    startingWith: 0,
    startingWithPosition: 0,
    callback: { error in
    
  })
  
  return PlayTrack(trackID: id)
}

func playQueue(trackIDs: [String], startingWithTrackID trackID: String) -> Action {
  return WrapInDispatch { dispatch in
    dispatch(PlayQueue(trackIDs: trackIDs))
    
    dispatch(playTrack(id: trackID))
  }
}

func playTrack(inQueue queue: [String], afterTrackID trackID: String) -> Action? {
  guard let currentTrackIndex = queue.index(of: trackID) else { return nil }
  let nextTrackIndex = queue.index(after: currentTrackIndex)
  
  if nextTrackIndex != queue.endIndex {
    return playTrack(id: queue[nextTrackIndex])
  } else {
    return nil
  }
}

fileprivate func id(fromURI uri: String) -> String {
  return String(uri.split(separator: ":").last!)
}

fileprivate let streamingDelegate = StreamingDelegate()
fileprivate let playbackDelegate = PlaybackDelegate()

fileprivate class StreamingDelegate: NSObject, SPTAudioStreamingDelegate {
  func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
    mainStore.dispatch(LoggedInPlayer())
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

fileprivate class PlaybackDelegate: NSObject, SPTAudioStreamingPlaybackDelegate {
  
  
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
    
  }
  
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
    
  }
  
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
    mainStore.dispatch(StoppedPlaying(trackID: id(fromURI: trackUri)))
  }
  
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
    mainStore.dispatch(PlayingTrack(trackID: id(fromURI: trackUri)))
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
