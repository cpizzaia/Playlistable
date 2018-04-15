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
  struct RequestTracksFromSeeds: APIRequestAction {}
  struct ReceiveTracksFromSeeds: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorTracksFromSeeds: APIResponseFailureAction {
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

  struct RequestCreatePlaylist: APIRequestAction {}
  struct ReceiveCreatePlaylist: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorCreatePlaylist: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct RequestAddTracksToPlaylist: APIRequestAction {}
  struct ReceiveAddTracksToPlaylist: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorAddTracksToPlaylist: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct RequestUnfollowPlaylist: APIRequestAction {}
  struct ReceiveUnfollowPlaylist: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorUnfollowPlaylist: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  struct GeneratingPlaylist: Action {}
  struct GeneratedPlaylist: Action {}

  struct RequestStoredPlaylist: APIRequestAction {}
  struct ReceiveStoredPlaylist: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorStoredPlaylist: APIResponseFailureAction {
    let error: APIRequest.APIError
  }

  static func generateTracks(fromSeeds seeds: SeedsState, success: @escaping (AppState) -> Void, failure: @escaping () -> Void) -> Action {
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

    return WrapInDispatch { dispatch, _ in
      dispatch(CallSpotifyAPI(
        endpoint: "/v1/recommendations",
        queryParams: queryParams,
        method: .get,
        types: APITypes(
          requestAction: RequestTracksFromSeeds.self,
          successAction: ReceiveTracksFromSeeds.self,
          failureAction: ErrorTracksFromSeeds.self
        ),
        success: success,
        failure: failure
      ))
    }
  }

  static func generatePlaylist(fromSeeds seedsState: SeedsState) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(GeneratingPlaylist())

      dispatch(generateTracks(fromSeeds: seedsState, success: { state in
        guard let userID = state.spotifyAuth.userID else { return }

        dispatch(createGeneratedPlaylist(userID: userID, success: { state in
          guard let playlistID = state.generatedPlaylist.playlistID else { return }

          dispatch(unfollowPlaylist(playlistID: playlistID, playlistOwnerID: userID))

          dispatch(
            addTracksToPlaylist(
              trackIDs: state.generatedPlaylist.trackIDsGeneratedFromSeeds,
              userID: userID,
              playlistID: playlistID,
              success: { _ in
                dispatch(SeedsActions.GeneratedFromSeeds(seeds: seedsState))
                dispatch(GeneratedPlaylist())
            },
              failure: {}
            )
          )
        }, failure: {}))
      }, failure: {}))
    }
  }

  static func reloadPlaylistFromStorage(userID: String) -> Action? {
    guard
      let playlistID = UserDefaults.standard.storedGeneratedPlaylistID,
      let seedTrackIDs = UserDefaults.standard.storedTrackSeedIDs,
      let seedArtistIDs = UserDefaults.standard.storedArtistSeedIDs
      else { return nil }

    return WrapInDispatch { dispatch, _ in

      var seedItems = [String: Item]()
      let group = DispatchGroup()

      dispatch(getStoredPlaylist(playlistID: playlistID, playlistOwnerID: userID))

      if !seedTrackIDs.isEmpty {
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
      }

      if !seedArtistIDs.isEmpty {
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
      }

      group.notify(queue: .main) {
        dispatch(ReceiveStoredSeedsState(seeds: SeedsState(items: seedItems)))
      }
    }
  }

  static func createGeneratedPlaylist(userID: String, success: @escaping (AppState) -> Void, failure: @escaping () -> Void) -> Action {
    return CallSpotifyAPI(
      endpoint: "/v1/users/\(userID)/playlists",
      method: .post,
      body: ["name": "Playlistable"],
      types: APITypes(
        requestAction: RequestCreatePlaylist.self,
        successAction: ReceiveCreatePlaylist.self,
        failureAction: ErrorCreatePlaylist.self
      ),
      success: success,
      failure: failure
    )
  }

  static func addTracksToPlaylist(trackIDs: [String], userID: String, playlistID: String, success: @escaping (AppState) -> Void, failure: @escaping () -> Void) -> Action {
    return WrapInDispatch { dispatch, getState in
      dispatch(CallSpotifyAPI(
        endpoint: "/v1/users/\(userID)/playlists/\(playlistID)/tracks",
        method: .post,
        body: ["uris": trackIDs.map(trackURI)],
        types: APITypes(
          requestAction: RequestAddTracksToPlaylist.self,
          successAction: ReceiveAddTracksToPlaylist.self,
          failureAction: ErrorAddTracksToPlaylist.self
        ),
        success: { newState in
          guard let playlist = newState.resources.playlistFor(id: playlistID) else { return }

          dispatch(ResourceActions.UpdatePlaylist(
            playlist: Playlist(
              trackIDs: playlist.trackIDs + trackIDs,
              name: playlist.name,
              id: playlist.id,
              images: playlist.images
            )
          ))
          guard let state = getState() else { return }
          success(state)
      },
        failure: failure
      ))
    }
  }

  static func unfollowPlaylist(playlistID: String, playlistOwnerID: String) -> Action {
    return CallSpotifyAPI(
      endpoint: "/v1/users/\(playlistOwnerID)/playlists/\(playlistID)/followers",
      method: .delete,
      types: APITypes(
        requestAction: RequestUnfollowPlaylist.self,
        successAction: ReceiveUnfollowPlaylist.self,
        failureAction: ErrorUnfollowPlaylist.self
      )
    )
  }

  static func getStoredPlaylist(playlistID: String, playlistOwnerID: String) -> Action {
    return CallSpotifyAPI(
      endpoint: "/v1/users/\(playlistOwnerID)/playlists/\(playlistID)",
      method: .get,
      types: APITypes(
        requestAction: RequestStoredPlaylist.self,
        successAction: ReceiveStoredPlaylist.self,
        failureAction: ErrorStoredPlaylist.self
      )
    )
  }
}

private func getIDs<T: Item>(forType type: T.Type, fromSeeds seeds: SeedsState) -> [String] {
  return seeds.items.compactMap { _, value in
    return (value as? T)?.id
  }
}
