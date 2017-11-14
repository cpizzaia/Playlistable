//
//  LoggingMiddlware.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

let loggingMiddleware: Middleware<Any> = { dispatch, getState in
  return { next in
    return { action in
      log("\(String(describing: type(of: action)))")
      
      next(action)
    }
  }
}
