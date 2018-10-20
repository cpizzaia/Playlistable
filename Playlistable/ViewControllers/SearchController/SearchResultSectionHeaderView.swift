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

  // MARK: Private Properties
  private let titleLabel = UILabel()
  private let actionButton = UIButton()
  private let action: () -> Void

  // MARK: Public Methods
  init(withTitle title: String, buttonTitle: String, andAction action: @escaping () -> Void) {
    titleLabel.text = title
    actionButton.setTitle(buttonTitle, for: .normal)
    self.action = action

    super.init(frame: .zero)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func actionButtonTapped(_ sender: UIButton) {
    action()
  }

  // MARK: Private Methods
  private func setupViews() {
    backgroundColor = UIColor.myDarkBlack

    setupTitleLabel()
    setupActionButton()
  }

  private func setupTitleLabel() {
    addSubview(titleLabel)

    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(10)
      make.centerY.equalTo(self)
    }

    titleLabel.textColor = UIColor.myWhite
    titleLabel.font = UIFont.myFontBold(withSize: 17)
  }

  private func setupActionButton() {
    addSubview(actionButton)

    actionButton.snp.makeConstraints { make in
      make.trailing.equalTo(self).inset(10)
      make.centerY.equalTo(self)
    }

    actionButton.titleLabel?.font = UIFont.myFontBold(withSize: 17)
    actionButton.setTitleColor(UIColor.myWhite, for: .normal)
    actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
  }
}
