//
//  SpotifyTokenRefreshMiddleware.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/10/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

let spotifyTokenRefreshMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      guard let state = getState(), state.spotifyAuth.shouldRefresh && action is CallSpotifyAPI else {
        next(action)
        return
      }

      log("refreshing auth from middleware")

      dispatch(SpotifyAuthActions.refreshSpotifyAuth(
        refreshToken: getState()?.spotifyAuth.refreshToken ?? "",
        success: { _ in
          next(action)
        },
        failure: {}
      ))
    }
  }
}
