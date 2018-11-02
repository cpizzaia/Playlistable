//
//  PlayAndTabBarContainerViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class PlayAndTabBarContainerViewController: UIViewController, TabBarViewDelegate, MyStoreSubscriber {
  // MARK: Public Types
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let selectedTabIndex: Int
  }

  // MARK: Public Properties
  var props: Props?

  // MARK: Private Properties
  private var currentViewController: UIViewController?
  private let tabBar = TabBarView(tabs: [
    TabBarView.Tab(
      viewController: MyNavigationController(rootViewController: GeneratedPlaylistViewController()),
      imageString: "PlaylistTab",
      name: "Playlist"
    ),
    TabBarView.Tab(
      viewController: MyNavigationController(rootViewController: SeedsViewController()),
      imageString: "SeedsTab",
      name: "Seeds"
    ),
    TabBarView.Tab(
      viewController: MyNavigationController(rootViewController: SearchViewController()),
      imageString: "SearchTab",
      name: "Search"
    )
  ])

  // MARK: Public Methods
  init() {
    super.init(nibName: nil, bundle: nil)

    setupViews()
    switchTo(viewController: tabBar.currentViewController)
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
    return Props(selectedTabIndex: state.tabBar.selectedIndex)
  }

  func didReceiveNewProps(props: Props) {
    tabBar.switchToTab(index: props.selectedTabIndex)
  }

  // MARK: Private Methods
  private func setupViews() {
    setupTabBar()
  }

  private func setupTabBar() {
    view.addSubview(tabBar)

    tabBar.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }

    tabBar.delegate = self
  }

  private func switchTo(viewController: UIViewController) {
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
      make.bottom.equalTo(tabBar.snp.top)
    }

    viewController.didMove(toParent: self)

    currentViewController = viewController
  }

  // MARK: TabBarViewDelegate
  func selected(viewController: UIViewController, atTabIndex tabIndex: Int) {
    switchTo(viewController: viewController)
    mainStore.dispatch(TabBarActions.SwitchTabIndex(selectedIndex: tabIndex))
  }
}
