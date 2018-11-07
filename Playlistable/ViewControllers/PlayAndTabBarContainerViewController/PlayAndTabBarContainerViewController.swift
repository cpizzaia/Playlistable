//
//  PlayAndTabBarContainerViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class PlayAndTabBarContainerViewController: UIViewController, TabBarViewDelegate, PlayBarViewDelegate, MyStoreSubscriber {
  // MARK: Public Types
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let selectedTabIndex: Int
    let currentTrack: Track?
    let isPlaying: Bool
    let currentViewController: UIViewController
  }

  // MARK: Public Properties
  var props: Props?

  // MARK: Private Properties
  private var currentViewController: UIViewController?
  private let playBar = PlayBarView()
  private let tabBar = TabBarView(tabs: [
    TabBarView.Tab(
      imageString: "PlaylistTab",
      name: "Playlist"
    ),
    TabBarView.Tab(
      imageString: "SeedsTab",
      name: "Seeds"
    ),
    TabBarView.Tab(
      imageString: "SearchTab",
      name: "Search"
    )
  ])

  // MARK: Public Methods
  init(notificationCenter: NotificationCenter = NotificationCenter.default) {
    super.init(nibName: nil, bundle: nil)

    setupViews()

    notificationCenter.addObserver(
      self,
      selector: #selector(handleEnteredForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )

    notificationCenter.addObserver(
      self,
      selector: #selector(handleEnteredBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
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
    let currentTrack: Track?

    if let trackID = state.spotifyPlayer.playingTrackID {
      currentTrack = state.resources.trackFor(id: trackID)
    } else {
      currentTrack = nil
    }

    return Props(
      selectedTabIndex: state.tabBar.selectedIndex,
      currentTrack: currentTrack,
      isPlaying: state.spotifyPlayer.isPlaying,
      currentViewController: state.tabBar.currentViewController
    )
  }

  func didReceiveNewProps(props: Props) {
    tabBar.switchToTab(index: props.selectedTabIndex)

    if let track = props.currentTrack {
      playBar.update(
        forTrack: track,
        startTime: SpotifyPlayerActions.getCurrentPlayerPosition(),
        endTime: (Double(track.durationMS / 1000)),
        isPlaying: props.isPlaying
      )
      playBar.show()
    } else {
      playBar.hide()
    }

    switchTo(viewController: props.currentViewController)
  }

  @objc func handleEnteredForeground() {
    mainStore.subscribe(self)
  }

  @objc func handleEnteredBackground() {
    mainStore.unsubscribe(self)
  }

  // MARK: Private Methods
  private func setupViews() {
    setupTabBar()
    setupPlayBar()
  }

  private func setupTabBar() {
    view.addSubview(tabBar)

    tabBar.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }

    tabBar.delegate = self
  }

  private func setupPlayBar() {
    view.addSubview(playBar)

    playBar.snp.makeConstraints { make in
      make.leading.trailing.equalTo(view)
      make.bottom.equalTo(tabBar.snp.top)
    }

    playBar.delegate = self
  }

  private func switchTo(viewController: UIViewController) {
    if currentViewController == viewController { return }
    removeCurrentViewController()
    display(viewController: viewController)
  }

  private func removeCurrentViewController() {
    currentViewController?.view.removeFromSuperview()
    currentViewController?.removeFromParent()
  }

  private func display(viewController: UIViewController) {
    addChild(viewController)

    view.addSubview(viewController.view)

    view.sendSubviewToBack(viewController.view)

    viewController.view.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view)
      make.bottom.equalTo(playBar.snp.top)
    }

    viewController.didMove(toParent: self)

    currentViewController = viewController
  }

  // MARK: TabBarViewDelegate
  func selectedTab(atIndex index: Int) {
    mainStore.dispatch(TabBarActions.SwitchTabIndex(selectedIndex: index))
  }

  // MARK: PlayBarViewDelegate
  func didTapPlayButton() {
    mainStore.dispatch(SpotifyPlayerActions.resume())
  }

  func didTapPauseButton() {
    mainStore.dispatch(SpotifyPlayerActions.pause())
  }
}
