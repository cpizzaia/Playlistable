//
//  QueryParamMarketInjector.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/11/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

let queryParamMarketInjector: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      guard let spotifyApiAction = action as? CallSpotifyAPI else {
        next(action)
        return
      }

      let actionWithMarket = CallSpotifyAPI(
        endpoint: spotifyApiAction.endpoint,
        queryParams: spotifyApiAction.queryParams?.union(
          ["market": getState()?.spotifyAuth.market ?? ""]
        ),
        batchedQueryParams: spotifyApiAction.batchedQueryParams,
        batchedJSONKey: spotifyApiAction.batchedJSONKey,
        method: spotifyApiAction.method,
        body: spotifyApiAction.body,
        types: spotifyApiAction.types,
        success: spotifyApiAction.success,
        failure: spotifyApiAction.failure
      )

      next(actionWithMarket)
    }
  }
}
