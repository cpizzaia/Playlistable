//
//  NoSearchResultsView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/19/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class NoSearchResultsView: UIView {
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

  func switchToHasSearched() {
    DispatchQueue.main.async {
      self.descriptionLabel.text = "Your search had no results"
    }
  }

  func switchToHasntSearched() {
    DispatchQueue.main.async {
      self.descriptionLabel.text = "Start by searching for your favorite music"
    }
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
      make.width.equalTo(self)
    }

    descriptionLabel.textAlignment = .center
    descriptionLabel.font = UIFont.myFont(withSize: 17)
    descriptionLabel.textColor = UIColor.myWhite
  }
}
