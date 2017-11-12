//
//  GeneratedPlaylistViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class GeneratedPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  @IBOutlet var noPlaylistView: UIView!
  @IBOutlet var playlistView: UIView!
  @IBOutlet var playButton: UIButton!
  @IBOutlet var playlistTableView: UITableView!
  
  
  @IBAction func playButtonTapped(_ sender: UIButton) {
  }
  
  var tracks = [Track]()
  var noTracks: Bool {
    get {
      return tracks.isEmpty
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    playlistTableView.delegate = self
    playlistTableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mainStore.subscribe(self)
    
    tabBarController?.title = "Generated Playlist"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  
  func newState(state: AppState) {
    tracks = []
    
    noPlaylistView.isHidden = !noTracks
    playlistView.isHidden = noTracks
  }
  
  // MARK: Table View Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}
