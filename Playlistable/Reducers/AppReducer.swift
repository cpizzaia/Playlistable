//
//  AppReducer
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

struct AppState: StateType {
  var spotifyAuth: SpotifyAuthState
  var resources: ResourceState
  var myLibrary: LibraryState
  var savedTracks: SavedTracksState
  var seeds: SeedsState
  var generatedPlaylist: GeneratedPlaylistState
  var spotifyPlayer: SpotifyPlayerState
}

func appReducer(action: Action, state: AppState?) -> AppState {
  return AppState(
    spotifyAuth: spotifyAuthReducer(action: action, state: state?.spotifyAuth),
    resources: resourceReducer(action: action, state: state?.resources),
    myLibrary: myLibraryReducer(action: action, state: state?.myLibrary),
    savedTracks: savedTracksReducer(action: action, state: state?.savedTracks),
    seeds: seedsReducer(action: action, state: state?.seeds),
    generatedPlaylist: generatedPlaylistReducer(action: action, state: state?.generatedPlaylist),
    spotifyPlayer: spotifyPlayerReducer(action: action, state: state?.spotifyPlayer)
  )
}
