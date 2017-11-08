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
      
      next(apiAction.types.requestAction.init())
      
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
    encoding: JSONEncoding.default,
    success: { data in
      parseResources(fromJSON: data, next: next)
      next(apiAction.types.successAction.init(response: data))
  },
    failure: { error in
      next(apiAction.types.failureAction.init(error: error))
  }
  )
}

struct CallSpotifyAPI: APIAction {
  let endpoint: String
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let body: Parameters?
  let bodyEncoding: ParameterEncoding
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
    headers = ["Authorization": "Bearer \(mainStore.state.spotifyAuth.token ?? "")"]
    body = nil
    bodyEncoding = JSONEncoding.default
  }
}

struct CallAPI: APIAction {
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let body: Parameters?
  let bodyEncoding: ParameterEncoding
  let types: APITypes
  let url: String
}

protocol APIAction: Action {
  var method: HTTPMethod { get }
  var headers: HTTPHeaders? { get }
  var body: Parameters? { get }
  var bodyEncoding: ParameterEncoding { get }
  var types: APITypes { get }
  var url: String { get }
}

struct APITypes {
  let requestAction: APIRequestAction.Type
  let successAction: APIResponseSuccessAction.Type
  let failureAction: APIResponseFailureAction.Type
}

protocol APIRequestAction: Action {
  init()
}

protocol APIResponseSuccessAction: Action {
  var response: JSON { get }
  init(response: JSON)
}

protocol APIResponseFailureAction: Action {
  var error: APIRequest.APIError { get }
  init(error: APIRequest.APIError)
}
