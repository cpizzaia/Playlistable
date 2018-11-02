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
import SnapKit

class IntroViewController: UIViewController, MyStoreSubscriber {
  // MARK: Public Types
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let hasPremium: Bool
    let doesNotHaveUser: Bool
    let isRequestingUser: Bool
    let spotifyAuthState: SpotifyAuthState
  }

  var props: Props?

  // MARK: Private Properties
  private let descriptionText = UILabel()
  private let titleLabel = UILabel()
  private let loginButton = UIButton()
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

  // MARK: Public Methods
  init() {
    super.init(nibName: nil, bundle: nil)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      let vc = PlayAndTabBarContainerViewController()

      present(vc, animated: true, completion: nil)

      return
    }

    if props.spotifyAuthState.isAuthed && props.doesNotHaveUser && !props.isRequestingUser {
      mainStore.dispatch(SpotifyAuthActions.getCurrentUser(success: { _ in }, failure: {}))
    }
  }

  @objc func loginButtonPressed(_ sender: UIButton) {
    guard let auth = props?.spotifyAuthState else { return }
    mainStore.dispatch(SpotifyAuthActions.oAuthSpotify(authState: auth))
  }

  // MARK: Private Methods
  private func setupViews() {
    view.backgroundColor = UIColor.myDarkBlack
    setupDescriptionLabel()
    setupTitleLabel()
    setupLoginButton()
  }

  private func setupDescriptionLabel() {
    view.addSubview(descriptionText)

    descriptionText.snp.makeConstraints { make in
      make.width.equalTo(view).multipliedBy(0.8)
      make.centerX.equalTo(view)
      make.centerY.equalTo(view).multipliedBy(0.7)
    }

    descriptionText.font = UIFont.myFont(withSize: 17)
    descriptionText.backgroundColor = UIColor.clear
    descriptionText.textColor = UIColor.myWhite
    descriptionText.numberOfLines = 0
    descriptionText.text = "Mix your favorite music together. Generate playlists on the fly. Discover music tailored to your taste."
    descriptionText.textAlignment = .center
  }

  private func setupTitleLabel() {
    view.addSubview(titleLabel)

    titleLabel.snp.makeConstraints { make in
      make.width.equalTo(view)
      make.centerX.equalTo(view)
      make.top.equalTo(descriptionText.snp.bottom).offset(50)
    }

    titleLabel.font = UIFont.myFontBold(withSize: 22)
    titleLabel.textColor = UIColor.myWhite
    titleLabel.text = "Experience Playlistable"
    titleLabel.textAlignment = .center
  }

  private func setupLoginButton() {
    view.addSubview(loginButton)

    loginButton.snp.makeConstraints { make in
      make.width.equalTo(view).multipliedBy(0.8)
      make.top.equalTo(titleLabel.snp.bottom).offset(50)
      make.centerX.equalTo(view)
      make.height.equalTo(70)
    }

    loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

    loginButton.setImage(UIImage(named: "spotifyLogin"), for: .normal)

    loginButton.imageView?.contentMode = .scaleAspectFit
  }
}
