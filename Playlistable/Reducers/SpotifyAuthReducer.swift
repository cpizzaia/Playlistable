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
  var isAuthed: Bool {
    get {
      return token != nil
    }
  }
}

fileprivate let initialSpotifyAuthState = SpotifyAuthState(token: nil)

func spotifyAuthReducer(action: Action, state: SpotifyAuthState?) -> SpotifyAuthState {
  var state = state ?? initialSpotifyAuthState
  
  switch action {
  case let action as ReceiveSpotifyAuth:
    state.token = action.token
  default:
    break
  }
  
  return state
}
