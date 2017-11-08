//
//  LibraryViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/24/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class LibraryViewController: UIViewController, StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  
  var savedTracks = [Track]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }
  
  func newState(state: AppState) {
    let isAuthed = state.spotifyAuth.isAuthed
    let isRequestingSavedTracks = state.myLibrary.isRequestingSavedTracks
    
    savedTracks = state.resources.tracksFor(ids: state.myLibrary.mySavedTrackIDs)
    
    if isAuthed && savedTracks.isEmpty && !isRequestingSavedTracks {
      mainStore.dispatch(getSavedTracks())
    }
  }
}
