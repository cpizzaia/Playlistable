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

    window?.rootViewController = IntroViewController()

    window?.makeKeyAndVisible()

    application.statusBarStyle = .lightContent

    application.isStatusBarHidden = false

    startStateManagers()

    let navAppearance = UINavigationBar.appearance()

    navAppearance.tintColor = UIColor.myWhite
    navAppearance.isTranslucent = false
    navAppearance.setBackgroundImage(UIImage(), for: .default)
    navAppearance.shadowImage = UIImage()

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
