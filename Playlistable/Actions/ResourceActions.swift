//
//  ResourceActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/31/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

enum ResourceActions {
  struct ReceiveTracks: Action {
    let tracks: [Track]
  }

  struct ReceiveAlbums: Action {
    let albums: [Album]
  }

  struct ReceiveArtists: Action {
    let artists: [Artist]
  }

  struct ReceivePlaylists: Action {
    let playlists: [Playlist]
  }

  struct UpdatePlaylist: Action {
    let playlist: Playlist
  }
}
