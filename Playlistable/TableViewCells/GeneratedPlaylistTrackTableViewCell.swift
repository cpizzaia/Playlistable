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
  @IBOutlet var trackImage: UIImageView!
  @IBOutlet var trackTitle: UILabel!
  
  var currentlyPlaying: Bool {
    get {
      return _currentlyPlaying
    } set {
      trackTitle.textColor = newValue ? .blue : .black
      _currentlyPlaying = newValue
    }
  }
  
  private var _currentlyPlaying = false
  
  func setupCell(forTrack track: Track) {
    trackTitle.text = track.name
    if let mediumImageURL = track.mediumImageURL {
      trackImage.sd_setImage(with: mediumImageURL)
    }
  }
  
}