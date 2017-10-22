//
//  SpotifyRequest.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation

class SpotifyRequest {
  //MARK: Public Typealiases
  typealias TracksResponse = ([Track]) -> ()
  typealias AlbumsResponse = ([Album]) -> ()
  typealias ArtistsResponse = ([Artist]) -> ()
  
  //MARK: Public Static Properties
  static let shared = SpotifyRequest()
  
  //MARK: Private Instance Properties
  private let request: APIRequest
  private let baseURL = "https://api.spotify.com/v1"
  private var defaultHeaders: [String: String] {
    get {
      return [:]
    }
  }
  private let translator = SpotifyTranslator.self
  
  //MARK: Public Instance Methods
  func getMySavedTracks(success: @escaping TracksResponse, failure: @escaping APIRequest.FailureResponse) {
    request.get(
      url: completeURL(withEndpoint: "/me/tracks"),
      headers: defaultHeaders,
      success: translator.translateToSuccessResponse(response: success),
      failure: failure
    )
  }
  
  //MARK: Private Instance Methods
  private init(request: APIRequest = APIRequest()) {
    self.request = request
  }
  
  private func completeURL(withEndpoint endpoint: String) -> String {
    return baseURL + endpoint
  }
}
