//
//  InspectAllViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/8/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import ReSwift

class InspectAllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
  enum CollectionType {
    case savedTracks
    case playlistableSavedTracks
  }
  
  typealias StoreSubscriberStateType = AppState
  
  @IBOutlet var noItemsView: UIView!
  @IBOutlet var noItemsLabel: UILabel!
  @IBOutlet var populatedItemsView: UIView!
  @IBOutlet var inspectAllTableView: UITableView!
  
  var items = [Item]()
  var seeds: SeedsState?
  
  var type: CollectionType?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    inspectAllTableView.dataSource = self
    inspectAllTableView.delegate = self
    
    inspectAllTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "inspectAllCell"
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
    inspectAllTableView.reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }
  
  func newState(state: AppState) {
    seeds = state.seeds
    
    switch type {
    case .some(.savedTracks):
      setupForSavedTracks(state: state)
    case .some(.playlistableSavedTracks):
      setupForPlaylistableSavedTracks(state: state)
    default:
      break
    }
    
    if seeds?.isFull == true {
      presentAlertView(
        title: "Limit Reached",
        message: "Would you like to generate a playlist off of these?",
        successActionTitle: "Ok",
        failureActionTitle: "Cancel",
        success: {
          guard let seeds = self.seeds else { return }
          
          self.tabBarController?.selectedIndex = 0
          mainStore.dispatch(generatePlaylist(fromSeeds: seeds))
      },
        failure: {}
      )
    }
  }
  
  private func setupForSavedTracks(state: AppState) {
    let library = state.myLibrary
    
    if library.isRequestingSavedTracks {
      SVProgressHUD.show()
    } else {
      SVProgressHUD.dismiss()
    }
    
    if library.mySavedTrackIDs.isEmpty && !library.isRequestingSavedTracks {
      mainStore.dispatch(getSavedTracks())
    }
    
    if !library.mySavedTrackIDs.isEmpty {
      items = state.resources.tracksFor(ids: state.myLibrary.mySavedTrackIDs)
      inspectAllTableView.reloadData()
    }
    
    noItemsLabel.text = "Your saved tracks will appear here."
    shouldDisplayNoItemsView(library.mySavedTrackIDs.isEmpty)
  }
  
  private func setupForPlaylistableSavedTracks(state: AppState) {
    let library = state.myLibrary
    noItemsLabel.text = "Playlistable saved tracks will appear here."
    shouldDisplayNoItemsView(library.playlistableSavedTrackIDs.isEmpty)
    
    guard let playlistID = library.playlistableSavedTracksPlaylistID else { return }
    guard let userID = state.spotifyAuth.userID else { return }
    
    if library.isRequestingPlaylistableSavedTracks {
      SVProgressHUD.show()
    } else {
      SVProgressHUD.dismiss()
    }
    
    if library.playlistableSavedTrackIDs.isEmpty && !library.isRequestingPlaylistableSavedTracks {
      mainStore.dispatch(getPlaylistableSavedTracks(userID: userID, playlistID: playlistID))
    } else {
      items = state.resources.tracksFor(ids: library.playlistableSavedTrackIDs)
      inspectAllTableView.reloadData()
    }
  }
  
  private func shouldDisplayNoItemsView(_ bool: Bool) {
    noItemsView.isHidden = !bool
    populatedItemsView.isHidden = bool
  }
  
  // MARK: UITableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "inspectAllCell") as! InspectAllTableViewCell
    
    let item = items[indexPath.row]
    
    cell.setupCellFor(item: item)
    
    cell.seededCell = seeds?.isInSeeds(item: item) == true
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    
    if seeds?.isInSeeds(item: item) == true {
      mainStore.dispatch(RemoveSeed(item: item))
    } else {
      mainStore.dispatch(AddSeed(item: item))
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return isPlayerBarHidden ? 0 : playerBarHeight
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollViewHeight = scrollView.frame.size.height
    let scrollContentSizeHeight = scrollView.contentSize.height
    let scrollOffset = scrollView.contentOffset.y
    
    if scrollOffset > (scrollContentSizeHeight - scrollViewHeight) {
      
    }
  }
}
