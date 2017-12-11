//
//  GeneratePlaylistActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReSwift

struct RequestGeneratePlaylist: APIRequestAction {}

struct ReceiveGeneratePlaylist: APIResponseSuccessAction {
  let response: JSON
}

struct ErrorGeneratePlaylist: APIResponseFailureAction {
  let error: APIRequest.APIError
}

func generatePlaylist(fromSeeds seeds: SeedsState) -> Action {
  let trackIDs = getIDs(forType: Track.self, fromSeeds: seeds)
  
  return WrapInDispatch { dispatch in
    dispatch(CallSpotifyAPI(
      endpoint: "/v1/recommendations",
      queryParams: [
        "seed_tracks": trackIDs.joined(separator: ","),
        "limit": "100",
        "market": "US"
      ],
      method: .get,
      types: APITypes(
        requestAction: RequestGeneratePlaylist.self,
        successAction: ReceiveGeneratePlaylist.self,
        failureAction: ErrorGeneratePlaylist.self
      ),
      success: { json in
        dispatch(GeneratedFromSeeds(seeds: seeds))
    },
      failure: {}
    ))
  }
  
}

fileprivate func getIDs<T: Item>(forType type: T.Type, fromSeeds seeds: SeedsState) -> [String] {
  return seeds.items.flatMap { key, value in
    return (value as? T)?.id
  }
}
