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
  @IBOutlet var itemImageHeightZeroConstraint: NSLayoutConstraint!
  @IBOutlet var itemImageHeightRegularConstraint: NSLayoutConstraint!

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subTitleLabel: UILabel!
  @IBOutlet var itemImage: UIImageView!
  @IBOutlet var actionButton: UIButton!
  @IBAction func actionButtonTapped(_ sender: UIButton) {
    action()
  }

  var seededCell: Bool {
    get {
      return _seededCell
    } set {
      DispatchQueue.main.async {
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

  var action = {}

  private var _seededCell = false
  private var _currentlyPlaying = false
  private var innerGradient: CALayer?
  private var currentImageURL: URL?

  func setupCellWithImage(forItem item: Item, actionSymbol: String = ">", action: (() -> Void)?) {
    showImage()
    setupCell(forItem: item, actionSymbol: actionSymbol, action: action)
  }

  func setupCellWithoutImage(forItem item: Item, actionSymbol: String = ">", action: (() -> Void)?) {
    hideImage()
    setupCell(forItem: item, actionSymbol: actionSymbol, action: action)
  }

  private func hideImage() {
    DispatchQueue.main.async {
      self.itemImageHeightRegularConstraint.isActive = false
      self.itemImageHeightZeroConstraint.isActive = true
    }
  }

  private func showImage() {
    DispatchQueue.main.async {
      self.itemImageHeightZeroConstraint.isActive = false
      self.itemImageHeightRegularConstraint.isActive = true
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

    styleCell()
  }

  private func styleCell() {
    titleLabel.textColor = UIColor.myWhite
    titleLabel.font = UIFont.myFont(withSize: 17)

    subTitleLabel.font = UIFont.myFont(withSize: 15)
    subTitleLabel.textColor = UIColor.myDarkWhite

    actionButton.setTitleColor(UIColor.myWhite, for: .normal)
    actionButton.titleLabel?.font = UIFont.myFontBold(withSize: 23)

    itemImage.contentMode = .scaleAspectFill
    itemImage.clipsToBounds = true

    backgroundColor = seededCell ? UIColor.myAccent.withAlphaComponent(0.5) : UIColor.clear
    selectionStyle = .none
  }
}
