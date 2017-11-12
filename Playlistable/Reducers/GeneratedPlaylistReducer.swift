//
//  GeneratedPlaylistReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct GeneratedPlaylistState {
  var trackIDs: [String]
}

fileprivate let initialGeneratedPlaylistState = GeneratedPlaylistState(trackIDs: [])

func generatedPlaylistReducer(action: Action, state: GeneratedPlaylistState?) -> GeneratedPlaylistState {
  return initialGeneratedPlaylistState
}
