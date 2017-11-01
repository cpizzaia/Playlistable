//
//  MyLibraryReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct MyLibraryState {
  var mySavedTracks: [Track]
  var isRequestingSavedTracks: Bool
}

fileprivate let initialMyLibraryState = MyLibraryState(mySavedTracks: [], isRequestingSavedTracks: false)

func spotifyAuthReducer(action: Action, state: MyLibraryState?) -> MyLibraryState {
  var state = state ?? initialMyLibraryState
  
  switch action {
  case _ as RequestSavedTracks:
    state.isRequestingSavedTracks = true
  default:
    break
  }
  
  return state
}
