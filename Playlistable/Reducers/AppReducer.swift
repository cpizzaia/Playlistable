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
  var seeds: SeedsState
  var generatedPlaylist: GeneratedPlaylistState
}

func appReducer(action: Action, state: AppState?) -> AppState {
  return AppState(
    spotifyAuth: spotifyAuthReducer(action: action, state: state?.spotifyAuth),
    resources: resourceReducer(action: action, state: state?.resources),
    myLibrary: myLibraryReducer(action: action, state: state?.myLibrary),
    seeds: seedsReducer(action: action, state: state?.seeds),
    generatedPlaylist: generatedPlaylistReducer(action: action, state: state?.generatedPlaylist)
  )
}
