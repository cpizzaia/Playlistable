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

func search(query: String) -> Action {
  return WrapInDispatch { dispatch in
    dispatch(CallSpotifyAPI(
      endpoint: "/v1/search",
      queryParams: ["q": query.replacingOccurrences(of: " ", with: "+"), "type": "track"],
      method: .get,
      types: APITypes(
        requestAction: RequestSearch.self,
        successAction: ReceiveSearch.self,
        failureAction: ErrorSearch.self
      ),
      success: { json in
        dispatch(StoreQuery(query: query))
      },
      failure: nil
    ))
  }
}
