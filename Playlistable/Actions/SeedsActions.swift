//
//  SeedsActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/9/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

enum SeedsActions {
  struct AddSeed: Action {
    let item: Item
  }

  struct RemoveSeed: Action {
    let item: Item
  }

  struct GeneratedFromSeeds: Action {
    let seeds: SeedsState
  }
}
