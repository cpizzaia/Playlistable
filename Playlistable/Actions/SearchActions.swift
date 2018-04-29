//
//  SearchActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON

enum SearchActions {
  struct RequestQueryResults: Action {
    let query: String
  }
  struct ReceiveQueryResults: Action {
    let query: String
    let response: JSON
  }
  struct ErrorQueryResults: Action {
    let query: String
  }
  struct StoreCurrentQuery: Action {
    let query: String
  }

  struct SawSearchTip: Action {}
  struct SawSelectTip: Action {}

  static func search(query: String) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(StoreCurrentQuery(query: query))

      dispatch(RequestQueryResults(query: query))

      dispatch(CallSpotifyAPI(
        endpoint: "/v1/search",
        queryParams: [
          "q": query.replacingOccurrences(of: " ", with: "+"),
          "type": "track,artist,album"
        ],
        method: .get,
        types: nil,
        success: { response in
          dispatch(ReceiveQueryResults(query: query, response: response))
        },
        failure: {
          dispatch(ErrorQueryResults(query: query))
        }
      ))
    }
  }
}
