//
//  WrapInDispatchMiddleware.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/15/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

let wrapInDispatchMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      guard let wrappedAction = action as? WrapInDispatch else {
        next(action)
        return
      }

      // FIXME: Wrapped actions can return other wrapped actions and we need can't call
      // next on it cause it will still be wrapped, so we just use the stores dispatch
      // to repeat for now.
      wrappedAction.body(mainStore.dispatch)
    }
  }
}

struct WrapInDispatch: Action {
  let body: (@escaping DispatchFunction) -> Void
}
