//
//  StateManager.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/16/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

protocol StateManager: StoreSubscriber {
  static func start()
}
