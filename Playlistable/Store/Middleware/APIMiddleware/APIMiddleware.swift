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
      guard let apiAction = action as? CallSpotifyAPI else { return next(action) }
      
      next(apiAction.types.requestAction)
      
      APIRequest.shared.request(params: translateToRequestParams(apiAction: apiAction, next: next))
    }
  }
}

fileprivate func translateToRequestParams(apiAction: CallSpotifyAPI, next: @escaping DispatchFunction) -> APIRequest.RequestParams {
  return APIRequest.RequestParams(
    url: apiAction.url,
    method: apiAction.method,
    body: apiAction.body,
    headers: apiAction.headers,
    success: { data in
      parseResources(fromJSON: data, next: next)
      next(apiAction.types.successAction.init(response: data))
  },
    failure: { error in
      next(apiAction.types.failureAction.init(error: error))
  }
  )
}

struct CallSpotifyAPI: Action {
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
  
  init(endpoint: String, method: HTTPMethod, types: APITypes) {
    self.endpoint = endpoint
    self.method = method
    self.types = types
    headers = nil
    body = nil
  }
}

struct APITypes {
  let requestAction: Action
  let successAction: APIResponseSuccessAction.Type
  let failureAction: APIResponseFailureAction.Type
}

protocol APIResponseSuccessAction: Action {
  var response: JSON { get }
  init(response: JSON)
}

protocol APIResponseFailureAction: Action {
  var error: APIRequest.APIError { get }
  init(error: APIRequest.APIError)
}
