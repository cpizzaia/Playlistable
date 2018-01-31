//
//  SpotifyAuthActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import Alamofire
import Spotify
import ReSwift
import SwiftyJSON
import SafariServices

struct InitializeOAuth: Action {
  let isInitializing = true
}

struct RequestSpotifyAuth: APIRequestAction {}

struct RequestSpotifyRefreshAuth: APIRequestAction {}

struct ErrorSpotifyAuth: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct ErrorSpotifyRefreshAuth: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct ReceiveSpotifyAuth: APIResponseSuccessAction {
  let response: JSON
}

struct ReceiveSpotifyRefreshAuth: APIResponseSuccessAction {
  let response: JSON
}

struct RequestCurrentUser: APIRequestAction {}
struct ReceiveCurrentUser: APIResponseSuccessAction {
  let response: JSON
}
struct ErrorCurrentUser: APIResponseFailureAction {
  let error: APIRequest.APIError
}

fileprivate var hasSpotifyInstalled: Bool {
  get {
    return SPTAuth.supportsApplicationAuthentication()
  }
}

fileprivate var oAuthUrl: URL {
  get {
    return URL(string: "")!
  }
}

fileprivate var clientID: String {
  get {
    return "78aa57559d21489e83d50d8fec3579d1"
  }
}

fileprivate var clientSecret: String {
  get {
    return "2d1756d853834abeb15ffdb1ac045321"
  }
}

fileprivate var redirectURI: String {
  get {
    return "playlistable://"
  }
}

fileprivate var scopes: [String] {
  get {
    return [
      "playlist-read-private",
      "playlist-read-collaborative",
      "playlist-modify-public",
      "playlist-modify-private",
      "streaming",
      "ugc-image-upload",
      "user-follow-modify",
      "user-follow-read",
      "user-library-read",
      "user-library-modify",
      "user-read-private",
      "user-read-birthdate",
      "user-read-email",
      "user-top-read",
      "user-read-playback-state",
      "user-modify-playback-state",
      "user-read-currently-playing",
      "user-read-recently-played"
    ]
  }
}

fileprivate var oAuthQueryParams: String {
  get {
    return APIQueryParamsFormatter.queryString(params:
      [
        "client_id": clientID,
        "response_type": "code",
        "redirect_uri": redirectURI,
        "scope": scopes.joined(separator: " ")
      ]
    )
  }
}

fileprivate var appURL: URL {
  get {
    return URL(string: ("spotify-action://authorize" + oAuthQueryParams).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
}

fileprivate var webURL: URL {
  get {
    return URL(string: ("https://accounts.spotify.com/authorize" + oAuthQueryParams).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
}

func oAuthSpotify(authState: SpotifyAuthState) -> Action {
  return WrapInDispatch { dispatch in
    dispatch(RequestSpotifyAuth())
    
    if authState.isRefreshable && authState.shouldRefresh {
      dispatch(refreshSpotifyAuth(refreshToken: authState.refreshToken ?? ""))
      return
    }
    
    if hasSpotifyInstalled {
      log("Authing from spotify app")
      UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
    } else {
      log("Authing from webview")
      UIViewController.currentViewController()?.present(
        SFSafariViewController(url: webURL),
        animated: true
      )
    }
  }
}

func refreshSpotifyAuth(refreshToken: String) -> Action {
  return WrapInDispatch { dispatch in
    dispatch(CallAPI(
      method: .post,
      headers: nil,
      body: [
        "refresh_token": refreshToken,
        "grant_type": "refresh_token",
        "client_id": clientID,
        "client_secret": clientSecret
      ],
      bodyEncoding: URLEncoding.default,
      types: APITypes(
        requestAction: RequestSpotifyRefreshAuth.self,
        successAction: ReceiveSpotifyRefreshAuth.self,
        failureAction: ErrorSpotifyRefreshAuth.self
      ),
      url: "https://accounts.spotify.com/api/token",
      success: { json in
        guard let token = json["access_token"].string else { return }
        
        dispatch(postAuthAction(accessToken: token))
    },
      failure: nil
    ))
  }
}

func postAuthAction(accessToken: String) -> Action {
  
  return WrapInDispatch { dispatch in
    dispatch(initializePlayer(clientID: clientID, accessToken: accessToken))
    dispatch(getCurrentUser())
  }
  
}

func receiveSpotifyAuth(url: URL) -> Action? {
  guard let code = url.queryParameters?["code"] else { return nil }
  
  return WrapInDispatch { dispatch in
    dispatch(CallAPI(
      method: .post,
      headers: nil,
      body: [
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirectURI,
        "client_id": clientID,
        "client_secret": clientSecret
      ],
      bodyEncoding: URLEncoding.default,
      types: APITypes(
        requestAction: RequestSpotifyAuth.self,
        successAction: ReceiveSpotifyAuth.self,
        failureAction: ErrorSpotifyAuth.self
      ),
      url: "https://accounts.spotify.com/api/token",
      success: { json in
        guard let token = json["access_token"].string else { return }
        
        dispatch(postAuthAction(accessToken: token))
    },
      failure: {}
    ))
  }
}

func getCurrentUser() -> Action {
  return WrapInDispatch { dispatch in
    dispatch(CallSpotifyAPI(
      endpoint: "/v1/me",
      method: .get,
      types: APITypes(
        requestAction: RequestCurrentUser.self,
        successAction: ReceiveCurrentUser.self,
        failureAction: ErrorCurrentUser.self
      ),
      success: { json in
    },
      failure: nil
    ))
  }
}
