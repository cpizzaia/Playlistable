//
//  GeneratedPlaylistTrackTableViewCell.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/13/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class GeneratedPlaylistTrackTableViewCell: UITableViewCell {
  enum ActionType {
    case add
    case remove
  }
  
  @IBOutlet var trackImage: UIImageView!
  @IBOutlet var trackTitle: UILabel!
  @IBOutlet var saveTrackButton: UIButton!
  @IBAction func saveTrackButtonTapped(_ sender: UIButton) {
    action?()
  }
  
  var currentlyPlaying: Bool {
    get {
      return _currentlyPlaying
    } set {
      trackTitle.textColor = newValue ? .blue : .black
      _currentlyPlaying = newValue
    }
  }
  
  var action: (() -> ())?
  
  
  private var _currentlyPlaying = false
  
  func setupCell(forTrack track: Track, actionType: ActionType, action: (() -> ())?) {
    self.action = action
    
    trackTitle.text = track.name
    
    if let mediumImageURL = track.mediumImageURL {
      trackImage.sd_setImage(with: mediumImageURL)
    }
    
    switch actionType {
    case .add:
      saveTrackButton.setTitle("+", for: .normal)
    case .remove:
      saveTrackButton.setTitle("-", for: .normal)
    }
    
    
  }
  
}
