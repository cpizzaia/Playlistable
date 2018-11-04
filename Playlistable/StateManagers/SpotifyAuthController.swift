//
//  SpotifyAuthController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/4/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class SpotifyAuthController: StateManager {
  // MARK: Public Types
  struct Props {
    let hasUser: Bool
    let isAuthed: Bool
    let isAuthRefreshable: Bool
    let requestingUser: Bool
    let refreshToken: String?
  }

  typealias StoreSubscriberStateType = AppState

  // MARK: Private Static Properties
  static var instance: SpotifyAuthController?

  // Public Static Methods
  static func start() {
    if self.instance != nil { return }

    let instance = SpotifyAuthController()

    self.instance = instance

    mainStore.subscribe(instance)
  }

  // MARK: Public Properties
  var props: Props?

  // MARK: Public Methods
  func mapStateToProps(state: StoreSubscriberStateType) -> Props {
    return Props(
      hasUser: state.spotifyAuth.userID != nil,
      isAuthed: state.spotifyAuth.isAuthed,
      isAuthRefreshable: state.spotifyAuth.isRefreshable,
      requestingUser: state.spotifyAuth.isRequestingUser,
      refreshToken: state.spotifyAuth.refreshToken
    )
  }

  func didReceiveNewProps(props: Props) {
    if props.isAuthed && !props.hasUser && !props.requestingUser {
      mainStore.dispatch(SpotifyAuthActions.getCurrentUser(success: { _ in }, failure: {}))
    }

    if let refreshToken = props.refreshToken, !props.isAuthed && props.isAuthRefreshable {
      mainStore.dispatch(SpotifyAuthActions.refreshSpotifyAuth(refreshToken: refreshToken))
    }
  }
}
