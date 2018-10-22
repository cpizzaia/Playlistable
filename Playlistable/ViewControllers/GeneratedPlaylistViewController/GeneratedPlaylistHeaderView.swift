//
//  GeneratedPlaylistHeaderView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/21/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class GeneratedPlaylistHeaderView: UIView {
  // MARK: Private Properties
  private let backgroundUpperHalf = UIView()
  private let backgroundLowerHalf = UIView()
  private let playButton = BigButton()
  private var styled = false
  private let action: () -> Void

  // MARK: Public Methods
  init(action: @escaping () -> Void) {
    self.action = action

    super.init(frame: .zero)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if styled { return }

    styled = true

    addGradient()
  }

  @objc func playButtonPressed(_ sender: BigButton) {
    action()
  }

  // MARK: Private Methods
  private func setupViews() {
    backgroundColor = UIColor.clear

    setupBackgroundUpperHalf()
    setupBackgroundLowerHalf()
    setupPlayButton()
  }

  private func setupBackgroundUpperHalf() {
    addSubview(backgroundUpperHalf)

    backgroundUpperHalf.snp.makeConstraints { make in
      make.height.equalTo(self).multipliedBy(0.5)
      make.top.leading.trailing.equalTo(self)
    }

    backgroundUpperHalf.backgroundColor = UIColor.myLightBlack
  }

  private func setupBackgroundLowerHalf() {
    addSubview(backgroundLowerHalf)

    backgroundLowerHalf.snp.makeConstraints { make in
      make.height.equalTo(self).multipliedBy(0.5)
      make.bottom.trailing.leading.equalTo(self)
    }

    backgroundLowerHalf.backgroundColor = UIColor.clear
  }

  private func setupPlayButton() {
    addSubview(playButton)

    playButton.snp.makeConstraints { make in
      make.height.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.55)
      make.centerX.equalTo(self)
    }

    playButton.setTitle("SHUFFLE PLAY", for: .normal)
    playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
  }

  private func addGradient() {
    let colour: UIColor = UIColor.myLightBlack
    let colours: [CGColor] = [colour.cgColor, colour.withAlphaComponent(0.0).cgColor]
    let locations: [NSNumber] = [0.1, 0.9]

    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = colours
    gradientLayer.locations = locations
    gradientLayer.frame = backgroundLowerHalf.bounds

    backgroundLowerHalf.layer.insertSublayer(gradientLayer, at: 0)
  }

}
