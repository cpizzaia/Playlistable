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
  var querySearchResults: [String: SearchResults]
  var isRequesting: [String: Bool]
  var currentQuery: String?
  var hasSeenSearchTip: Bool {
    didSet {
      MyUserDefaults.hasSeenSearchTip = hasSeenSearchTip
    }
  }
  var hasSeenSelectTip: Bool {
    didSet {
      MyUserDefaults.hasSeenSelectTip = hasSeenSelectTip
    }
  }
  func isRequesting(query: String) -> Bool {
    return isRequesting[query] == true
  }
}

struct SearchResults {
  let trackIDs: [String]
  let artistIDs: [String]
  let albumIDs: [String]
}

private let initialSearchState = SearchState(
  querySearchResults: [:],
  isRequesting: [:],
  currentQuery: nil,
  hasSeenSearchTip: MyUserDefaults.hasSeenSearchTip == true,
  hasSeenSelectTip: MyUserDefaults.hasSeenSelectTip == true
)

func searchReducer(action: Action, state: SearchState?) -> SearchState {
  var state = state ?? initialSearchState

  switch action {
  case let action as SearchActions.RequestQueryResults:
    state.isRequesting[action.query] = true
  case let action as SearchActions.ReceiveQueryResults:
    state.isRequesting[action.query] = false

    let searchResults = SearchResults(
      trackIDs: action.response["tracks"]["items"].array?.compactMap {
        $0["id"].string
        } ?? [],
      artistIDs: action.response["artists"]["items"].array?.compactMap {
        $0["id"].string
        } ?? [],
      albumIDs: action.response["albums"]["items"].array?.compactMap {
        $0["id"].string
        } ?? []
    )

    state.querySearchResults[action.query] = searchResults
  case let action as SearchActions.ErrorQueryResults:
    state.isRequesting[action.query] = false
  case let action as SearchActions.StoreCurrentQuery:
    state.currentQuery = action.query
  case _ as SearchActions.SawSearchTip:
    state.hasSeenSearchTip = true
  case _ as SearchActions.SawSelectTip:
    state.hasSeenSelectTip = true
  default:
    break
  }

  return state
}
