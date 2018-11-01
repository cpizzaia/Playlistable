//
//  AppDelegate.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import UIKit
import AVFoundation
import Fabric
import Crashlytics
import EasyTipView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    configureApp()

    window = UIWindow(frame: UIScreen.main.bounds)

//    if mainStore.state.spotifyAuth.isRefreshable {
//      window?.rootViewController = loadUIViewControllerFromNib(PlayerBarContainerViewController.self)
//    } else {
//      window?.rootViewController = IntroViewController()
//    }

    window?.rootViewController = PlayAndTabBarContainerViewController()

    window?.makeKeyAndVisible()

    application.statusBarStyle = .lightContent

    application.isStatusBarHidden = false

    startStateManagers()

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

    if let action = SpotifyAuthActions.receiveSpotifyAuth(url: url) {
      mainStore.dispatch(action)
    }

    return true
  }

  private func startStateManagers() {
    LockScreenController.start()
    AudioInterruptionController.start()
  }

  private func configureApp() {
    Fabric.with([Crashlytics.self])

    DispatchQueue.global().async {
      try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])

      try? AVAudioSession.sharedInstance().setActive(true)
    }

    var preferences = EasyTipView.Preferences()

    preferences.drawing.font = UIFont.myFont(withSize: 17)
    preferences.drawing.backgroundColor = UIColor.myLighterBlack
    preferences.drawing.foregroundColor = UIColor.myWhite

    EasyTipView.globalPreferences = preferences
  }
}
