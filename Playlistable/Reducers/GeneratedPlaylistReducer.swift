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
  var isGenerating: Bool
}

fileprivate let initialGeneratedPlaylistState = GeneratedPlaylistState(trackIDs: [], isGenerating: false)

func generatedPlaylistReducer(action: Action, state: GeneratedPlaylistState?) -> GeneratedPlaylistState {
  var state = state ?? initialGeneratedPlaylistState
  
  switch action {
  case _ as RequestGeneratePlaylist:
    state.isGenerating = true
  case let action as ReceiveGeneratePlaylist:
    state.isGenerating = false
    state.trackIDs = action.response["tracks"].array?.flatMap({ $0["id"].string }) ?? []
  case _ as ErrorGeneratePlaylist:
    state.isGenerating = false
  default:
    break
  }
  
  return state
}
