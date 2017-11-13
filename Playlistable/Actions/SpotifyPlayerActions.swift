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

struct StartedPlayer: Action {}

struct LoggedInPlayer: Action {}

struct StartPlayerFailed: Action {}

struct InitializedPlayer: Action {}

struct PlayTrack: Action {
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

fileprivate func loginPlayer(accessToken: String) -> Action {
  player.login(withAccessToken: accessToken)
  
  return LoggedInPlayer()
}

func initializePlayer(clientID: String, accessToken: String, dispatch: DispatchFunction) {
  player.delegate = playerDelegate
  player.playbackDelegate = playerDelegate
  dispatch(startPlayer(clientID: clientID))
  dispatch(loginPlayer(accessToken: accessToken))
  dispatch(InitializedPlayer())
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

fileprivate let playerDelegate = PlayerDelegate()

fileprivate class PlayerDelegate: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
  
  // MARK: SPTAudioStreamingDelegate Methods
  func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
    
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
  
  
  // MARK: SPTAudioStreamingPlaybackDelegate Methods
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
    
  }
  
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
    
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
