//
//  StringExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/9/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

extension String {
  var withoutSpotifyBaseURL: String {
    get {
      return replacingOccurrences(of: "https://api.spotify.com", with: "")
    }
  }
}
