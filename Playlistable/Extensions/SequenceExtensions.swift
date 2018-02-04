//
//  SequenceExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 2/4/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation

extension Sequence {
  /// Returns an array with the contents of this sequence, shuffled.
  func shuffled() -> [Element] {
    var result = Array(self)
    result.shuffle()
    return result
  }
}
