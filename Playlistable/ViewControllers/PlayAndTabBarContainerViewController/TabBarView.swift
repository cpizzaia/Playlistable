//
//  TabBarView.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

protocol TabBarViewDelegate: class {
  func selectedTab(atIndex: Int)
}

class TabBarView: UIView {
  // MARK: Public Types
  struct Tab {
    let imageString: String
    let name: String
  }

  // MARK: Private Types
  typealias TabUIElement = (label: UILabel, imageView: UIImageView)

  // MARK: Public Properties
  weak var delegate: TabBarViewDelegate?

  // MARK: Private Properties
  private let tabs: [Tab]
  private let stackView = UIStackView()
  private var tabUIElements = [TabUIElement]()
  private var currentTabIndex: Int

  // MARK: Public Methods
  init(tabs: [Tab], initialTabIndex: Int = 0) {
    self.tabs = tabs
    self.currentTabIndex = initialTabIndex
    super.init(frame: .zero)
    setupViews()
    setCurrentTab(index: initialTabIndex)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func tabPressed(_ button: UIButton) {
    self.switchToTab(index: button.tag)
  }

  func switchToTab(index: Int) {
    if currentTabIndex == index { return }

    setCurrentTab(index: index)
    delegate?.selectedTab(atIndex: index)
  }

  // MARK: Private Methods
  private func setupViews() {
    backgroundColor = .myLightBlack

    snp.makeConstraints { make in
      make.height.equalTo(49)
    }

    setupStackView()
    setupViewsForTabs()
  }

  private func setupStackView() {
    addSubview(stackView)

    stackView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }

    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
  }

  private func setupViewsForTabs() {
    tabs.enumerated().forEach(setup)
  }

  private func setup(index: Int, tab: Tab) {
    let backgroundView = UIView()
    let imageView = UIImageView()
    let button = UIButton()
    let nameLabel = UILabel()

    stackView.addArrangedSubview(backgroundView)

    // Setting up tab background
    backgroundView.snp.makeConstraints { make in
      make.height.equalTo(stackView)
    }

    // Setting up tab image
    backgroundView.addSubview(imageView)

    imageView.snp.makeConstraints { make in
      make.width.height.equalTo(25)
      make.centerX.equalTo(backgroundView)
      make.top.equalTo(backgroundView).offset(4)
    }

    let image = UIImage(named: tab.imageString)?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = .myGray
    imageView.image = image

    // Setting up tab name
    backgroundView.addSubview(nameLabel)

    nameLabel.snp.makeConstraints { make in
      make.centerX.equalTo(backgroundView)
      make.bottom.equalTo(backgroundView).inset(3)
    }

    nameLabel.text = tab.name
    nameLabel.font = .myFont(withSize: 10)
    nameLabel.textColor = .myGray

    tabUIElements.append((label: nameLabel, imageView: imageView))

    // Setting up tab button
    backgroundView.addSubview(button)
    button.snp.makeConstraints { make in
      make.center.equalTo(backgroundView)
      make.height.equalTo(backgroundView.snp.height)
      make.width.equalTo(button.snp.height)
    }

    button.addTarget(self, action: #selector(tabPressed), for: .touchUpInside)
    button.tag = index
  }

  private func setCurrentTab(index: Int) {
    runOnMainThread {
      let currentTabUIElement = self.tabUIElements[self.currentTabIndex]
      let selectedTabUIElement = self.tabUIElements[index]

      currentTabUIElement.imageView.tintColor = .myGray
      currentTabUIElement.label.textColor = .myGray

      selectedTabUIElement.imageView.tintColor = .myWhite
      selectedTabUIElement.label.textColor = .myWhite

      self.currentTabIndex = index
    }
  }
}
