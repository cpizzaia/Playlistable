//
//  SeedsReducer.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/9/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct SeedsState {
  typealias ID = String
  var items: [ID: Item]
  
  var isFull: Bool {
    get {
      return items.count >= 5
    }
  }
  
  func isInSeeds(item: Item) -> Bool {
    return items[item.id] != nil
  }
}

fileprivate let initialSeedsState = SeedsState(items: [:])

func seedsReducer(action: Action, state: SeedsState?) -> SeedsState {
  var state = state ?? initialSeedsState
  switch action {
  case let action as SeedsActions.AddSeed:
    if state.isFull { break }
    state.items[action.item.id] = action.item
  case let action as SeedsActions.RemoveSeed:
    state.items.removeValue(forKey: action.item.id)
  case _ as SeedsActions.GeneratedFromSeeds:
    state.items = [:]
  default:
    break
  }
  
  return state
}
