//
//  TabBarController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/24/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class TabBarController: UITabBarController, MyStoreSubscriber {
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let playerIsInitialized: Bool
    let spotifyAuthState: SpotifyAuthState
  }

  func didReceiveNewProps(props: Props) {

  }

  func mapStateToProps(state: AppState) -> TabBarController.Props {
    return Props(
      playerIsInitialized: state.spotifyPlayer.isInitialized,
      spotifyAuthState: state.spotifyAuth
    )
  }

  var props: Props?

  override func viewDidLoad() {
    super.viewDidLoad()

    tabBar.backgroundColor = UIColor.myLightBlack
    tabBar.barTintColor = UIColor.myLightBlack
    tabBar.tintColor = UIColor.myWhite
    tabBar.isTranslucent = false

    let tabOne = UINavigationController(rootViewController: GeneratedPlaylistViewController())

    tabOne.tabBarItem = UITabBarItem()
    tabOne.tabBarItem.title = "Playlist"
    tabOne.tabBarItem.image = UIImage(named: "PlaylistTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    tabOne.tabBarItem.selectedImage = UIImage(named: "PlaylistTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))

    let tabTwo = UINavigationController(rootViewController: SeedsViewController())

    tabTwo.tabBarItem = UITabBarItem()
    tabTwo.tabBarItem.title = "Seeds"
    tabTwo.tabBarItem.image = UIImage(named: "SeedsTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    tabTwo.tabBarItem.selectedImage = UIImage(named: "SeedsTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))

    let tabThree = UINavigationController(rootViewController: SearchViewController())

    tabThree.tabBarItem = UITabBarItem()
    tabThree.tabBarItem.title = "Search"
    tabThree.tabBarItem.image = UIImage(named: "SearchTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    tabThree.tabBarItem.selectedImage = UIImage(named: "SearchTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))

    viewControllers = [tabOne, tabTwo, tabThree]

    viewControllers?.forEach { vc in
      guard let vc = vc as? UINavigationController else { return }
      self.setup(navigationController: vc)
    }

    let navAppearance = UINavigationBar.appearance()

    navAppearance.tintColor = UIColor.myWhite
    navAppearance.isTranslucent = false
    navAppearance.setBackgroundImage(UIImage(), for: .default)
    navAppearance.shadowImage = UIImage()

    // FIXME: Bit of an anti pattern here cause we are accessing state outside of the store
    // rethink and fix when you get a chance
    if MyUserDefaults.storedGeneratedPlaylistID != nil {
      selectedIndex = 0
    } else {
      selectedIndex = 2
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let props = props else { return }

    if !props.spotifyAuthState.isAuthed {
      mainStore.dispatch(SpotifyAuthActions.oAuthSpotify(authState: props.spotifyAuthState))
      return
    }

    if !props.playerIsInitialized {
      mainStore.dispatch(SpotifyAuthActions.postAuthAction(accessToken: props.spotifyAuthState.token ?? ""))
    }
  }

  private func setup(navigationController: UINavigationController) {
    navigationController.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont.myFontBold(withSize: 17),
      NSAttributedString.Key.foregroundColor: UIColor.myWhite
    ]

    navigationController.navigationBar.backgroundColor = UIColor.myLightBlack
    navigationController.navigationBar.barTintColor = UIColor.myLightBlack
  }

}
