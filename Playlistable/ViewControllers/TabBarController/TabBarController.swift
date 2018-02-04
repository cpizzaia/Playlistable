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

class TabBarController: UITabBarController, StoreSubscriber {
  var authState: SpotifyAuthState?
  
  func newState(state: AppState) {
    authState = state.spotifyAuth
  }
  
  typealias StoreSubscriberStateType = AppState
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tabBar.backgroundColor = UIColor.myLightBlack
    tabBar.barTintColor = UIColor.myLightBlack
    tabBar.tintColor = UIColor.myWhite
  
    let tabOne = UINavigationController(rootViewController: loadUIViewControllerFromNib(GeneratedPlaylistViewController.self))
    
    tabOne.tabBarItem = UITabBarItem()
    tabOne.tabBarItem.title = "Playlist"
    tabOne.tabBarItem.image = UIImage(named: "PlaylistTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    tabOne.tabBarItem.selectedImage = UIImage(named: "PlaylistTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    
    
    let tabTwo = UINavigationController(rootViewController: loadUIViewControllerFromNib(SeedsViewController.self))
    
    tabTwo.tabBarItem = UITabBarItem()
    tabTwo.tabBarItem.title = "Seeds"
    tabTwo.tabBarItem.image = UIImage(named: "SeedsTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    tabTwo.tabBarItem.selectedImage = UIImage(named: "SeedsTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    
    
    
    
    
    let tabThree = UINavigationController(rootViewController:
        loadUIViewControllerFromNib(SearchViewController.self)
    )
    
    tabThree.tabBarItem = UITabBarItem()
    tabThree.tabBarItem.title = "Search"
    tabThree.tabBarItem.image = UIImage(named: "SearchTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    tabThree.tabBarItem.selectedImage = UIImage(named: "SearchTab")?.resizeImageWith(targetSize: CGSize(width: tabBar.bounds.height - 20, height: tabBar.bounds.height))
    
    
    
    viewControllers = [tabOne, tabTwo, tabThree]
    
    viewControllers?.forEach { self.setup(navigationController: $0 as! UINavigationController) }
    
    let navAppearance = UINavigationBar.appearance()
    
    navAppearance.tintColor = UIColor.myWhite
    navAppearance.isTranslucent = false
    navAppearance.setBackgroundImage(UIImage(), for: .default)
    navAppearance.shadowImage = UIImage()
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
    guard let authState = authState else { return }
    
    if !authState.isAuthed {
      mainStore.dispatch(oAuthSpotify(authState: authState))
    } else {
      mainStore.dispatch(postAuthAction(accessToken: authState.token ?? ""))
    }
  }
  
  private func setup(navigationController: UINavigationController) {
    navigationController.navigationBar.titleTextAttributes = [
      NSAttributedStringKey.font: UIFont.myFontBold(withSize: 17),
      NSAttributedStringKey.foregroundColor: UIColor.myWhite
    ]
    
    navigationController.navigationBar.backgroundColor = UIColor.myLightBlack
    navigationController.navigationBar.barTintColor = UIColor.myLightBlack
  }
  
}
