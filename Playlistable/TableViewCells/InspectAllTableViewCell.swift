//
//  InspectAllTableViewCell.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/8/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class InspectAllTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  
  func setupCellFor(item: Track) {
    titleLabel.text = item.name
  }
}
