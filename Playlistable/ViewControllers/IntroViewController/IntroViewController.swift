//
//  IntroViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 3/18/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class IntroViewController: UIViewController, StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  
  @IBOutlet var descriptionText: UITextView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var loginButton: UIButton!
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard let auth = spotifyAuthState else { return }
    mainStore.dispatch(SpotifyAuthActions.oAuthSpotify(authState: auth))
  }
  
  private var spotifyAuthState: SpotifyAuthState?
  private var hasSpotifyPremium: Bool? {
    didSet {
      if oldValue == false || hasSpotifyPremium != false { return }
      
      presentAlertView(
        title: "Error",
        message: "You must have Spotify Premium to login.",
        completion: {}
      )
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    style()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mainStore.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  func newState(state: AppState) {
    spotifyAuthState = state.spotifyAuth
    hasSpotifyPremium = spotifyAuthState?.isPremium
    
    if spotifyAuthState?.isAuthed == true && spotifyAuthState?.userID != nil && hasSpotifyPremium == true {
      let vc = loadUIViewControllerFromNib(PlayerBarContainerViewController.self)
      
      present(vc, animated: true, completion: nil)
      
      return
    }
    
    if spotifyAuthState?.isAuthed == true && spotifyAuthState?.userID == nil && !(spotifyAuthState?.isRequestingUser == true) {
      mainStore.dispatch(SpotifyAuthActions.getCurrentUser())
    }
  }
  
  private func style() {
    view.backgroundColor = UIColor.myDarkBlack
    
    descriptionText.font = UIFont.myFont(withSize: 17)
    titleLabel.font = UIFont.myFontBold(withSize: 22)
    titleLabel.textColor = UIColor.myWhite
    descriptionText.backgroundColor = UIColor.clear
    descriptionText.textColor = UIColor.myWhite
    descriptionText.isUserInteractionEnabled = false
    descriptionText.isScrollEnabled = false
    descriptionText.layoutIfNeeded()
    
    loginButton.imageView?.contentMode = .scaleAspectFit
  }
  
}
