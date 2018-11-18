//
//  PlayBarView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/1/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

protocol PlayBarViewDelegate: class {
  func didTapPlayButton()
  func didTapPauseButton()
}

class PlayBarView: UIView {
  // MARK: Public Properties
  weak var delegate: PlayBarViewDelegate?

  // MARK: Private Properties
  private let trackTitleLabel = UILabel()
  private let pausePlayButton = ImageButton()
  private let trackInfoContainer = UIView()
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
    self.isPlaying = isPlaying
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

  @objc func pausePlayButtonTapped() {
    isPlaying ? delegate?.didTapPauseButton() : delegate?.didTapPlayButton()
  }

  // MARK: Private Methods
  private func setupViews() {
    snp.makeConstraints { make in
      make.height.equalTo(49)
    }

    backgroundColor = .myLightBlack
    clipsToBounds = true

    setupDurationBarBackground()
    setupDurationBar()
    setupTrackInfoContainer()
    setupPausePlayButton()
    setupTrackTitleLabel()
  }

  private func setupTrackInfoContainer() {
    addSubview(trackInfoContainer)

    trackInfoContainer.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(self)
      make.bottom.equalTo(durationBarBackground.snp.top)
    }
  }

  private func setupTrackTitleLabel() {
    trackInfoContainer.addSubview(trackTitleLabel)

    trackTitleLabel.snp.makeConstraints { make in
      make.center.equalTo(trackInfoContainer)
      make.trailing.lessThanOrEqualTo(pausePlayButton.snp.leading).offset(-15)
      make.height.equalTo(trackInfoContainer)
    }

    trackTitleLabel.textAlignment = .center
    trackTitleLabel.font = .myFont(withSize: 15)
    trackTitleLabel.textColor = UIColor.myWhite
  }

  private func setupPausePlayButton() {
    trackInfoContainer.addSubview(pausePlayButton)

    pausePlayButton.snp.makeConstraints { make in
      make.centerY.equalTo(trackInfoContainer)
      make.width.equalTo(pausePlayButton.snp.height)
      make.trailing.equalTo(trackInfoContainer).inset(12)
      make.height.equalTo(25)
    }

    pausePlayButton.button.addTarget(self, action: #selector(pausePlayButtonTapped), for: .touchUpInside)
    pausePlayButton.imageView.contentMode = .scaleAspectFit
  }

  private func setupDurationBarBackground() {
    addSubview(durationBarBackground)

    durationBarBackground.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self)
      make.bottom.equalTo(self)
      make.height.equalTo(2)
    }

    durationBarBackground.backgroundColor = .myDarkGray
  }

  private func setupDurationBar() {
    durationBarBackground.addSubview(durationBar)

    durationBar.snp.makeConstraints { make in
      make.leading.top.bottom.equalTo(durationBarBackground)
      make.width.equalTo(0)
    }

    durationBar.backgroundColor = .myWhite
  }

  private func updateFor(isPlaying: Bool) {
    runOnMainThread {
      self.pausePlayButton.button.setTitleColor(.myWhite, for: .normal)

      if isPlaying {
        self.pausePlayButton.imageView.image = UIImage(named: "pause")
      } else {
        self.pausePlayButton.imageView.image = UIImage(named: "logo")
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

      self.durationBar.snp.remakeConstraints { make in
        make.leading.top.bottom.equalTo(self.durationBarBackground)
        make.width.equalTo(fullWidth * CGFloat(percentCompleted))
      }

      self.layoutIfNeeded()

      if isStopped { return }

      self.isAnimatingDuration = true

      UIView.animate(withDuration: timeLeft, delay: 0, options: .curveLinear, animations: {
        self.durationBar.snp.remakeConstraints { make in
          make.leading.top.bottom.equalTo(self.durationBarBackground)
          make.width.equalTo(fullWidth)
        }

        self.layoutIfNeeded()
      }, completion: { _ in
        self.isAnimatingDuration = false
      })
    }
  }
}
