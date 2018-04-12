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
      UserDefaults.standard.set(token, forKey: UserDefaultsKeys.spotifyAuthToken)
      UserDefaults.standard.synchronize()
    }
  }
  var refreshToken: String? {
    didSet {
      UserDefaults.standard.set(refreshToken, forKey: UserDefaultsKeys.spotifyRefreshToken)
      UserDefaults.standard.synchronize()
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
      guard let expiresAt = expiresAt else {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.spotifyTokenExpirationTimeInterval)
        return
      }

      UserDefaults.standard.set(
        expiresAt,
        forKey: UserDefaultsKeys.spotifyTokenExpirationTimeInterval
      )
      UserDefaults.standard.synchronize()
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
  token: UserDefaults.standard.string(forKey: UserDefaultsKeys.spotifyAuthToken),
  refreshToken: UserDefaults.standard.string(forKey: UserDefaultsKeys.spotifyRefreshToken),
  userID: nil,
  market: nil,
  isInitializingOAuth: false,
  isRequestingToken: false,
  isRefreshingToken: false,
  isRequestingUser: false,
  isPremium: nil,
  expiresAt: UserDefaults.standard.double(forKey: UserDefaultsKeys.spotifyTokenExpirationTimeInterval)
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
