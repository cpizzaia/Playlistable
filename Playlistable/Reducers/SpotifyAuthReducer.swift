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
  
}

fileprivate let initialSpotifyAuthState = SpotifyAuthState()

func spotifyAuthReducer(action: Action, state: SpotifyAuthState?) -> SpotifyAuthState {
  return state ?? initialSpotifyAuthState
}
