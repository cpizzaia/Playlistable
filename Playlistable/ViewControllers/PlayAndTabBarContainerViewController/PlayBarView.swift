//
//  PlayBarView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/1/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class PlayBarView: UIView {
  // MARK: Private Properties
  private let trackTitleLabel = UILabel()
  private let pausePlayButton = UIButton()
  private let durationBarBackground = UIView()
  private let durationBar = UIView()
  private var endTime: Double = 0
  private var isPlaying = false
  private var isAnimatingDuration = false

  // MARK: Public Methods
  init() {
    super.init(frame: .zero)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(forTrack track: Track, startTime: Double, endTime: Double, isPlaying: Bool) {
    updateFor(isPlaying: isPlaying)
    updateTitleLabel(forTrack: track)
    animateDuration(startTime: startTime, endTime: endTime, isStopped: !isPlaying)
  }

  func hide() {
    runOnMainThread {
      self.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
    }
  }

  func show() {
    runOnMainThread {
      self.snp.updateConstraints { make in
        make.height.equalTo(49)
      }
    }
  }

  // MARK: Private Methods
  private func setupViews() {
    snp.makeConstraints { make in
      make.height.equalTo(49)
    }

    backgroundColor = .myLightBlack
    clipsToBounds = true

    setupTrackTitleLabel()
    setupPausePlayButton()
    setupDurationBarBackground()
    setupDurationBar()
  }

  private func setupTrackTitleLabel() {
    addSubview(trackTitleLabel)

    trackTitleLabel.snp.makeConstraints { make in
      make.center.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.7)
      make.height.equalTo(self)
    }

    trackTitleLabel.textAlignment = .center
    trackTitleLabel.font = .myFont(withSize: 15)
    trackTitleLabel.textColor = UIColor.myWhite
  }

  private func setupPausePlayButton() {
    addSubview(pausePlayButton)

    pausePlayButton.snp.makeConstraints { make in
      make.centerY.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.08)
      make.trailing.equalTo(self).inset(8)
      make.height.equalTo(pausePlayButton.snp.height)
    }
  }

  private func setupDurationBarBackground() {
    addSubview(durationBarBackground)

    durationBarBackground.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self)
      make.bottom.equalTo(self)
      make.height.equalTo(2)
    }

    durationBarBackground.backgroundColor = .green
  }

  private func setupDurationBar() {
    durationBarBackground.addSubview(durationBar)

    durationBar.snp.makeConstraints { make in
      make.leading.top.bottom.equalTo(durationBarBackground)
      make.width.equalTo(0)
    }

    durationBar.backgroundColor = .red
  }

  private func updateFor(isPlaying: Bool) {
    runOnMainThread {
      self.pausePlayButton.setTitleColor(.myWhite, for: .normal)

      if isPlaying {
        self.pausePlayButton.setImage(UIImage(named: "roundedPause")?.withRenderingMode(.alwaysOriginal), for: .normal)
      } else {
        self.pausePlayButton.setImage(UIImage(named: "roundedPlay")?.withRenderingMode(.alwaysOriginal), for: .normal)
      }
    }
  }

  private func updateTitleLabel(forTrack track: Track) {
    runOnMainThread {
      self.trackTitleLabel.attributedText = "\(track.name) \u{2022} \(track.artistNames.first ?? "")".attributedStringForPartiallyColoredText(track.artistNames.first ?? "", with: .myGray)
    }
  }

  func animateDuration(startTime: Double, endTime: Double, isStopped: Bool) {
    runOnMainThread {
      if self.isAnimatingDuration && !isStopped && self.endTime == endTime { return }

      self.endTime = endTime

      self.durationBar.layer.removeAllAnimations()

      let percentCompleted = startTime / endTime
      let timeLeft = endTime - startTime

      let fullWidth = self.frame.size.width

      self.durationBar.snp.updateConstraints { update in
        update.width.equalTo(fullWidth * CGFloat(1 - percentCompleted))
      }

      self.layoutIfNeeded()

      if isStopped { return }

      self.isAnimatingDuration = true

      self.durationBar.snp.updateConstraints { update in
        update.width.equalTo(fullWidth)
      }

      UIView.animate(withDuration: timeLeft, delay: 0, options: .curveLinear, animations: {
        self.layoutIfNeeded()
      }, completion: { _ in
        self.isAnimatingDuration = false
      })
    }
  }
}
