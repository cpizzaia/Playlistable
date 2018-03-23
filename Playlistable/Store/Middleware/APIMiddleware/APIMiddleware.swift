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

let apiMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      guard let apiAction = action as? APIAction else { return next(action) }

      next(apiAction.types.requestAction.init())

      APIRequest.shared.request(params: translateToRequestParams(apiAction: apiAction, next: next, getState: getState))
    }
  }
}

private func translateToRequestParams(apiAction: APIAction, next: @escaping DispatchFunction, getState: @escaping () -> AppState?) -> APIRequest.RequestParams {
  return APIRequest.RequestParams(
    url: apiAction.url,
    method: apiAction.method,
    body: apiAction.body,
    headers: apiAction.headers,
    encoding: apiAction.bodyEncoding,
    success: { data in
      parseResources(fromJSON: data, next: next)
      next(apiAction.types.successAction.init(response: data))
      guard let state = getState() else { return }
      apiAction.success?(state)
  },
    failure: { error in
      next(apiAction.types.failureAction.init(error: error))
      apiAction.failure?()
  }
  )
}

struct CallSpotifyAPI: APIAction {
  let endpoint: String
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let body: Parameters?
  let queryParams: QueryParams?
  let bodyEncoding: ParameterEncoding
  let types: APITypes
  let success: ((AppState) -> Void)?
  let failure: (() -> Void)?
  var url: String {
    return "https://api.spotify.com" + endpoint + queryString
  }
  private var queryString: String {
    return queryParams?.reduce("?", { result, keyValue in
      return result + "&\(keyValue.key)=\(keyValue.value)"
    }) ?? ""
  }

  init(endpoint: String, queryParams: QueryParams? = nil, method: HTTPMethod, body: Parameters? = nil, types: APITypes, success: ((AppState) -> Void)? = nil, failure: (() -> Void)? = nil) {
    self.endpoint = endpoint
    self.method = method
    self.types = types
    headers = ["Authorization": "Bearer \(mainStore.state.spotifyAuth.token ?? "")"]
    self.body = body
    bodyEncoding = JSONEncoding.default
    self.queryParams = queryParams
    self.success = success
    self.failure = failure
  }
}

struct CallAPI: APIAction {
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let body: Parameters?
  let bodyEncoding: ParameterEncoding
  let types: APITypes
  let url: String
  let success: ((AppState) -> Void)?
  let failure: (() -> Void)?
}

protocol APIAction: Action {
  var method: HTTPMethod { get }
  var headers: HTTPHeaders? { get }
  var body: Parameters? { get }
  var bodyEncoding: ParameterEncoding { get }
  var types: APITypes { get }
  var url: String { get }
  var success: ((AppState) -> Void)? { get }
  var failure: (() -> Void)? { get }
}

typealias QueryParams = [String: String]

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
