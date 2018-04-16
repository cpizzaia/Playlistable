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

  struct RequestCreateGeneratedPlaylist: APIRequestAction {}
  struct ReceiveCreateGeneratedPlaylist: APIResponseSuccessAction {
    let response: JSON
  }
  struct ErrorCreateGeneratedPlaylist: APIResponseFailureAction {
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

  static func generateTracks(fromSeeds seeds: SeedsState, success: @escaping (JSON) -> Void, failure: @escaping () -> Void) -> Action {
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
    return WrapInDispatch { dispatch, getState in
      dispatch(GeneratingPlaylist())

      dispatch(generateTracks(fromSeeds: seedsState, success: { _ in
        guard let userID = getState()?.spotifyAuth.userID else { return }

        dispatch(createGeneratedPlaylist(userID: userID, success: { _ in
          guard let playlistID = getState()?.generatedPlaylist.playlistID else { return }

          dispatch(unfollowPlaylist(playlistID: playlistID, playlistOwnerID: userID))

          dispatch(
            addTracksToPlaylist(
              trackIDs: getState()?.generatedPlaylist.trackIDsGeneratedFromSeeds ?? [],
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

    return WrapInDispatch { dispatch, getState in

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
            success: { _ in
              guard let state = getState() else { return }

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
            success: { _ in
              getState()?.resources.artistsFor(ids: seedArtistIDs).forEach { artist in
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

  static func createGeneratedPlaylist(userID: String, success: @escaping (JSON) -> Void, failure: @escaping () -> Void) -> Action {
    return createPlaylist(
      userID: userID,
      name: "Playlistable",
      types: APITypes(
        requestAction: RequestCreateGeneratedPlaylist.self,
        successAction: ReceiveCreateGeneratedPlaylist.self,
        failureAction: ErrorCreateGeneratedPlaylist.self
      ),
      success: success,
      failure: failure
    )
  }

  static func createSavedPlaylist(userID: String, name: String, trackIDs: [String], success: @escaping () -> Void, failure: @escaping () -> Void) -> Action {
    return WrapInDispatch { dispatch, _ in
      dispatch(createPlaylist(
        userID: userID,
        name: name,
        types: nil,
        success: { json in
          guard let playlistID = json["id"].string else { return }

          dispatch(addTracksToPlaylist(trackIDs: trackIDs, userID: userID, playlistID: playlistID, success: { _ in
            success()
          }, failure: failure))
        },
        failure: failure
      ))
    }
  }

  private static func createPlaylist(userID: String, name: String, types: APITypes?, success: @escaping (JSON) -> Void, failure: @escaping () -> Void) -> Action {
    return CallSpotifyAPI(
      endpoint: "/v1/users/\(userID)/playlists",
      method: .post,
      body: ["name": name],
      types: types,
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
        success: { _ in
          guard let playlist = getState()?.resources.playlistFor(id: playlistID) else { return }

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
