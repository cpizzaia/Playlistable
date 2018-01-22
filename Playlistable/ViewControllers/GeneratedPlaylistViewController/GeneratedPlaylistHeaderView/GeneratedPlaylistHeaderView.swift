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
  @IBOutlet var backgroundUpperHalf: UIView!
  @IBOutlet var backgroundLowerHalf: UIView!
  @IBOutlet var playButton: BigButton!
  @IBOutlet var generatePlaylistButton: BigButton!
  
  @IBAction func playButtonPressed(_ sender: BigButton) {
    action()
  }
  
  private var styled = false
  private var action = {}
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if styled { return }
    styled = true
    
    backgroundColor = UIColor.clear
    
    backgroundUpperHalf.backgroundColor = UIColor.myLightBlack
    backgroundLowerHalf.backgroundColor = UIColor.clear
    
    
    playButton.setTitle("SHUFFLE PLAY", for: .normal)
    
    addGradient()
  }
  
  func setupView(action: @escaping () -> ()) {
    self.action = action
  }
  
  private func addGradient() {
    let colour:UIColor = UIColor.myLightBlack
    let colours:[CGColor] = [colour.cgColor, colour.withAlphaComponent(0.0).cgColor]
    let locations:[NSNumber] = [0.1,0.9]
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = colours
    gradientLayer.locations = locations
    gradientLayer.frame = backgroundLowerHalf.bounds
    
    backgroundLowerHalf.layer.insertSublayer(gradientLayer, at: 0)
  }
  
}
