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
    mainStore.dispatch(oAuthSpotify(authState: auth))
  }
  
  private var spotifyAuthState: SpotifyAuthState?
  
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
    
    if spotifyAuthState?.isAuthed == true {
      let vc = loadUIViewControllerFromNib(PlayerBarContainerViewController.self)
      
      present(vc, animated: true, completion: nil)
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
    descriptionText.setHeightForTextInside()
    
    loginButton.imageView?.contentMode = .scaleAspectFit
  }
  
}