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
  
  struct APIError: Error {
    let code: Int
    let domainCode: Int?
    let description: String
  }
  
  struct Response {
    let statusCode: Int
    let headers: Headers
    let body: Body
  }
  
  typealias Headers = JSON
  typealias Body = JSON
  
  struct RequestParams {
    let url: String
    let method: HTTPMethod
    let body: Parameters?
    let headers: HTTPHeaders?
    let success: DataCompletion
    let failure: ErrorCompletion
    
    func mergeWithHeaders(_ dictionary: HTTPHeaders) -> RequestParams {
      return RequestParams(
        url: url,
        method: method,
        body: body,
        headers: headers ?? [:],
        success: success,
        failure: failure
      )
    }
  }
  
  typealias DataCompletion = (JSON) -> ()
  typealias ErrorCompletion = (APIError) -> ()
  
  func get(url: String, headers: HTTPHeaders?, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
    
    request(params: RequestParams(url: url, method: .get, body: nil, headers: headers, success: success, failure: failure))
    
  }
  
  func post(url: String, body: Parameters?, headers: HTTPHeaders?, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
    
    request(params: RequestParams(url: url, method: .post, body: body, headers: headers, success: success, failure: failure))
    
  }
  
  func delete(url: String, body: Parameters?, headers: HTTPHeaders?, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
    
    request(params: RequestParams(url: url, method: .delete, body: body, headers: headers, success: success, failure: failure))
    
  }
  
  func patch(url: String, body: Parameters?, headers: HTTPHeaders?, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
    
    request(params: RequestParams(url: url, method: .patch, body: body, headers: headers, success: success, failure: failure))
    
  }
  
  func put(url: String, body: Parameters?, headers: HTTPHeaders?, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
    
    request(params: RequestParams(url: url, method: .put, body: body, headers: headers, success: success, failure: failure))
    
  }
  
  
  private func request(params: RequestParams) {
    log("\(params.method.rawValue): \(params.url)")
    
    Alamofire.request(
      params.url,
      method: params.method,
      parameters: params.body,
      encoding: JSONEncoding.default,
      headers: params.headers
      ).validate().responseJSON(completionHandler: { response in
        self.handle(response: response, params: params)
      })
  }
  
  
  //MARK: Private Methods
  private func handle(response: DataResponse<Any>, params: RequestParams) {
    
    let apiResponse = Response(
      statusCode: response.response?.statusCode ?? 400,
      headers: JSON(response.response?.allHeaderFields ?? [:]),
      body: JSON(data: response.data ?? Data())
    )
    
    switch response.result {
    case .success:
      log("SUCCESS: \(params.url)")
      params.success(apiResponse.body)
      
    case .failure:
      log("FAILURE: \(params.url)")
      params.failure(self.errorFrom(response: apiResponse))
    }
  }
  
  private func errorFrom(response: Response) -> APIError {
    let error = response.body["error"]
    
    return APIError(
      code: response.statusCode,
      domainCode: error["code"].int ?? Int(error["code"].string ?? ""),
      description:error["detail"].string ?? error["title"].string ?? error["error"].string ?? "Something went wrong, please try again."
    )
  }
}
