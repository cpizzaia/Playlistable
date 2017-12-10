//
//  SavedTracksReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/9/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct SavedTracksState {
  var trackIDs: [String]
  var isRequesting: Bool
  var nextURL: String?
}

fileprivate let initialSavedTracksState = SavedTracksState(
  trackIDs: [],
  isRequesting: false,
  nextURL: "/v1/me/tracks?offset=0&limit=50"
)

func savedTracksReducer(action: Action, state: SavedTracksState?) -> SavedTracksState {
  var state = state ?? initialSavedTracksState
  
  switch action {
  case _ as RequestSavedTracks:
    state.isRequesting = true
    
  case let action as ReceiveSavedTracks:
    state.trackIDs += action.response["items"].array?.flatMap { json in
      return json["track"]["id"].string
      } ?? []
    state.nextURL = action.response["next"].string?.withoutSpotifyBaseURL
    state.isRequesting = false
    
  case _ as ErrorSavedTracks:
    state.nextURL = nil
    state.isRequesting = false
    
  default:
    break
  }
  
  return state
}
