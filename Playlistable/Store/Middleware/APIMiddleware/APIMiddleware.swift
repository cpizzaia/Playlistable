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

      if
        let spotifyAPIAction = apiAction as? CallSpotifyAPI,
        let batchedQueryParams = spotifyAPIAction.batchedQueryParams,
        let batchedJSONKey = spotifyAPIAction.batchedJSONKey {

        // FIXME: There's a smarter cleaner way to make batched requests
        // I just can't think of it right now
        makeBatchApiRequest(
          apiAction: spotifyAPIAction,
          batchedQueryParams: batchedQueryParams,
          batchedJSONKey: batchedJSONKey,
          next: next,
          getState: getState
        )

        return
      }

      makeAPIRequest(apiAction: apiAction, next: next, getState: getState)
    }
  }
}

private func translateToRequestParams(apiAction: APIAction, next: @escaping DispatchFunction, getState: @escaping () -> AppState?, success: @escaping (JSON) -> Void, failure: @escaping (APIRequest.APIError) -> Void) -> APIRequest.RequestParams {
  return APIRequest.RequestParams(
    url: apiAction.url,
    method: apiAction.method,
    body: apiAction.body,
    headers: apiAction.headers,
    encoding: apiAction.bodyEncoding,
    success: { data in
      parseResources(fromJSON: data, next: next)
      success(data)
    },
    failure: { error in
      failure(error)
    }
  )
}

private func makeAPIRequest(apiAction: APIAction, next: @escaping DispatchFunction, getState: @escaping () -> AppState?) {
  APIRequest.shared.request(
    params: translateToRequestParams(
      apiAction: apiAction,
      next: next,
      getState: getState,
      success: { data in
        next(apiAction.types.successAction.init(response: data))
        guard let state = getState() else { return }
        apiAction.success?(state)
      }, failure: { error in
        next(apiAction.types.failureAction.init(error: error))
        apiAction.failure?()
      }
    )
  )
}

private func makeBatchApiRequest(apiAction: CallSpotifyAPI, batchedQueryParams: [QueryParams], batchedJSONKey: String, next: @escaping DispatchFunction, getState: @escaping () -> AppState?) {
  let group = DispatchGroup()

  var combinedJSON = [JSON]()

  batchedQueryParams.forEach { queryParams in
    let newAPIAction = CallSpotifyAPI(
      endpoint: apiAction.endpoint,
      queryParams: queryParams,
      method: apiAction.method,
      body: apiAction.body,
      types: apiAction.types,
      success: apiAction.success,
      failure: apiAction.failure
    )

    group.enter()

    APIRequest.shared.request(params:
      translateToRequestParams(
        apiAction: newAPIAction,
        next: next,
        getState: getState,
        success: { json in

          combinedJSON += json[batchedJSONKey].array ?? []

          group.leave()
        },
        failure: { _ in
          group.leave()
        }
      )
    )
  }

  group.notify(queue: .main) {
    next(apiAction.types.successAction.init(response: JSON([batchedJSONKey: combinedJSON])))
    guard let state = getState() else { return }
    apiAction.success?(state)
  }
}

struct CallSpotifyAPI: APIAction {
  let endpoint: String
  let method: HTTPMethod
  let headers: HTTPHeaders?
  let body: Parameters?
  let queryParams: QueryParams?
  let batchedQueryParams: [QueryParams]? // Only used in batch requests
  let batchedJSONKey: String? // Only used in batch requests
  let bodyEncoding: ParameterEncoding
  let types: APITypes
  let success: ((AppState) -> Void)?
  let failure: (() -> Void)?
  var url: String {
    return "https://api.spotify.com" + endpoint + queryString
  }
  private var queryString: String {
    return queryParams?.reduce("?", { result, keyValue in
      if result == "?" {
        return (result ?? "") + "\(keyValue.key)=\(keyValue.value)"
      } else {
        return (result ?? "") + "&\(keyValue.key)=\(keyValue.value)"
      }
    }) ?? ""
  }

  init(endpoint: String, queryParams: QueryParams? = nil, batchedQueryParams: [QueryParams]? = nil, batchedJSONKey: String? = nil, method: HTTPMethod, body: Parameters? = nil, types: APITypes, success: ((AppState) -> Void)? = nil, failure: (() -> Void)? = nil) {
    self.endpoint = endpoint
    self.method = method
    self.types = types
    headers = ["Authorization": "Bearer \(mainStore.state.spotifyAuth.token ?? "")"]
    self.body = body
    bodyEncoding = JSONEncoding.default
    self.queryParams = queryParams
    self.batchedQueryParams = batchedQueryParams
    self.batchedJSONKey = batchedJSONKey
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
