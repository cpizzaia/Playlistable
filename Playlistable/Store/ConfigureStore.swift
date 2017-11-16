//
//  ConfigureStore.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

let mainStore = Store<AppState>(
  reducer: appReducer,
  state: nil,
  middleware: [wrapInDispatchMiddleware, apiMiddleware, loggingMiddleware]
)
