//
//  SearchResultSectionHeaderView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class SearchResultSectionHeaderView: UIView {
  // MARK: Outlets
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var actionButton: UIButton!
  @IBAction func actionButtonTapped(_ sender: UIButton) {
    action()
  }

  // MARK: Private Properties
  var action = {}

  // MARK: Public Methods
  func setupView(withTitle title: String, buttonTitle: String, andAction action: @escaping () -> Void) {
    titleLabel.text = title
    actionButton.setTitle(buttonTitle, for: .normal)
    self.action = action

    styleView()
  }

  // MARK: Private Methods
  private func styleView() {
    titleLabel.textColor = UIColor.myWhite
    titleLabel.font = UIFont.myFontBold(withSize: 17)

    actionButton.titleLabel?.font = UIFont.myFontBold(withSize: 17)
    actionButton.setTitleColor(UIColor.myWhite, for: .normal)

    backgroundColor = UIColor.myDarkBlack
  }
}
