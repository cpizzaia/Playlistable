//
//  APIQueryParamsFormatter.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

struct APIQueryParamsFormatter {
  typealias QueryParams = [String: String]

  static func queryString(params: QueryParams) -> String {
    if params.count == 0 { return "" }

    let tempArray = params.map({ key, value in
      return "\(key)=\(value)"
    })

    return "?" + tempArray.joined(separator: "&")
  }
}
