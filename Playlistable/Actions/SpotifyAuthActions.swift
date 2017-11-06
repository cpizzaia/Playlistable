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

struct RequestSpotifyAuth: Action {
  let isRequesting = true
}

struct ErrorSpotifyAuth: APIResponseFailureAction {
  let error: APIRequest.APIError
}

struct ReceiveSpotifyAuth: APIResponseSuccessAction {
  let response: JSON
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

func oAuthSpotify(dispatch: DispatchFunction) {
  dispatch(RequestSpotifyAuth())

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

func receiveSpotifyAuth(url: URL) {
  guard let code = url.queryParameters?["code"] else { return }
  
  mainStore.dispatch(CallAPI(
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
      requestAction: RequestSpotifyAuth(),
      successAction: ReceiveSpotifyAuth.self,
      failureAction: ErrorSpotifyAuth.self
    ),
    url: "https://accounts.spotify.com/api/token"
  ))
}
