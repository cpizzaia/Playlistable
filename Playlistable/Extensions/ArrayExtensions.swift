//
//  ArrayExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/9/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation

extension Array {
  func chunked(by chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
  }
}
