//
//  MyLibraryActions.swift
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

struct RequestSavePlaylist: APIRequestAction {}
struct ReceiveSavePlaylist: APIResponseSuccessAction {
  let response: JSON
}
struct ErrorSavePlaylist: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct StoredPlaylistableSavedTracksPlaylistID: Action {
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

func createPlaylist(name: String, userID: String, success: @escaping (JSON) -> (), failure: @escaping () -> ()) -> Action {
  return CallSpotifyAPI(
    endpoint: "/v1/users/\(userID)/playlists",
    method: .post,
    body: ["name": name],
    types: APITypes(
      requestAction: RequestSavePlaylist.self,
      successAction: ReceiveSavePlaylist.self,
      failureAction: ErrorSavePlaylist.self
    ),
    success: success,
    failure: failure
  )
}

func createPlaylistableSavedTracksPlaylist(userID: String) -> Action {
  return WrapInDispatch { dispatch in
    dispatch(createPlaylist(name: "Playlistable Saved Tracks", userID: userID, success: { json in
      guard let id = json["id"].string else { return }
      dispatch(storePlaylistableSavedTracksPlaylist(id: id))
    }, failure: {}))
  }
}

func storePlaylistableSavedTracksPlaylist(id: String) -> Action {
  try? Locksmith.saveData(
    data: [KeychainKeys.playlistableSavedTracksPlaylistID: id],
    forUserAccount: KeychainKeys.playlistableSavedTracksPlaylistID
  )
  
  return StoredPlaylistableSavedTracksPlaylistID(id: id)
}

func saveToPlaylistableTrack(trackID: String, userID: String, playlistID: String) -> Action {
  return CallSpotifyAPI(
    endpoint: "/v1/users/\(userID)/playlists/\(playlistID)",
    method: .post,
    body: ["uris": ["spotify:track:\(trackID)"]],
    types: APITypes(
      requestAction: RequestSavePlaylistableTrack.self,
      successAction: ReceiveSavePlaylistableTrack.self,
      failureAction: ErrorSavePlaylistableTrack.self
    ),
    success: { json in },
    failure: {}
  )
}
