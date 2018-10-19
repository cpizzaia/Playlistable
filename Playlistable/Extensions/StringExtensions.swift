//
//  StringExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/9/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

extension String {
  var withoutSpotifyBaseURL: String {
    return replacingOccurrences(of: "https://api.spotify.com", with: "")
  }

  func attributedStringForPartiallyColoredText(_ textToFind: String, with color: UIColor) -> NSMutableAttributedString {
    let mutableAttributedstring = NSMutableAttributedString(string: self)
    let range = mutableAttributedstring.mutableString.range(of: textToFind, options: .caseInsensitive)
    if range.location != NSNotFound {
      mutableAttributedstring.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    return mutableAttributedstring
  }
}
