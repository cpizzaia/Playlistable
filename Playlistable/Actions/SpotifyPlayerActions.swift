//
//  SpotifyPlayerActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import Spotify

fileprivate let player = SPTAudioStreamingController.sharedInstance()!

struct StartedPlayer: Action {}

struct LoggedInPlayer: Action {}

struct StartPlayerFailed: Action {}

struct InitializedPlayer: Action {}

fileprivate func startPlayer(clientID: String) -> Action {
  
  do {
    try player.start(withClientId: clientID)
  } catch {
    return StartPlayerFailed()
  }
  
  return StartedPlayer()
}

fileprivate func loginPlayer(accessToken: String) -> Action {
  player.login(withAccessToken: accessToken)
  
  return LoggedInPlayer()
}

func initializePlayer(clientID: String, accessToken: String, dispatch: DispatchFunction) {
  dispatch(startPlayer(clientID: clientID))
  dispatch(loginPlayer(accessToken: accessToken))
  dispatch(InitializedPlayer())
}
