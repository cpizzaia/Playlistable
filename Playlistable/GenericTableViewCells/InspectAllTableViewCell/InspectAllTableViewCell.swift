//
//  InspectAllTableViewCell.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/8/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class InspectAllTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var itemImage: UIImageView!
  @IBOutlet var actionButton: UIButton!
  @IBAction func actionButtonTapped(_ sender: UIButton) {
    action()
  }
  
  var seededCell: Bool {
    get {
      return _seededCell
    } set {
      backgroundColor = newValue ? .cyan : .clear
      _seededCell = newValue
    }
  }
  
  var action = {}
  
  private var _seededCell = false
  
  func setupCellFor(item: Item, action: (() -> ())?) {
    self.action = action ?? {}
    titleLabel.text = item.title
    if let mediumImageURL = item.mediumImageURL {
      itemImage.sd_setImage(with: mediumImageURL)
    } else {
      itemImage.image = UIImage.placeholder
    }
    
    itemImage.contentMode = .scaleAspectFill
    
    if action != nil {
      actionButton.setTitle(">", for: .normal)
      actionButton.isEnabled = true
    } else {
      actionButton.setTitle("", for: .normal)
      actionButton.isEnabled = false
    }
  }
}
