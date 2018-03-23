//
//  ItemWithTrackListHeaderView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/20/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class ItemWithTrackListHeaderView: UIView {
  @IBOutlet var itemImage: UIImageView!

  func setup(forItem item: Item) {
    if let imageURL = item.largeImageURL {
      itemImage.sd_setImage(with: imageURL, placeholderImage: UIImage.placeholder)
    } else {
      itemImage.image = UIImage.placeholder
    }
  }
}
