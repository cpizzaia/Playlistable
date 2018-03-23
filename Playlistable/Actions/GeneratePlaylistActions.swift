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

enum GeneratePlaylistActions {
  struct RequestGeneratePlaylist: APIRequestAction {}
  
  struct ReceiveGeneratePlaylist: APIResponseSuccessAction {
    let response: JSON
  }
  
  struct ErrorGeneratePlaylist: APIResponseFailureAction {
    let error: APIRequest.APIError
  }
  
  static func generatePlaylist(fromSeeds seeds: SeedsState) -> Action {
    let trackIDs = getIDs(forType: Track.self, fromSeeds: seeds)
    let artistIDs = getIDs(forType: Artist.self, fromSeeds: seeds)
    let albumIDs = getIDs(forType: Album.self, fromSeeds: seeds)
    
    var queryParams = [
      "limit": "100",
      "market": "US"
    ]
    
    if !trackIDs.isEmpty {
      queryParams = queryParams.union(["seed_tracks": trackIDs.joined(separator: ",")])
    }
    
    if !artistIDs.isEmpty {
      queryParams = queryParams.union(["seed_artists": artistIDs.joined(separator: ",")])
    }
    
    if !albumIDs.isEmpty {
      queryParams = queryParams.union(["seed_albums": albumIDs.joined(separator: ",")])
    }
    
    return WrapInDispatch { dispatch in
      dispatch(CallSpotifyAPI(
        endpoint: "/v1/recommendations",
        queryParams: queryParams,
        method: .get,
        types: APITypes(
          requestAction: RequestGeneratePlaylist.self,
          successAction: ReceiveGeneratePlaylist.self,
          failureAction: ErrorGeneratePlaylist.self
        ),
        success: { json in
          dispatch(SeedsActions.GeneratedFromSeeds(seeds: seeds))
      },
        failure: {}
      ))
    }
    
  }
}

fileprivate func getIDs<T: Item>(forType type: T.Type, fromSeeds seeds: SeedsState) -> [String] {
  return seeds.items.flatMap { key, value in
    return (value as? T)?.id
  }
}
