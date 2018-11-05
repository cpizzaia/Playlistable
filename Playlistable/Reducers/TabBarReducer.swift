//
//  TabBarReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/1/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct TabBarState {
  var selectedIndex: Int
  let viewControllers: [UIViewController]

  var currentViewController: UIViewController {
    return viewControllers[selectedIndex]
  }
}

private let initialTabBarState = TabBarState(
  selectedIndex: 0,
  viewControllers: [
    MyNavigationController(rootViewController: GeneratedPlaylistViewController()),
    MyNavigationController(rootViewController: SeedsViewController()),
    MyNavigationController(rootViewController: SearchViewController())
  ]
)

func tabBarReducer(action: Action, state: TabBarState?) -> TabBarState {
  var state = state ?? initialTabBarState

  switch action {
  case let action as TabBarActions.SwitchTabIndex:
    state.selectedIndex = action.selectedIndex
    return state
  default:
    return state
  }
}
