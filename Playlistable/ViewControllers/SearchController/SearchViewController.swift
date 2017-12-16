//
//  SearchController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/14/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SearchViewController: UIViewController, UISearchBarDelegate, StoreSubscriber, UITableViewDelegate, UITableViewDataSource {
  typealias StoreSubscriberStateType = AppState
  
  @IBOutlet var noResultsView: UIView!
  @IBOutlet var noResultsLabel: UILabel!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var searchResultsTableView: UITableView!
  
  var tracks = [Track]()
  var seeds: SeedsState?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
    searchResultsTableView.delegate = self
    searchResultsTableView.dataSource = self
    
    searchResultsTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "searchCell"
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.isHidden = true
    
    mainStore.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  func newState(state: AppState) {
    searchResultsTableView.isHidden = true
    noResultsView.isHidden = false
    
    seeds = state.seeds
    tracks = state.resources.tracksFor(ids: state.search.trackIDs)
    
    let noResults = tracks.isEmpty
    
    searchResultsTableView.isHidden = noResults
    noResultsView.isHidden = !noResults
    searchResultsTableView.reloadData()
  }
  
  // MARK: UITableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! InspectAllTableViewCell
    
    let track = tracks[indexPath.row]
    
    cell.setupCellFor(item: track)
    
    cell.isSelected = seeds?.isInSeeds(item: track) == true
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  // MARK: UISearchBar Methods
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else { return }
    mainStore.dispatch(search(query: query))
    
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
  }
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
