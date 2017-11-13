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

struct PlayingTrack: Action {
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

func initializePlayer(clientID: String, accessToken: String, dispatch: DispatchFunction) {
  player.delegate = streamingDelegate
  player.playbackDelegate = playbackDelegate
  dispatch(startPlayer(clientID: clientID))
  loginPlayer(accessToken: accessToken)
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
    
  }
  
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
    mainStore.dispatch(PlayingTrack(trackID: String(trackUri.split(separator: ":").last!)))
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
