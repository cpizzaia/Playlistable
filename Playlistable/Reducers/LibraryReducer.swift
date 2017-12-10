//
//  MyLibraryReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import Locksmith

struct LibraryState {
  typealias TrackID = String
  
  var playlistableSavedTracksPlaylistID: String?
  var playlistableSavedTrackIDs: [String]
  var isRequestingPlaylistableSavedTracks: Bool
  var isCreatingPlaylistableSavedTracks: Bool
}

fileprivate let initialMyLibraryState = LibraryState(
  playlistableSavedTracksPlaylistID: Locksmith.loadDataForUserAccount(
    userAccount: KeychainKeys.playlistableSavedTracksPlaylistID)?[KeychainKeys.playlistableSavedTracksPlaylistID] as? String,
  playlistableSavedTrackIDs: [],
  isRequestingPlaylistableSavedTracks: false,
  isCreatingPlaylistableSavedTracks: false
)

func myLibraryReducer(action: Action, state: LibraryState?) -> LibraryState {
  var state = state ?? initialMyLibraryState
  
  switch action {
  case let action as StoredPlaylistableSavedTracksPlaylistID:
    state.playlistableSavedTracksPlaylistID = action.id
  
  case _ as RequestCreatePlaylistableTracksPlaylist:
    state.isCreatingPlaylistableSavedTracks = true
  
  case let action as ReceiveCreatePlaylistableTracksPlaylist:
    state.playlistableSavedTracksPlaylistID = action.response["id"].string
    state.isCreatingPlaylistableSavedTracks = false
  
  case _ as ErrorCreatePlaylistableTracksPlaylist:
    state.isCreatingPlaylistableSavedTracks = false
  
  case _ as RequestPlaylistableSavedTracks:
    state.isRequestingPlaylistableSavedTracks = true
  
  case let action as ReceivePlaylistableSavedTracks:
    state.playlistableSavedTrackIDs = action.response["items"].array?.flatMap { json in
      return json["track"]["id"].string
    } ?? []
    
    state.isRequestingPlaylistableSavedTracks = false
  case _ as ErrorPlaylistableSavedTracks:
    state.isRequestingPlaylistableSavedTracks = false
  
  case let action as SavedTrack:
    state.playlistableSavedTrackIDs = state.playlistableSavedTrackIDs + [action.id]
  case let action as UnSavedTrack:
    state.playlistableSavedTrackIDs = state.playlistableSavedTrackIDs.filter { id in
      return action.id != id
    }
  default:
    break
  }
  
  return state
}
