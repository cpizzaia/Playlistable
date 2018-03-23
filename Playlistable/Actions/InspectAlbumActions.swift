//
//  InspectAlbumActions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/14/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON

enum InspectAlbumActions {
  struct InspectAlbum: Action {
    let albumID: String
  }

  struct RequestAlbumTracks: APIRequestAction {}
  struct ReceiveAlbumTracks: APIResponseSuccessAction {
    var response: JSON
  }
  struct ErrorAlbumTracks: APIResponseFailureAction {
    var error: APIRequest.APIError
  }

  static func getAlbumTracks(album: Album) -> Action {
    return CallSpotifyAPI(
      endpoint: "/v1/albums/\(album.id)/tracks",
      queryParams: ["limit": "50"],
      method: .get,
      types: APITypes(
        requestAction: RequestAlbumTracks.self,
        successAction: ReceiveAlbumTracks.self,
        failureAction: ErrorAlbumTracks.self
      )
    )
  }
}
