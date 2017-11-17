//
//  LockscreenManager.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer

class LockScreenManager: StateManager {
  typealias StoreSubscriberStateType = AppState
  private static var instance: LockScreenManager?
  private let commandCenter = MPRemoteCommandCenter.shared()
  private let infoCenter = MPNowPlayingInfoCenter.default()
  private var currentTrack: Track?
  
  static func start() {
    instance = LockScreenManager()
  }
  
  private init() {
    mainStore.subscribe(self)
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.playCommand.isEnabled = true
    commandCenter.nextTrackCommand.isEnabled = true
    commandCenter.previousTrackCommand.isEnabled = true
    
    UIApplication.shared.beginReceivingRemoteControlEvents()
  }
  
  func newState(state: AppState) {
    guard let currentPlayingTrack = state.spotifyPlayer.playingTrackID else { return }
    guard let track = state.resources.tracksFor(ids: [currentPlayingTrack]).first else { return }
    guard currentTrack?.id != track.id else { return }
    
    currentTrack = track
    updateNowPlayingInfo(forTrack: track)
  }
  
  private func updateNowPlayingInfo(forTrack track: Track) {
    DispatchQueue.main.async {
      var info = [
        MPMediaItemPropertyPersistentID: track.id as AnyObject,
        MPMediaItemPropertyMediaType: 1 as AnyObject,
        MPMediaItemPropertyIsCloudItem : false as AnyObject,
        MPMediaItemPropertyAlbumTitle: "" as AnyObject,
        MPMediaItemPropertyAlbumArtist: "" as AnyObject,
        MPMediaItemPropertyTitle: track.name as AnyObject,
        MPMediaItemPropertyAlbumTrackCount: 1 as AnyObject,
        MPMediaItemPropertyAlbumTrackNumber: 0 as AnyObject,
        MPMediaItemPropertyPlaybackDuration: Double(track.durationMS) / 1000.0 as AnyObject,
        MPNowPlayingInfoPropertyPlaybackQueueIndex: 0 as AnyObject,
        MPNowPlayingInfoPropertyPlaybackQueueCount: 1 as AnyObject,
        MPNowPlayingInfoPropertyElapsedPlaybackTime: 0 as AnyObject
      ]
      
      if let imageURL = track.mediumImageURL {
        
        
        let data = try? Data(contentsOf: imageURL)
        let image = UIImage(data: data ?? Data()) ?? UIImage()
        
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
      }
      
      self.infoCenter.nowPlayingInfo = info
    }
    
  }
}
