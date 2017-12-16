//
//  SearchReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct SearchState {
  var query: String?
  var trackIDs: [String]
  var isRequesting: Bool
}

fileprivate let initialSearchState = SearchState(query: nil, trackIDs: [], isRequesting: false)

func searchReducer(action: Action, state: SearchState?) -> SearchState {
  var state = state ?? initialSearchState
  
  switch action {
  case _ as RequestSearch:
    state.isRequesting = true
  case let action as ReceiveSearch:
    state.isRequesting = false
    state.trackIDs = action.response["tracks"]["items"].array?.flatMap {
      $0["id"].string
      } ?? []
  case _ as ErrorSearch:
    state.isRequesting = false
  case let action as StoreQuery:
    state.query = action.query
  default:
    break
  }
  
  return state
}
