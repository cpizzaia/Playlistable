//
//  URLExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

extension URL {
  
  public var queryParameters: [String: String]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
      return nil
    }
    
    var parameters = [String: String]()
    for item in queryItems {
      parameters[item.name] = item.value
    }
    
    return parameters
  }
}
