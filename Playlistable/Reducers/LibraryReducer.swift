//
//  MyLibraryReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct LibraryState {
  typealias TrackID = String
  
  var mySavedTrackIDs: [TrackID]
  var isRequestingSavedTracks: Bool
}

fileprivate let initialMyLibraryState = LibraryState(mySavedTrackIDs: [], isRequestingSavedTracks: false)

func myLibraryReducer(action: Action, state: LibraryState?) -> LibraryState {
  var state = state ?? initialMyLibraryState
  
  switch action {
  case _ as RequestSavedTracks:
    state.isRequestingSavedTracks = true
  case let action as ReceiveSavedTracks:
    state.mySavedTrackIDs = action.response["items"].array?.flatMap { json in
      return json["track"]["id"].string
    } ?? []
    state.isRequestingSavedTracks = false
  case _ as ErrorSavedTracks:
    state.isRequestingSavedTracks = false
  default:
    break
  }
  
  return state
}
