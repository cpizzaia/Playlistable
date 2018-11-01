//
//  PlayAndTabBarContainerViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class PlayAndTabBarContainerViewController: UIViewController {
  // MARK: Private Properties
  private let tabBar = TabBarView(tabs: [
    TabBarView.Tab(
      viewController: UINavigationController(rootViewController: GeneratedPlaylistViewController()),
      imageString: "PlaylistTab",
      name: "Playlist"
    ),
    TabBarView.Tab(
      viewController: UINavigationController(rootViewController: SeedsViewController()),
      imageString: "SeedsTab",
      name: "Seeds"
    ),
    TabBarView.Tab(
      viewController: UINavigationController(rootViewController: SearchViewController()),
      imageString: "SearchTab",
      name: "Search"
    )
  ])

  // MARK: Public Methods
  init() {
    super.init(nibName: nil, bundle: nil)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private Methods
  private func setupViews() {
    view.addSubview(tabBar)

    tabBar.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }
  }
}
