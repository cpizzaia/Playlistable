//
//  ImageFactory.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ImageFactory {
  static func createImages(fromJSONArray jsonArray: [JSON]) -> [Image] {
    return jsonArray.flatMap({ createImage(fromJSON: $0) })
  }
  
  static func createImage(fromJSON json: JSON) -> Image? {
    guard
      let height = json["height"].int,
      let width = json["width"].int,
      let urlString = json["url"].string,
      let url = URL(string: urlString) else {
        return nil
    }
    
    return Image(height: height, width: width, url: url)
  }
}
