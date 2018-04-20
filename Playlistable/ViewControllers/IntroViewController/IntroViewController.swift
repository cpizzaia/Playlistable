//
//  IntroViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 3/18/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class IntroViewController: UIViewController, MyStoreSubscriber {
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let hasPremium: Bool
    let doesNotHaveUser: Bool
    let isRequestingUser: Bool
    let spotifyAuthState: SpotifyAuthState
  }

  @IBOutlet var descriptionText: UITextView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var loginButton: UIButton!
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard let auth = props?.spotifyAuthState else { return }
    mainStore.dispatch(SpotifyAuthActions.oAuthSpotify(authState: auth))
  }

  var props: Props?

  private var hasSpotifyPremium: Bool? {
    didSet {
      if oldValue == false || hasSpotifyPremium != false { return }

      presentAlertView(
        title: "Error",
        message: "You must have Spotify Premium to login.",
        completion: {}
      )
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    style()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }

  func mapStateToProps(state: AppState) -> Props {
    return Props(
      hasPremium: state.spotifyAuth.isPremium == true,
      doesNotHaveUser: state.spotifyAuth.userID == nil,
      isRequestingUser: state.spotifyAuth.isRequestingUser,
      spotifyAuthState: state.spotifyAuth
    )
  }

  func didReceiveNewProps(props: Props) {
    if props.spotifyAuthState.isAuthed && !props.doesNotHaveUser && props.hasPremium {
      let vc = loadUIViewControllerFromNib(PlayerBarContainerViewController.self)

      present(vc, animated: true, completion: nil)

      return
    }

    if props.spotifyAuthState.isAuthed && props.doesNotHaveUser && !props.isRequestingUser {
      mainStore.dispatch(SpotifyAuthActions.getCurrentUser(success: { _ in }, failure: {}))
    }
  }

  private func style() {
    view.backgroundColor = UIColor.myDarkBlack

    descriptionText.font = UIFont.myFont(withSize: 17)
    titleLabel.font = UIFont.myFontBold(withSize: 22)
    titleLabel.textColor = UIColor.myWhite
    descriptionText.backgroundColor = UIColor.clear
    descriptionText.textColor = UIColor.myWhite
    descriptionText.isUserInteractionEnabled = false
    descriptionText.isScrollEnabled = false
    descriptionText.layoutIfNeeded()

    loginButton.imageView?.contentMode = .scaleAspectFit
  }

}
