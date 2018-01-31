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
  var isInitializing: Bool
  var isRequesting: Bool
  var isRefreshing: Bool
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
  var isAuthed: Bool {
    get {
      return token != nil && !isExpired
    }
  }
  
  var shouldRefresh: Bool {
    get {
      return isExpired && isRefreshable
    }
  }
  
  var isRefreshable: Bool {
    get {
      return refreshToken != nil
    }
  }
  
  var isExpired: Bool {
    get {
      guard let expiresAt = expiresAt else { return true }
      
      return Date().timeIntervalSince1970 > expiresAt
    }
  }
}

fileprivate let initialSpotifyAuthState = SpotifyAuthState(
  token: UserDefaults.standard.string(forKey: UserDefaultsKeys.spotifyAuthToken),
  refreshToken: UserDefaults.standard.string(forKey: UserDefaultsKeys.spotifyRefreshToken),
  userID: nil,
  isInitializing: false,
  isRequesting: false,
  isRefreshing: false,
  expiresAt: UserDefaults.standard.double(forKey: UserDefaultsKeys.spotifyTokenExpirationTimeInterval)
)

func spotifyAuthReducer(action: Action, state: SpotifyAuthState?) -> SpotifyAuthState {
  var state = state ?? initialSpotifyAuthState
  
  switch action {
  case _ as RequestSpotifyAuth:
    state.isRequesting = true
    
  case _ as ReceiveSpotifyRefreshAuth:
    state.isRefreshing = true
    
  case let action as ReceiveSpotifyAuth:
    state.token = action.response["access_token"].string
    state.refreshToken = action.response["refresh_token"].string
    
    if let expiresIn = action.response["expires_in"].double {
      state.expiresAt = expiresIn + Date().timeIntervalSince1970
    } else {
      state.expiresAt = nil
    }
    
    state.isRequesting = false
    state.isInitializing = false
  
  case let action as ReceiveSpotifyRefreshAuth:
    state.token = action.response["access_token"].string
    
    if let expiresIn = action.response["expires_in"].double {
      state.expiresAt = expiresIn + Date().timeIntervalSince1970
    } else {
      state.expiresAt = nil
    }
    
    state.isRefreshing = false
    state.isInitializing = false
  
  case _ as ErrorSpotifyRefreshAuth:
    state.isRefreshing = false
    state.isInitializing = false
    
  case _ as ErrorSpotifyAuth:
    state.isRequesting = false
    state.isInitializing = false
    
  case _ as InitializeOAuth:
    state.isInitializing = true
    
  case let action as ReceiveCurrentUser:
    state.userID = action.response["id"].string
    
  default:
    break
  }
  
  return state
}
