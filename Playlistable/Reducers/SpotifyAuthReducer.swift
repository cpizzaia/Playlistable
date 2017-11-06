//
//  SpotifyAuthReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct SpotifyAuthState {
  var token: String?
  var isInitializing: Bool
  var isRequesting: Bool
  var isAuthed: Bool {
    get {
      return token != nil
    }
  }
}

fileprivate let initialSpotifyAuthState = SpotifyAuthState(token: nil, isInitializing: false, isRequesting: false)

func spotifyAuthReducer(action: Action, state: SpotifyAuthState?) -> SpotifyAuthState {
  var state = state ?? initialSpotifyAuthState
  
  switch action {
  case let action as ReceiveSpotifyAuth:
    state.token = action.response["access_token"].string
    state.isRequesting = false
    state.isInitializing = false
  case _ as ErrorSpotifyAuth:
    state.isRequesting = false
    state.isInitializing = false
  case _ as InitializeOAuth:
    state.isInitializing = true
  default:
    break
  }
  
  return state
}
