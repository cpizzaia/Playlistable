//
//  NoPlaylistView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class NoPlaylistView: UIView {
  // MARK: Private Properties
  private let descriptionLabel = UILabel()

  // MARK: Public Methods
  init() {
    super.init(frame: .zero)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private Methods
  private func setupViews() {
    backgroundColor = .clear

    setupDescriptionLabel()
  }

  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)

    descriptionLabel.snp.makeConstraints { make in
      make.center.equalTo(self)
    }

    descriptionLabel.font = UIFont.myFont(withSize: 17)
    descriptionLabel.textColor = UIColor.myWhite
    descriptionLabel.text = "Your generated playlist will appear here."
  }
}
