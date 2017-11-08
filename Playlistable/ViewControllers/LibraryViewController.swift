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

class LibraryViewController: UIViewController, StoreSubscriber, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var libraryTableView: UITableView!
  
  typealias StoreSubscriberStateType = AppState
  
  var savedTracks = [Track]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    libraryTableView.register(
      UINib(nibName: "LibraryTableViewCell", bundle: nil),
      forCellReuseIdentifier: "libraryCell"
    )
    
    libraryTableView.dataSource = self
    libraryTableView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.title = "Library"
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
    
    libraryTableView.reloadData()
    
    if isAuthed && savedTracks.isEmpty && !isRequestingSavedTracks {
      mainStore.dispatch(getSavedTracks())
    }
  }
  
  // MARK: Table View Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = libraryTableView.dequeueReusableCell(withIdentifier: "libraryCell") as! LibraryTableViewCell
    
    cell.setupCellWith(title: "Saved Tracks")
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
