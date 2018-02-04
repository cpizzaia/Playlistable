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
      trackTitle.textColor = newValue ? UIColor.myAccent : UIColor.myWhite
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
    
    // FIXME: Will add this back in later when I'm ready to implement saved tracks
//    switch actionType {
//    case .add:
//      saveTrackButton.setTitle("+", for: .normal)
//    case .remove:
//      saveTrackButton.setTitle("-", for: .normal)
//    }
    
    saveTrackButton.setTitle("", for: .normal)
    saveTrackButton.isEnabled = false
    
    styleCell()
  }
  
  private func styleCell() {
    trackTitle.font = UIFont.myFont(withSize: 17)
    trackTitle.textColor = UIColor.myWhite
    
    saveTrackButton.setTitleColor(UIColor.myWhite, for: .normal)
    saveTrackButton.titleLabel?.font = UIFont.myFontBold(withSize: 25)
    
    backgroundColor = UIColor.clear
  }
  
}
