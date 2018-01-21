//
//  AppDelegate.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    DispatchQueue.global().async {
      try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
      
      try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    window?.rootViewController = loadUIViewControllerFromNib(PlayerBarContainerViewController.self)
    
    window?.makeKeyAndVisible()
    
    application.statusBarStyle = .lightContent
    
    startStateManagers()
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    if let action = receiveSpotifyAuth(url: url) {
      mainStore.dispatch(action)
    }
    
    return true
  }
  
  private func startStateManagers() {
    LockScreenController.start()
    PlayerQueueController.start()
  }
}

