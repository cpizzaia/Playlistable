//
//  SpotifyAuthActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import Spotify
import ReSwift
import SwiftyJSON

struct RequestSpotifyAuth: Action {
  let isRequesting = true
}

struct ReceiveSpotifyAuth: APIResponseSuccessAction {
  let payload: JSON
}
struct FailureSpotifyAuth: APIResponseFailureAction {
  let error: APIRequest.APIError
}

fileprivate let auth = SPTAuth.defaultInstance()!

fileprivate var appURL: URL {
  get {
    return auth.spotifyAppAuthenticationURL()
  }
}

fileprivate var webURL: URL {
  get {
    return auth.spotifyWebAuthenticationURL()
  }
}

func oAuthSpotify(dispatch: DispatchFunction) {
  
}
