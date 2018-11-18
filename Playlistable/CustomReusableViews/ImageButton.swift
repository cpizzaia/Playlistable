//
//  ImageButton.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/17/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class ImageButton: UIView {
  // MARK: Public Properties
  let imageView = UIImageView()
  let button = UIButton()

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
    setupImageView()
    setupButton()
  }

  private func setupImageView() {
    addSubview(imageView)

    imageView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }

  private func setupButton() {
    addSubview(button)

    button.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }
}
