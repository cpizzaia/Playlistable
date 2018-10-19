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

private var hasSpotifyInstalled: Bool {
  return SPTAuth.supportsApplicationAuthentication()
}

private var oAuthUrl: URL? {
  return URL(string: "")
}

private var clientID: String {
  return "78aa57559d21489e83d50d8fec3579d1"
}

private var clientSecret: String {
  return "2d1756d853834abeb15ffdb1ac045321"
}

private var redirectURI: String {
  return "playlistable://"
}

private var scopes: [String] {
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

private var oAuthQueryParams: String {
  return APIQueryParamsFormatter.queryString(params:
    [
      "client_id": clientID,
      "response_type": "code",
      "redirect_uri": redirectURI,
      "scope": scopes.joined(separator: " ")
    ]
  )
}

private var appURL: URL? {
  return URL(string: ("spotify-action://authorize" + oAuthQueryParams).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
}

private var webURL: URL? {
  return URL(string: ("https://accounts.spotify.com/authorize" + oAuthQueryParams).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
}

enum SpotifyAuthActions {
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

  static func oAuthSpotify(authState: SpotifyAuthState) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(RequestSpotifyAuth())

      if authState.isRefreshable && authState.shouldRefresh {
        dispatch(
          refreshSpotifyAuthAndInitPlayer(
            refreshToken: authState.refreshToken ?? ""
          )
        )
        return
      }

      if hasSpotifyInstalled {
        log("Authing from spotify app")
        guard let appURL = appURL else { return }
        UIApplication.shared.open(appURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
      } else {
        log("Authing from webview")
        guard let webURL = webURL else { return }
        UIViewController.currentViewController()?.present(
          SFSafariViewController(url: webURL),
          animated: true
        )
      }
    }
  }

  static func refreshSpotifyAuthAndInitPlayer(refreshToken: String) -> Action {
    return WrapInDispatch { dispatch, getState in
      dispatch(refreshSpotifyAuth(
        refreshToken: refreshToken,
        success: { _ in
          guard let token = getState()?.spotifyAuth.token else { return }

          dispatch(postAuthAction(accessToken: token))
        },
        failure: {}
      ))
    }
  }

  static func refreshSpotifyAuth(refreshToken: String, success: @escaping (JSON) -> Void, failure: @escaping () -> Void) -> Action {
    return WrapInDispatch { dispatch, _ in
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
        success: success,
        failure: failure
      ))
    }
  }

  static func postAuthAction(accessToken: String) -> Action {
    return WrapInDispatch { dispatch, getState in
      dispatch(SpotifyPlayerActions.initializePlayer(clientID: clientID, accessToken: accessToken))
      dispatch(
        SpotifyAuthActions.getCurrentUser(success: { _ in
          guard let userID = getState()?.spotifyAuth.userID else { return }

          if let action = GeneratePlaylistActions.reloadPlaylistFromStorage(userID: userID) {
            dispatch(action)
          }
        }, failure: {})
      )
      dispatch(SpotifyPlayerActions.setHighBitrate())
    }
  }

  static func receiveSpotifyAuth(url: URL) -> Action? {
    guard let code = url.queryParameters?["code"] else { return nil }

    if let webview = UIViewController.currentViewController() as? SFSafariViewController {
      webview.dismiss(animated: true, completion: nil)
    }

    return WrapInDispatch { dispatch, getState in
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
        success: { _ in
          guard
            let newState = getState(),
            let token = newState.spotifyAuth.token
            else { return }

          dispatch(postAuthAction(accessToken: token))
      },
        failure: {}
      ))
    }
  }

  static func getCurrentUser(success: @escaping (JSON) -> Void, failure: @escaping () -> Void) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(CallSpotifyAPI(
        endpoint: "/v1/me",
        method: .get,
        types: APITypes(
          requestAction: RequestCurrentUser.self,
          successAction: ReceiveCurrentUser.self,
          failureAction: ErrorCurrentUser.self
        ),
        success: success,
        failure: failure
      ))
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
