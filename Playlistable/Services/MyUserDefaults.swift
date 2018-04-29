//
//  MyUserDefaults.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/29/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation

struct MyUserDefaults {
  private enum UserDefaultsKey: String {
    case spotifyAuthToken
    case spotifyRefreshToken
    case spotifyTokenExpirationTimeInterval
    case storedGeneratedPlaylistID
    case storedArtistSeedIDs
    case storedTrackSeedIDs
    case hasSeenSearchTip
    case hasSeenSelectTip
  }

  static var spotifyAuthToken: String? {
    get {
      return value(forKey: .spotifyAuthToken) as? String
    } set {
      set(newValue, forKey: .spotifyAuthToken)
    }
  }

  static var spotifyRefreshToken: String? {
    get {
      return value(forKey: .spotifyRefreshToken) as? String
    } set {
      set(newValue, forKey: .spotifyRefreshToken)
    }
  }

  static var spotifyTokenExpirationTimeInterval: Double? {
    get {
      return value(forKey: .spotifyTokenExpirationTimeInterval) as? Double
    } set {
      set(newValue, forKey: .spotifyTokenExpirationTimeInterval)
    }
  }

  static var storedGeneratedPlaylistID: String? {
    get {
      return value(forKey: .storedGeneratedPlaylistID) as? String
    } set {
      set(newValue, forKey: .storedGeneratedPlaylistID)
    }
  }

  static var storedArtistSeedIDs: [String]? {
    get {
      return value(forKey: .storedArtistSeedIDs) as? [String]
    } set {
      set(newValue, forKey: .storedArtistSeedIDs)
    }
  }

  static var storedTrackSeedIDs: [String]? {
    get {
      return value(forKey: .storedTrackSeedIDs) as? [String]
    } set {
      set(newValue, forKey: .storedTrackSeedIDs)
    }
  }

  static var hasSeenSearchTip: Bool? {
    get {
      return value(forKey: .hasSeenSearchTip) as? Bool
    } set {
      set(newValue, forKey: .hasSeenSearchTip)
    }
  }

  static var hasSeenSelectTip: Bool? {
    get {
      return value(forKey: .hasSeenSelectTip) as? Bool
    } set {
      set(newValue, forKey: .hasSeenSelectTip)
    }
  }

  private static func value(forKey key: UserDefaultsKey) -> Any? {
    return UserDefaults.standard.value(forKey: key.rawValue)
  }

  private static func set(_ value: Any?, forKey key: UserDefaultsKey) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
    UserDefaults.standard.synchronize()
  }
}
