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
  @IBOutlet var generatedPlaylistTab: UITabBarItem!
  @IBOutlet var libraryTab: UITabBarItem!
  @IBOutlet var seedsTab: UITabBarItem!
  
  var isAuthed = false
  
  func newState(state: AppState) {
    isAuthed = state.spotifyAuth.isAuthed
  }
  
  typealias StoreSubscriberStateType = AppState
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    let tabOne = UINavigationController(rootViewController: loadUIViewControllerFromNib(GeneratedPlaylistViewController.self))
    
    tabOne.tabBarItem = generatedPlaylistTab
    
    let tabTwo = UINavigationController(rootViewController: loadUIViewControllerFromNib(SeedsViewController.self))
    
    tabTwo.tabBarItem = seedsTab
    
    let tabThree = UINavigationController(rootViewController: loadUIViewControllerFromNib(LibraryViewController.self))
    
    tabThree.tabBarItem = libraryTab
    
    viewControllers = [tabOne, tabTwo, tabThree]
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
    if !isAuthed { mainStore.dispatch(oAuthSpotify()) }
  }
  
}
