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

class PlayerBarContainerViewController: UIViewController, MyStoreSubscriber {

  typealias StoreSubscriberStateType = AppState

  struct Props {
    let currentState: AppState
    let isPlaying: Bool
    let playingTrack: Track?
  }

  @IBOutlet var containerView: UIView!
  @IBOutlet var playBarView: UIView!
  @IBOutlet var durationBarBackground: UIView!
  @IBOutlet var durationBarView: UIView!
  @IBOutlet var playBarTitleLabel: UILabel!
  @IBOutlet var durationWidthConstraint: NSLayoutConstraint!
  @IBOutlet var playPauseButton: UIButton!
  @IBAction func playPauseButtonPressed(_ sender: UIButton) {
    if props?.isPlaying == true {
      mainStore.dispatch(SpotifyPlayerActions.pause())
    } else {
      mainStore.dispatch(SpotifyPlayerActions.resume())
    }
  }

  var isAnimatingDuration = false
  var endTime: Double?
  var props: Props?

  func mapStateToProps(state: AppState) -> PlayerBarContainerViewController.Props {
    let playingTrack: Track?

    if let trackID = state.spotifyPlayer.playingTrackID {
      playingTrack = state.resources.trackFor(id: trackID)
    } else {
      playingTrack = nil
    }

    return Props(
      currentState: state,
      isPlaying: state.spotifyPlayer.isPlaying,
      playingTrack: playingTrack
    )
  }

  func didReceiveNewProps(props: Props) {
    playBarView.isHidden = props.playingTrack == nil
    setPlayPauseButtonImage(playing: props.isPlaying)
    isPlayerBarHidden = playBarView.isHidden

    if let track = props.playingTrack {
      playBarTitleLabel.attributedText = "\(track.name) \u{2022} \(track.artistNames.first ?? "")".attributedStringForPartiallyColoredText(track.artistNames.first ?? "", with: UIColor.myDarkWhite)

      animateDuration(startTime: SpotifyPlayerActions.getCurrentPlayerPosition(), endTime: Double(track.durationMS) / 1000.0, isStopped: !props.isPlaying)
    }
  }

  @objc func enteredForeground() {
    guard let state = props?.currentState else { return }
    newState(state: state)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tabBarVC = loadUIViewControllerFromNib(TabBarController.self)
    addChild(tabBarVC)
    containerView.insertSubview(tabBarVC.view, at: 0)

    tabBarVC.didMove(toParent: self)

    playBarView.backgroundColor = UIColor.myLightBlack

    playBarTitleLabel.font = UIFont.myFont(withSize: 15)
    playBarTitleLabel.textColor = UIColor.myWhite

    durationBarView.backgroundColor = UIColor.myWhite
    durationBarBackground.backgroundColor = UIColor.myLighterBlack
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(enteredForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)

    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  func animateDuration(startTime: Double, endTime: Double, isStopped: Bool) {
    if isAnimatingDuration && !isStopped && self.endTime == endTime { return }
    self.endTime = endTime

    durationBarView.layer.removeAllAnimations()

    let percentCompleted = startTime / endTime
    let timeLeft = endTime - startTime

    let fullWidth = view.frame.size.width

    durationWidthConstraint.constant = fullWidth * CGFloat(1 - percentCompleted)

    view.layoutIfNeeded()

    if isStopped { return }

    isAnimatingDuration = true

    UIView.animate(withDuration: timeLeft, delay: 0, options: .curveLinear, animations: {
      self.durationWidthConstraint.constant = 0
      self.view.layoutIfNeeded()
    }, completion: { _ in
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
