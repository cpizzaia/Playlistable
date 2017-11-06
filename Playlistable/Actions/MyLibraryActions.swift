//
//  MyLibraryActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON

struct RequestSavedTracks: Action {}

struct ReceiveSavedTracks: APIResponseSuccessAction {
  let response: JSON
}

struct ErrorSavedTracks: APIResponseFailureAction {
  let error: APIRequest.APIError
}

func getSavedTracks() -> Action {
  return CallSpotifyAPI(
    endpoint: "/v1/me/tracks",
    method: .get,
    types: APITypes(
      requestAction: RequestSavedTracks(),
      successAction: ReceiveSavedTracks.self,
      failureAction: ErrorSavedTracks.self
    )
  )
}
