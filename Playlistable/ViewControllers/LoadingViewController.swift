//
//  LoadingViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/1/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController, MyStoreSubscriber {
  // MARK: Public Types
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let isAuthed: Bool
    let hasUser: Bool
    let hasPremium: Bool?
    let hasPlaylist: Bool
    let userID: String?
    let isFetchingStoredPlaylist: Bool
    let hasFetchedStoredPlaylist: Bool
    let isAuthRefreshable: Bool
  }

  // MARK: Public Properties
  var props: Props?

  // MARK: Private Properties
  private var presentedNotPremiumAlert = false

  // MARK: Public Methods
  init() {
    super.init(nibName: nil, bundle: nil)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }

  func mapStateToProps(state: AppState) -> Props {
    return Props(
      isAuthed: state.spotifyAuth.isAuthed,
      hasUser: state.spotifyAuth.userID != nil,
      hasPremium: state.spotifyAuth.isPremium,
      hasPlaylist: state.generatedPlaylist.playlistID != nil,
      userID: state.spotifyAuth.userID,
      isFetchingStoredPlaylist: state.generatedPlaylist.isFetchingStoredPlaylist,
      hasFetchedStoredPlaylist: state.generatedPlaylist.hasFetchedStoredPlaylist,
      isAuthRefreshable: state.spotifyAuth.isRefreshable
    )
  }

  func didReceiveNewProps(props: Props) {
    if !props.isAuthed && !props.isAuthRefreshable {
      return present(IntroViewController(), animated: true, completion: nil)
    }

    if isAuthorizedToUseApp(props: props) && !playlistNeedsToBeFetched(props: props) {
      let vc = PlayAndTabBarContainerViewController()

      return present(vc, animated: true, completion: nil)
    }

    if
      let userID = props.userID,
      let action = GeneratePlaylistActions.reloadPlaylistFromStorage(userID: userID),
      shouldFetchPlaylist(props: props)
    {
      mainStore.dispatch(action)
    }

    if props.hasPremium == false && !presentedNotPremiumAlert {
      presentedNotPremiumAlert = true
      presentAlertView(
        title: "Error",
        message: "You must have Spotify Premium to login.",
        completion: {
          mainStore.dispatch(SpotifyAuthActions.Deauthorize())
          self.presentedNotPremiumAlert = false
        }
      )
    }
  }

  // MARK: Private Methods
  private func playlistNeedsToBeFetched(props: Props) -> Bool {
    return props.hasPlaylist && !props.hasFetchedStoredPlaylist
  }

  private func shouldFetchPlaylist(props: Props) -> Bool {
    return props.hasPlaylist && !props.isFetchingStoredPlaylist && !props.hasFetchedStoredPlaylist
  }

  private func isAuthorizedToUseApp(props: Props) -> Bool {
    return props.isAuthed && props.hasUser && props.hasPremium == true
  }

  private func setupViews() {
    view.backgroundColor = .myDarkBlack

    let imageView = UIImageView()

    view.addSubview(imageView)

    imageView.snp.makeConstraints { make in
      make.height.equalTo(imageView.snp.width)
      make.width.equalTo(view.snp.width).multipliedBy(0.2)
      make.centerX.equalTo(view)
      make.centerY.equalTo(view).multipliedBy(0.95)
    }

    imageView.image = UIImage(named: "logo")
  }
}
