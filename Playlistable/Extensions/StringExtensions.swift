//
//  StringExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

extension String {
  func toBase64() -> String {
    return Data(self.utf8).base64EncodedString()
  }
}
