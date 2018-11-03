//
//  SpotifyPlayerController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/3/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation

class SpotifyPlayerController: StateManager {
  // MARK: Public Types
  struct Props {
    let isAuthed: Bool
    let isInitialized: Bool
    let isInitializing: Bool
    let authToken: String?
  }

  typealias StoreSubscriberStateType = AppState

  // MARK: Private Static Properties
  static var instance: SpotifyPlayerController?

  // MARK: Public Static Methods
  static func start() {
    if self.instance != nil { return }

    let instance = SpotifyPlayerController()

    self.instance = instance

    mainStore.subscribe(instance)
  }

  // MARK: Public Methods
  var props: SpotifyPlayerController.Props?

  func mapStateToProps(state: AppState) -> SpotifyPlayerController.Props {
    return Props(
      isAuthed: state.spotifyAuth.isAuthed,
      isInitialized: state.spotifyPlayer.isInitialized,
      isInitializing: state.spotifyPlayer.isInitializing,
      authToken: state.spotifyAuth.token
    )
  }

  func didReceiveNewProps(props: SpotifyPlayerController.Props) {
    if let authToken = props.authToken, props.isAuthed && !props.isInitialized && !props.isInitializing {
      mainStore.dispatch(SpotifyAuthActions.authorizePlayer(accessToken: authToken))
    }
  }
}
