//
//  PlayerBarContainerViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class PlayerBarContainerViewController: UIViewController, StoreSubscriber {
  
  
  typealias StoreSubscriberStateType = AppState
  
  @IBOutlet var containerView: UIView!
  @IBOutlet var playBarView: UIView!
  @IBOutlet var durationBarView: UIView!
  @IBOutlet var playBarTitleLabel: UILabel!
  @IBOutlet var durationWidthConstraint: NSLayoutConstraint!
  
  var isAnimatingDuration = false
  var endTime: Double?
  
  func newState(state: AppState) {
    playBarView.isHidden = !state.spotifyPlayer.isPlaying
    
    if let trackID = state.spotifyPlayer.playingTrackID, state.spotifyPlayer.isPlaying {
      let track = state.resources.tracksFor(ids: [trackID]).first!
      playBarTitleLabel.text = track.name
      
      animateDuration(startTime: 0, endTime: Double(track.durationMS) / 1000.0)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tabBarVC = loadUIViewControllerFromNib(TabBarController.self)
    addChildViewController(tabBarVC)
    containerView.insertSubview(tabBarVC.view, at: 0)
    
    tabBarVC.didMove(toParentViewController: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }
  
  func animateDuration(startTime: Double, endTime: Double) {
    if self.endTime == endTime { return }
    self.endTime = endTime
    
    durationBarView.layer.removeAllAnimations()
    

    isAnimatingDuration = true
    
    let percentCompleted = startTime / endTime
    let timeLeft = endTime - startTime
    
    let fullWidth = view.frame.size.width
    
    durationWidthConstraint.constant = fullWidth * CGFloat(1 - percentCompleted)
    
    view.layoutIfNeeded()
    
    UIView.animate(withDuration: timeLeft, delay: 0, options: .curveLinear, animations: {
      self.durationWidthConstraint.constant = 0
      self.view.layoutIfNeeded()
    }, completion: { finished in
      self.isAnimatingDuration = false
    })
    
  }
}
