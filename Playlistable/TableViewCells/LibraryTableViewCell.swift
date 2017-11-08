//
//  LibraryTableViewCell.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/7/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class LibraryTableViewCell: UITableViewCell {
  @IBOutlet var titleLabel: UILabel!
  
  func setupCellWith(title: String) {
    titleLabel.text = title
  }
  
}
