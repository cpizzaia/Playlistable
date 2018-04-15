//
//  UserDefaultsExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/15/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation

private struct UserDefaultsKeys {
  static let spotifyAuthToken = "spotifyAuthToken" // String
  static let spotifyRefreshToken = "spotifyRefreshToken" // String
  static let spotifyTokenExpirationTimeInterval = "spotifyTokenExpirationTimeInterval" // Double
  static let storedGeneratedPlaylistID = "storedGeneratedPlaylistID" // [String]
  static let storedArtistSeedIDs = "storedArtistSeedIDs" // [String]
  static let storedTrackSeedIDs = "storedTrackSeedIDs" // [String]
}

extension UserDefaults {
  var spotifyAuthToken: String? {
    get {
      return value(forKey: UserDefaultsKeys.spotifyAuthToken) as? String
    } set {
      set(newValue, forKey: UserDefaultsKeys.spotifyAuthToken)
      synchronize()
    }
  }

  var spotifyRefreshToken: String? {
    get {
      return value(forKey: UserDefaultsKeys.spotifyRefreshToken) as? String
    } set {
      set(newValue, forKey: UserDefaultsKeys.spotifyRefreshToken)
      synchronize()
    }
  }

  var spotifyTokenExpirationTimeInterval: Double? {
    get {
      return value(forKey: UserDefaultsKeys.spotifyTokenExpirationTimeInterval) as? Double
    } set {
      set(newValue, forKey: UserDefaultsKeys.spotifyTokenExpirationTimeInterval)
      synchronize()
    }
  }

  var storedGeneratedPlaylistID: String? {
    get {
      return value(forKey: UserDefaultsKeys.storedGeneratedPlaylistID) as? String
    } set {
      set(newValue, forKey: UserDefaultsKeys.storedGeneratedPlaylistID)
      synchronize()
    }
  }

  var storedArtistSeedIDs: [String]? {
    get {
      return value(forKey: UserDefaultsKeys.storedArtistSeedIDs) as? [String]
    } set {
      set(newValue, forKey: UserDefaultsKeys.storedArtistSeedIDs)
      synchronize()
    }
  }

  var storedTrackSeedIDs: [String]? {
    get {
      return value(forKey: UserDefaultsKeys.storedTrackSeedIDs) as? [String]
    } set {
      set(newValue, forKey: UserDefaultsKeys.storedTrackSeedIDs)
      synchronize()
    }
  }
}
