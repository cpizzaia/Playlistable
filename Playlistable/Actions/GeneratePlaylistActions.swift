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

  struct RequestStoredPlaylistTracks: APIRequestAction {}

  struct ReceiveStoredPlaylistTracks: APIResponseSuccessAction {
    let response: JSON
  }

  struct ErrorStoredPlaylistTracks: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct RequestStoredSeedTracks: APIRequestAction {}

  struct ReceiveStoredSeedTracks: APIResponseSuccessAction {
    let response: JSON
  }

  struct ErrorStoredSeedTracks: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct RequestStoredSeedArtists: APIRequestAction {}

  struct ReceiveStoredSeedArtists: APIResponseSuccessAction {
    let response: JSON
  }

  struct ErrorStoredSeedArtists: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct ReceiveStoredSeedsState: Action {
    let seeds: SeedsState
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
        success: { _ in
          dispatch(SeedsActions.GeneratedFromSeeds(seeds: seeds))
      },
        failure: {}
      ))
    }
  }

  static func reloadPlaylistFromStorage() -> Action? {
    guard
      let playlistTrackIDs = UserDefaults.standard.value(forKey: UserDefaultsKeys.storedPlaylistTrackIDs) as? [String],
      let seedTrackIDs = UserDefaults.standard.value(forKey: UserDefaultsKeys.storedTrackSeedIDs) as? [String],
      let seedArtistIDs = UserDefaults.standard.value(forKey: UserDefaultsKeys.storedArtistSeedIDs) as? [String]
      else { return nil }

    return WrapInDispatch { dispatch in

      var seedItems = [String: Item]()
      let group = DispatchGroup()

      dispatch(
        CallSpotifyAPI(
          endpoint: "/v1/tracks",
          batchedQueryParams: playlistTrackIDs.chunked(by: 50).map { ids in
            return ["ids": ids.joined(separator: ",")]
          },
          batchedJSONKey: "tracks",
          method: .get,
          types: APITypes(
            requestAction: RequestStoredPlaylistTracks.self,
            successAction: ReceiveStoredPlaylistTracks.self,
            failureAction: ErrorStoredPlaylistTracks.self
          )
        )
      )

      group.enter()
      dispatch(
        CallSpotifyAPI(
          endpoint: "/v1/tracks",
          queryParams: ["ids": seedTrackIDs.joined(separator: ",")],
          method: .get,
          types: APITypes(
            requestAction: RequestStoredSeedTracks.self,
            successAction: ReceiveStoredSeedTracks.self,
            failureAction: ErrorStoredSeedTracks.self
          ),
          success: { state in
            state.resources.tracksFor(ids: seedTrackIDs).forEach { track in
              seedItems[track.id] = track
            }

            group.leave()
          },
          failure: group.leave
        )
      )

      group.enter()
      dispatch(
        CallSpotifyAPI(
          endpoint: "/v1/artists",
          queryParams: ["ids": seedArtistIDs.joined(separator: ",")],
          method: .get,
          types: APITypes(
            requestAction: RequestStoredSeedArtists.self,
            successAction: ReceiveStoredSeedArtists.self,
            failureAction: ErrorStoredSeedArtists.self
          ),
          success: { state in
            state.resources.artistsFor(ids: seedArtistIDs).forEach { artist in
              seedItems[artist.id] = artist
            }

            group.leave()
          },
          failure: group.leave
        )
      )

      group.notify(queue: .main) {
        dispatch(ReceiveStoredSeedsState(seeds: SeedsState(items: seedItems)))
      }
    }
  }
}

private func getIDs<T: Item>(forType type: T.Type, fromSeeds seeds: SeedsState) -> [String] {
  return seeds.items.compactMap { _, value in
    return (value as? T)?.id
  }
}
