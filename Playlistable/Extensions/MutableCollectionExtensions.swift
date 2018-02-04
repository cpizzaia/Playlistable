//
//  MutableCollectionExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 2/4/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
extension MutableCollection {
  /// Shuffles the contents of this collection.
  mutating func shuffle() {
    let c = count
    guard c > 1 else { return }
    
    for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
      let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
      let i = index(firstUnshuffled, offsetBy: d)
      swapAt(firstUnshuffled, i)
    }
  }
}
