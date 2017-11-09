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
  
  func setupCellFor(item: Track) {
    titleLabel.text = item.name
    if let mediumImageURL = item.mediumImageURL {
      itemImage.sd_setImage(with: mediumImageURL)
    }
  }
}
