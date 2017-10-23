//
//  APIMiddleware.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import SwiftyJSON

let apiMiddleware: Middleware<Any> = { dispatch, getState in
  return { next in
    return { action in
      guard let apiAction = action as? APIAction else { return next(action) }
      
      next(apiAction.types.requestAction)
      
      APIRequest.shared.request(params: translateToRequestParams(apiAction: apiAction, next: next))
    }
  }
}

fileprivate func translateToRequestParams(apiAction: APIAction, next: @escaping DispatchFunction) -> APIRequest.RequestParams {
  return APIRequest.RequestParams(
    url: apiAction.url,
    method: apiAction.method,
    body: apiAction.body,
    headers: apiAction.headers,
    success: { data in
      var successAction = apiAction.types.successAction
      successAction.payload = data
      
      next(successAction)
  },
    failure: { error in
      var failureAction = apiAction.types.failureAction
      
      failureAction.error = error
      
      next(failureAction)
  }
  )
}

struct APIAction: Action {
  let endpoint: String
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let body: Parameters?
  let types: APITypes
  var url: String {
    get {
      return "https://api.spotify.com" + endpoint
    }
  }
}

struct APITypes {
  let requestAction: Action
  let successAction: APIResponseSuccessAction
  let failureAction: APIResponseFailureAction
}

protocol APIResponseSuccessAction: Action {
  var payload: JSON { get set }
}

protocol APIResponseFailureAction: Action {
  var error: APIRequest.APIError { get set }
}
