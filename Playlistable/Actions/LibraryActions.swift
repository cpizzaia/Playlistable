//
//  LibraryActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import Locksmith

struct RequestSavedTracks: APIRequestAction {}
struct ReceiveSavedTracks: APIResponseSuccessAction {
  let response: JSON
}
struct ErrorSavedTracks: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct RequestSavePlaylistableTrack: APIRequestAction {}
struct ReceiveSavePlaylistableTrack: APIResponseSuccessAction {
  let response: JSON
}
struct ErrorSavePlaylistableTrack: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct RequestCreatePlaylistableTracksPlaylist: APIRequestAction {}
struct ReceiveCreatePlaylistableTracksPlaylist: APIResponseSuccessAction {
  let response: JSON
}
struct ErrorCreatePlaylistableTracksPlaylist: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct RequestPlaylistableSavedTracks: APIRequestAction {}
struct ReceivePlaylistableSavedTracks: APIResponseSuccessAction {
  let response: JSON
}
struct ErrorPlaylistableSavedTracks: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct StoredPlaylistableSavedTracksPlaylistID: Action {
  let id: String
}

struct SavedTrack: Action {
  let id: String
}

func getSavedTracks() -> Action {
  return CallSpotifyAPI(
    endpoint: "/v1/me/tracks",
    queryParams: ["limit": "50"],
    method: .get,
    types: APITypes(
      requestAction: RequestSavedTracks.self,
      successAction: ReceiveSavedTracks.self,
      failureAction: ErrorSavedTracks.self
    )
  )
}

func getPlaylistableSavedTracks(userID: String, playlistID: String) -> Action {
  return CallSpotifyAPI(
    endpoint: "/v1/users/\(userID)/playlists/\(playlistID)/tracks",
    queryParams: ["limit": "100"],
    method: .get,
    types: APITypes(
      requestAction: RequestPlaylistableSavedTracks.self,
      successAction: ReceivePlaylistableSavedTracks.self,
      failureAction: ErrorPlaylistableSavedTracks.self
    )
  )
}

func saveToAndCreatePlaylistableSavedTracksIfNeeded(trackID: String, userID: String, playlistID: String?) -> Action {
  if let playlistID = playlistID {
    return saveToPlaylistableTracks(
      trackID: trackID,
      userID: userID,
      playlistID: playlistID
    )
  } else {
    return WrapInDispatch { dispatch in
      dispatch(createPlaylistSavedTracksPlaylist(userID: userID, success: { json in
        guard let id = json["id"].string else { return }
        dispatch(saveToPlaylistableTracks(trackID: trackID, userID: userID, playlistID: id))
      }, failure: {}))
    }
  }
}

fileprivate func createPlaylistSavedTracksPlaylist(userID: String, success: @escaping (JSON) -> (), failure: @escaping () -> ()) -> Action {
  
  return WrapInDispatch { dispatch in
    dispatch(CallSpotifyAPI(
      endpoint: "/v1/users/\(userID)/playlists",
      method: .post,
      body: ["name": "Playlistable Saved Tracks"],
      types: APITypes(
        requestAction: RequestCreatePlaylistableTracksPlaylist.self,
        successAction: ReceiveCreatePlaylistableTracksPlaylist.self,
        failureAction: ErrorCreatePlaylistableTracksPlaylist.self
      ),
      success: { json in
        guard let id = json["id"].string else { return }
        dispatch(storePlaylistableSavedTracksPlaylist(id: id))
        success(json)
    },
      failure: failure
    ))
  }
}

fileprivate func saveToPlaylistableTracks(trackID: String, userID: String, playlistID: String) -> Action {
  return WrapInDispatch { dispatch in
    dispatch(CallSpotifyAPI(
      endpoint: "/v1/users/\(userID)/playlists/\(playlistID)/tracks",
      method: .post,
      body: ["uris": ["spotify:track:\(trackID)"]],
      types: APITypes(
        requestAction: RequestSavePlaylistableTrack.self,
        successAction: ReceiveSavePlaylistableTrack.self,
        failureAction: ErrorSavePlaylistableTrack.self
      ),
      success: { json in
        dispatch(SavedTrack(id: trackID))
    },
      failure: {}
    ))
  }
}



fileprivate func storePlaylistableSavedTracksPlaylist(id: String) -> Action {
  try? Locksmith.saveData(
    data: [KeychainKeys.playlistableSavedTracksPlaylistID: id],
    forUserAccount: KeychainKeys.playlistableSavedTracksPlaylistID
  )
  
  return StoredPlaylistableSavedTracksPlaylistID(id: id)
}
