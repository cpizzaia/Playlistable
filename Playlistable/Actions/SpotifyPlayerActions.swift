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
    dispatch(startPlayer(clientID: clientID))
    loginPlayer(accessToken: accessToken)
    dispatch(InitializedPlayer())
  }
}

func playTrack(id: String) -> Action {
  player.playSpotifyURI(
    trackURI(fromID: id),
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
  
  if nextTrackIndex <= queue.endIndex {
    return playTrack(id: queue[nextTrackIndex])
  } else {
    return nil
  }
}

func playTrack(inQueue queue: [String], beforeTrackID trackID: String) -> Action? {
  guard let currentTrackIndex = queue.index(of: trackID) else { return nil }
  let nextTrackIndex = queue.index(before: currentTrackIndex)
  
  if nextTrackIndex >= queue.startIndex {
    return playTrack(id: queue[nextTrackIndex])
  } else {
    return nil
  }
}

func pause() -> Action {
  return WrapInDispatch { dispatch in
    dispatch(Pausing())
    
    player.setIsPlaying(false, callback: { error in
      if error != nil {
        dispatch(FailedToPause())
      } else {
        
      }
    })
  }
}

func resume() -> Action {
  return WrapInDispatch { dispatch in
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
func getCurrentPlayerPosition() -> TimeInterval {
  return player.playbackState.position
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
    switch event {
    case SPPlaybackNotifyPlay:
      mainStore.dispatch(Resumed())
    case SPPlaybackNotifyPause:
      mainStore.dispatch(Paused())
    default:
      break
    }
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
