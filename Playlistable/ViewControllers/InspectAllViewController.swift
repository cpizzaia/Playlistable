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
  }
  
  typealias StoreSubscriberStateType = AppState
  
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
    default:
      break
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
}
