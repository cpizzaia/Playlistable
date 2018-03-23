//
//  DictionaryExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/5/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

extension Dictionary {
  func union(_ dictionary: Dictionary) -> Dictionary {
    var result = Dictionary()
    self.forEach({ (key, value) in result[key] = value })
    dictionary.forEach({ (key, value) in result[key] = value })

    return result
  }
}
