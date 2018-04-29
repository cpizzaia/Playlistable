//
//  SpotifyAuthReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct SpotifyAuthState {
  var token: String? {
    didSet {
      MyUserDefaults.spotifyAuthToken = token
    }
  }
  var refreshToken: String? {
    didSet {
      MyUserDefaults.spotifyRefreshToken = refreshToken
    }
  }
  var userID: String?
  var market: String?
  var isInitializingOAuth: Bool
  var isRequestingToken: Bool
  var isRefreshingToken: Bool
  var isRequestingUser: Bool
  var isPremium: Bool?
  var expiresAt: TimeInterval? {
    didSet {
      MyUserDefaults.spotifyTokenExpirationTimeInterval = expiresAt
    }
  }

  // MARK: Computed Properties
  var isAuthed: Bool {
    return token != nil && !isExpired
  }

  var shouldRefresh: Bool {
    return isExpired && isRefreshable
  }

  var isRefreshable: Bool {
    return refreshToken != nil
  }

  var isExpired: Bool {
    guard let expiresAt = expiresAt else { return true }

    return Date().timeIntervalSince1970 > expiresAt
  }
}

private let initialSpotifyAuthState = SpotifyAuthState(
  token: MyUserDefaults.spotifyAuthToken,
  refreshToken: MyUserDefaults.spotifyRefreshToken,
  userID: nil,
  market: nil,
  isInitializingOAuth: false,
  isRequestingToken: false,
  isRefreshingToken: false,
  isRequestingUser: false,
  isPremium: nil,
  expiresAt: MyUserDefaults.spotifyTokenExpirationTimeInterval
)

func spotifyAuthReducer(action: Action, state: SpotifyAuthState?) -> SpotifyAuthState {
  var state = state ?? initialSpotifyAuthState

  switch action {
  case _ as SpotifyAuthActions.RequestSpotifyAuth:
    state.isRequestingToken = true

  case _ as SpotifyAuthActions.RequestSpotifyRefreshAuth:
    state.isRefreshingToken = true

  case let action as SpotifyAuthActions.ReceiveSpotifyAuth:
    state.token = action.response["access_token"].string
    state.refreshToken = action.response["refresh_token"].string

    if let expiresIn = action.response["expires_in"].double {
      state.expiresAt = expiresIn + Date().timeIntervalSince1970
    } else {
      state.expiresAt = nil
    }

    state.isRequestingToken = false
    state.isInitializingOAuth = false

  case let action as SpotifyAuthActions.ReceiveSpotifyRefreshAuth:
    state.token = action.response["access_token"].string

    if let expiresIn = action.response["expires_in"].double {
      state.expiresAt = expiresIn + Date().timeIntervalSince1970
    } else {
      state.expiresAt = nil
    }

    state.isRefreshingToken = false
    state.isInitializingOAuth = false

  case _ as SpotifyAuthActions.ErrorSpotifyRefreshAuth:
    state.isRefreshingToken = false
    state.isInitializingOAuth = false

  case _ as SpotifyAuthActions.ErrorSpotifyAuth:
    state.isRequestingToken = false
    state.isInitializingOAuth = false

  case _ as SpotifyAuthActions.InitializeOAuth:
    state.isInitializingOAuth = true

  case _ as SpotifyAuthActions.RequestCurrentUser:
    state.isRequestingUser = true

  case let action as SpotifyAuthActions.ReceiveCurrentUser:
    state.userID = action.response["id"].string
    state.market = action.response["country"].string
    state.isPremium = action.response["product"].string == "premium"

  default:
    break
  }

  return state
}
