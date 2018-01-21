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
  @IBOutlet var itemImageHeightZeroConstraint: NSLayoutConstraint!
  @IBOutlet var itemImageHeightRegularConstraint: NSLayoutConstraint!
  
  
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
      backgroundColor = newValue ? .yellow : .clear
      _seededCell = newValue
    }
  }
  
  var action = {}
  
  private var _seededCell = false
  
  func setupCellWithImage(forItem item: Item, action: (() -> ())?) {
    showImage()
    setupCell(forItem: item, action: action)
  }
  
  func setupCellWithoutImage(forItem item: Item, action: (() -> ())?) {
    hideImage()
    setupCell(forItem: item, action: action)
  }
  
  private func hideImage() {
    DispatchQueue.main.async {
      self.itemImageHeightRegularConstraint.isActive = false
      self.itemImageHeightZeroConstraint.isActive = true
    }
  }
  
  private func showImage() {
    DispatchQueue.main.async {
      self.itemImageHeightZeroConstraint.isActive = false
      self.itemImageHeightRegularConstraint.isActive = true
    }
  }
  
  private func setupCell(forItem item: Item, action: (() -> ())?) {
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
    
    styleCell()
  }
  
  private func styleCell() {
    titleLabel.textColor = UIColor.myWhite
    titleLabel.font = UIFont.myFont(withSize: 17)
    
    actionButton.setTitleColor(UIColor.myWhite, for: .normal)
    actionButton.titleLabel?.font = UIFont.myFont(withSize: 17)
    
    backgroundColor = UIColor.clear
  }
}
