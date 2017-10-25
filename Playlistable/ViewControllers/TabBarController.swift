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
  @IBOutlet var libraryTab: UITabBarItem!
  
  var isAuthed = false
  
  func newState(state: AppState) {
    isAuthed = state.spotifyAuth.isAuthed
  }
  
  typealias StoreSubscriberStateType = AppState
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tabOne = loadUIViewControllerFromNib(LibraryViewController.self)
    
    tabOne.tabBarItem = libraryTab
    
    viewControllers = [tabOne]
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
    if !isAuthed { oAuthSpotify(dispatch: mainStore.dispatch) }
  }
  
}
