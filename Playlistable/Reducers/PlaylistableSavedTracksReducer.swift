//
//  PlaylistableSavedTracksReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/9/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import Locksmith

struct PlaylistableSavedTrackState {
  var playlistID: String?
  var trackIDs: [String]
  var isRequesting: Bool
  var isCreatingPlaylist: Bool
}

fileprivate let initialPlaylistableSavedTracksState = PlaylistableSavedTrackState(
  playlistID: Locksmith.loadDataForUserAccount(
    userAccount: KeychainKeys.playlistableSavedTracksPlaylistID)?[KeychainKeys.playlistableSavedTracksPlaylistID] as? String,
  trackIDs: [],
  isRequesting: false,
  isCreatingPlaylist: false
)

func playlistableSavedTracksReducer(action: Action, state: PlaylistableSavedTrackState?) -> PlaylistableSavedTrackState {
  var state = state ?? initialPlaylistableSavedTracksState
  
  switch action {
  case let action as StoredPlaylistableSavedTracksPlaylistID:
    state.playlistID = action.id
    
  case _ as RequestCreatePlaylistableTracksPlaylist:
    state.isCreatingPlaylist = true
    
  case let action as ReceiveCreatePlaylistableTracksPlaylist:
    state.playlistID = action.response["id"].string
    state.isCreatingPlaylist = false
    
  case _ as ErrorCreatePlaylistableTracksPlaylist:
    state.isCreatingPlaylist = false
    
  case _ as RequestPlaylistableSavedTracks:
    state.isRequesting = true
    
  case let action as ReceivePlaylistableSavedTracks:
    state.trackIDs = action.response["items"].array?.flatMap { json in
      return json["track"]["id"].string
      } ?? []
    
    state.isRequesting = false
  case _ as ErrorPlaylistableSavedTracks:
    state.isRequesting = false
    
  case let action as SavedTrack:
    state.trackIDs = state.trackIDs + [action.id]
  case let action as UnSavedTrack:
    state.trackIDs = state.trackIDs.filter { id in
      return action.id != id
    }
  default:
    break
  }
  
  return state
}
