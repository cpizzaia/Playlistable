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
  // MARK: Public Properties
  var seededCell: Bool {
    get {
      return _seededCell
    } set {
      runOnMainThread {
        self.backgroundColor = newValue ? UIColor.myAccent.withAlphaComponent(0.5) : UIColor.clear

        self._seededCell = newValue
      }
    }
  }

  var currentlyPlaying: Bool {
    get {
      return _currentlyPlaying
    } set {
      titleLabel.textColor = newValue ? UIColor.myAccent : UIColor.myWhite
      _currentlyPlaying = newValue
    }
  }

  var item: Item? {
    return _item
  }

  // MARK: Private Properties
  private let labelStackView = UIStackView()
  private let titleLabel = UILabel()
  private let subTitleLabel = UILabel()
  private let itemImage = UIImageView()
  private let actionButton = UIButton()
  private var _seededCell = false
  private var _currentlyPlaying = false
  private var innerGradient: CALayer?
  private var currentImageURL: URL?
  private var action = {}
  private var _item: Item?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupCellWithImage(forItem item: Item, actionSymbol: String = ">", action: (() -> Void)?) {
    showImage()
    setupCell(forItem: item, actionSymbol: actionSymbol, action: action)
  }

  func setupCellWithoutImage(forItem item: Item, actionSymbol: String = ">", action: (() -> Void)?) {
    hideImage()
    setupCell(forItem: item, actionSymbol: actionSymbol, action: action)
  }

  @objc func actionButtonTapped(_ sender: UIButton) {
    action()
  }

  // MARK: Private Methods
  private func setupViews() {
    backgroundColor = seededCell ? UIColor.myAccent.withAlphaComponent(0.5) : UIColor.clear
    selectionStyle = .none

    setupItemImage()
    setupLabelStackView()
    setupTitleLabel()
    setupSubTitleLabel()
    setupActionButton()
  }

  private func setupItemImage() {
    contentView.addSubview(itemImage)

    itemImage.snp.makeConstraints { make in
      make.height.equalTo(contentView).multipliedBy(0.8)
      make.width.equalTo(itemImage.snp.height)
      make.leading.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }

    itemImage.contentMode = .scaleAspectFill
    itemImage.clipsToBounds = true
  }

  private func setupLabelStackView() {
    contentView.addSubview(labelStackView)

    labelStackView.snp.makeConstraints { make in
      make.leading.equalTo(itemImage.snp.trailing).offset(20)
      make.width.equalTo(contentView).multipliedBy(0.8)
      make.centerY.equalTo(contentView)
    }

    labelStackView.axis = .vertical
  }

  private func setupTitleLabel() {
    labelStackView.addArrangedSubview(titleLabel)

    labelStackView.snp.makeConstraints { make in
      make.leading.equalTo(labelStackView)
      make.width.equalTo(labelStackView)
    }

    titleLabel.textColor = UIColor.myWhite
    titleLabel.font = UIFont.myFont(withSize: 17)
  }

  private func setupSubTitleLabel() {
    labelStackView.addArrangedSubview(subTitleLabel)

    subTitleLabel.snp.makeConstraints { make in
      make.leading.equalTo(labelStackView)
      make.width.equalTo(labelStackView)
    }

    subTitleLabel.font = UIFont.myFont(withSize: 15)
    subTitleLabel.textColor = UIColor.myGray
  }

  private func setupActionButton() {
    contentView.addSubview(actionButton)

    actionButton.snp.makeConstraints { make in
      make.width.equalTo(labelStackView).multipliedBy(0.2)
      make.trailing.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }

    actionButton.setTitleColor(UIColor.myWhite, for: .normal)
    actionButton.titleLabel?.font = UIFont.myFontBold(withSize: 23)

    actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
  }

  private func showImage() {
    runOnMainThread {
      self.itemImage.snp.remakeConstraints { make in
        make.height.equalTo(self.contentView).multipliedBy(0.8)
        make.width.equalTo(self.itemImage.snp.height)
        make.leading.equalTo(self.contentView).offset(10)
        make.centerY.equalTo(self.contentView)
      }
    }
  }

  private func hideImage() {
    runOnMainThread {
      self.itemImage.snp.remakeConstraints { make in
        make.height.equalTo(self.contentView).multipliedBy(0.8)
        make.width.equalTo(0)
        make.leading.equalTo(self.contentView).offset(10)
        make.centerY.equalTo(self.contentView)
      }
    }
  }

  private func setupCell(forItem item: Item, actionSymbol: String, action: (() -> Void)?) {
    self.action = action ?? {}
    titleLabel.text = item.title
    if let mediumImageURL = item.mediumImageURL {
      if currentImageURL != mediumImageURL {
        itemImage.sd_setImage(with: mediumImageURL)
        currentImageURL = mediumImageURL
      }
    } else {
      itemImage.image = UIImage.placeholder
      currentImageURL = nil
    }

    itemImage.contentMode = .scaleAspectFill

    if action != nil {
      actionButton.setTitle(actionSymbol, for: .normal)
      actionButton.isEnabled = true
    } else {
      actionButton.setTitle("", for: .normal)
      actionButton.isEnabled = false
    }

    if let subTitle = item.subTitle {
      subTitleLabel.isHidden = false
      subTitleLabel.text = subTitle
    } else {
      subTitleLabel.isHidden = true
    }

    currentlyPlaying = false
    self._item = item
  }
}
