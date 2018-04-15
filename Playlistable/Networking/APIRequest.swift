//
//  APIRequest.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIRequest {
  static let shared = APIRequest()

  struct APIError: Error {
    let code: Int
    let domainCode: Int?
    let description: String
  }

  struct Response {
    let statusCode: Int
    let headers: Headers
    let body: Body

    var successful: Bool {
      return statusCode < 400
    }
  }

  typealias Headers = JSON
  typealias Body = JSON

  struct RequestParams {
    let url: String
    let method: HTTPMethod
    let body: Parameters?
    let headers: HTTPHeaders?
    let encoding: ParameterEncoding
    let success: SuccessResponse
    let failure: FailureResponse
  }

  typealias SuccessResponse = (JSON) -> Void
  typealias FailureResponse = (APIError) -> Void

 func request(params: RequestParams) {
    log("\(params.method.rawValue): \(params.url)")

    Alamofire.request(
      params.url,
      method: params.method,
      parameters: params.body,
      encoding: params.encoding,
      headers: params.headers
      ).validate().response(completionHandler: { response in
        self.handle(response: response, params: params)
      })
  }

  // MARK: Private Methods
  private func handle(response: DefaultDataResponse, params: RequestParams) {

    let apiResponse = Response(
      statusCode: response.response?.statusCode ?? 400,
      headers: JSON(response.response?.allHeaderFields ?? [:]),
      body: JSON(data: response.data ?? Data())
    )

    if !apiResponse.successful {
      log("FAILURE: \(params.url)")
      params.failure(self.errorFrom(response: apiResponse))
      return
    }

    log("SUCCESS: \(params.url)")
    params.success(apiResponse.body)
  }

  private func errorFrom(response: Response) -> APIError {
    let error = response.body["error"]

    return APIError(
      code: response.statusCode,
      domainCode: error["code"].int ?? Int(error["code"].string ?? ""),
      description: error["detail"].string ?? error["title"].string ?? error["error"].string ?? "Something went wrong, please try again."
    )
  }
}
