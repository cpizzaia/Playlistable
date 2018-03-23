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
  @IBOutlet var durationBarBackground: UIView!
  @IBOutlet var durationBarView: UIView!
  @IBOutlet var playBarTitleLabel: UILabel!
  @IBOutlet var durationWidthConstraint: NSLayoutConstraint!
  @IBOutlet var playPauseButton: UIButton!
  @IBAction func playPauseButtonPressed(_ sender: UIButton) {
    if isPlaying {
      mainStore.dispatch(SpotifyPlayerActions.pause())
    } else {
      mainStore.dispatch(SpotifyPlayerActions.resume())
    }
  }
  
  var isAnimatingDuration = false
  var endTime: Double?
  var isPlaying = false
  var isDurationBarStopped = false
  
  func newState(state: AppState) {
    isPlaying = state.spotifyPlayer.isPlaying
    playBarView.isHidden = state.spotifyPlayer.playingTrackID == nil
    setPlayPauseButtonImage(playing: isPlaying)
    isPlayerBarHidden = playBarView.isHidden
    
    if let trackID = state.spotifyPlayer.playingTrackID {
      let track = state.resources.tracksFor(ids: [trackID]).first!
      playBarTitleLabel.attributedText = "\(track.name) \u{2022} \(track.artistNames.first ?? "")".attributedStringForPartiallyColoredText(track.artistNames.first ?? "", with: UIColor.myDarkWhite)
      
      animateDuration(startTime: SpotifyPlayerActions.getCurrentPlayerPosition(), endTime: Double(track.durationMS) / 1000.0, isStopped: !isPlaying)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tabBarVC = loadUIViewControllerFromNib(TabBarController.self)
    addChildViewController(tabBarVC)
    containerView.insertSubview(tabBarVC.view, at: 0)
    
    tabBarVC.didMove(toParentViewController: self)
    
    playBarView.backgroundColor = UIColor.myLightBlack
    
    playBarTitleLabel.font = UIFont.myFont(withSize: 15)
    playBarTitleLabel.textColor = UIColor.myWhite
    
    durationBarView.backgroundColor = UIColor.myWhite
    durationBarBackground.backgroundColor = UIColor.myLighterBlack
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }
  
  func animateDuration(startTime: Double, endTime: Double, isStopped: Bool) {
    if self.endTime == endTime && isStopped == isDurationBarStopped { return }
    self.endTime = endTime
    isDurationBarStopped = isStopped
    
    durationBarView.layer.removeAllAnimations()
    

    isAnimatingDuration = true
    
    let percentCompleted = startTime / endTime
    let timeLeft = endTime - startTime
    
    let fullWidth = view.frame.size.width
    
    durationWidthConstraint.constant = fullWidth * CGFloat(1 - percentCompleted)
    
    view.layoutIfNeeded()
    
    if isStopped { return }
    
    UIView.animate(withDuration: timeLeft, delay: 0, options: .curveLinear, animations: {
      self.durationWidthConstraint.constant = 0
      self.view.layoutIfNeeded()
    }, completion: { finished in
      self.isAnimatingDuration = false
    })
  }
  
  private func setPlayPauseButtonImage(playing: Bool) {
    playPauseButton.setTitleColor(UIColor.myWhite, for: .normal)
    
    if playing {
      playPauseButton.setImage(UIImage(named: "roundedPause")?.withRenderingMode(.alwaysOriginal), for: .normal)
    } else {
      playPauseButton.setImage(UIImage(named: "roundedPlay")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
  }
}
