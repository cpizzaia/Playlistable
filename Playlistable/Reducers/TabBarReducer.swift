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
}

private let initialTabBarState = TabBarState(selectedIndex: 0)

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
