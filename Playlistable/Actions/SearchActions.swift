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
  struct RequestSearch: APIRequestAction {}
  struct ReceiveSearch: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorSearch: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct StoreQuery: Action {
    let query: String
  }

  static func search(query: String) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(CallSpotifyAPI(
        endpoint: "/v1/search",
        queryParams: [
          "q": query.replacingOccurrences(of: " ", with: "+"),
          "type": "track,artist,album"
        ],
        method: .get,
        types: APITypes(
          requestAction: RequestSearch.self,
          successAction: ReceiveSearch.self,
          failureAction: ErrorSearch.self
        ),
        success: { _ in
          dispatch(StoreQuery(query: query))
      },
        failure: nil
      ))
    }
  }
}
