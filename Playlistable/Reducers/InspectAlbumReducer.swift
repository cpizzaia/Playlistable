//
//  InspectAlbumReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/14/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct InspectAlbumState {
  var albumID: String?
  var trackIDs: [String]
  var isRequestingTracks: Bool
}

private let initialState = InspectAlbumState(
  albumID: nil,
  trackIDs: [],
  isRequestingTracks: false
)

func inspectAlbumReducer(action: Action, state: InspectAlbumState?) -> InspectAlbumState {
  var state = state ?? initialState

  switch action {
  case let action as InspectAlbumActions.InspectAlbum:
    state.albumID = action.albumID
    state.trackIDs = []
    state.isRequestingTracks = false
  case _ as InspectAlbumActions.RequestAlbumTracks:
    state.isRequestingTracks = true
  case let action as InspectAlbumActions.ReceiveAlbumTracks:
    state.isRequestingTracks = false
    state.trackIDs = action.response["items"].array?.compactMap { $0["id"].string } ?? []
  case _ as InspectAlbumActions.ErrorAlbumTracks:
    state.isRequestingTracks = false
  default:
    break
  }

  return state
}
