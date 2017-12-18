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
import SVProgressHUD

class GeneratedPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  @IBOutlet var noPlaylistView: UIView!
  @IBOutlet var playlistView: UIView!
  @IBOutlet var playButton: UIButton!
  @IBOutlet var playlistTableView: UITableView!
  
  
  @IBAction func playButtonTapped(_ sender: UIButton) {
    guard let track = tracks.first else { return }
    
    mainStore.dispatch(playTrack(id: track.id))
    
    mainStore.dispatch(playQueue(
      trackIDs: tracks.map { $0.id },
      startingWithTrackID: track.id
    ))
  }
  
  var tracks = [Track]()
  var currentlyPlayingTrack: Track?
  var noTracks: Bool {
    get {
      return tracks.isEmpty
    }
  }
  
  var userID: String?
  var savedTracksPlaylistID: String?
  var savedTrackIDs = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    playlistTableView.delegate = self
    playlistTableView.dataSource = self
    playlistTableView.delaysContentTouches = false
    
    playlistTableView.register(
      UINib(nibName: "GeneratedPlaylistTrackTableViewCell", bundle: nil),
      forCellReuseIdentifier: "generatedTrackCell"
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mainStore.subscribe(self)
    
    navigationItem.title = "Generated Playlist"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  
  func newState(state: AppState) {
    tracks = state.resources.tracksFor(ids: state.generatedPlaylist.trackIDs)
    
    if let playingTrackID = state.spotifyPlayer.playingTrackID {
      currentlyPlayingTrack = state.resources.tracks[playingTrackID]
    } else {
      currentlyPlayingTrack = nil
    }
    
    
    noPlaylistView.isHidden = !noTracks
    playlistView.isHidden = noTracks
    
    if state.generatedPlaylist.isGenerating {
      noPlaylistView.isHidden = true
      playlistView.isHidden = true
      SVProgressHUD.show()
    } else {
      SVProgressHUD.dismiss()
    }
    
    userID = state.spotifyAuth.userID
    savedTracksPlaylistID = state.playlistableSavedTracks.playlistID
    savedTrackIDs = state.playlistableSavedTracks.trackIDs
    
    playlistTableView.reloadData()
  }
  
  // MARK: Table View Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "generatedTrackCell") as! GeneratedPlaylistTrackTableViewCell
    
    let track = tracks[indexPath.row]
    
    let isSavedTrack = savedTrackIDs.contains(track.id)
    
    cell.setupCell(forTrack: track, actionType: isSavedTrack ? .remove : .add, action: {
      guard let userID = self.userID else { return }
      
      if isSavedTrack {
        guard let playlistID = self.savedTracksPlaylistID else { return }
        mainStore.dispatch(UnSaveFromPlaylistableTracks(
          trackID: track.id,
          userID: userID,
          playlistID: playlistID)
        )
      } else {
        mainStore.dispatch(saveToAndCreatePlaylistableSavedTracksIfNeeded(
          trackID: track.id,
          userID: userID,
          playlistID: self.savedTracksPlaylistID
        ))
      }
      
      
    })
    
    cell.currentlyPlaying = track.id == currentlyPlayingTrack?.id
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    mainStore.dispatch(playQueue(trackIDs: tracks.map { $0.id }, startingWithTrackID: tracks[indexPath.row].id))
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForFooterWithPlayerBar
  }
}
