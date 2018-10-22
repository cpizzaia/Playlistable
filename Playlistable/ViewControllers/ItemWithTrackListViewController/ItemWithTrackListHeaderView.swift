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
  // MARK: Private Properties
  private let itemImageView = UIImageView()

  // MARK: Public Methods
  init(item: Item) {
    super.init(frame: .zero)
    setupImageView(item: item)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private Methods
  private func setupImageView(item: Item) {
    addSubview(itemImageView)

    itemImageView.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self)
      make.height.equalTo(itemImageView.snp.width)
    }

    itemImageView.sd_setImage(with: item.largeImageURL, placeholderImage: UIImage.placeholder)
  }
}
