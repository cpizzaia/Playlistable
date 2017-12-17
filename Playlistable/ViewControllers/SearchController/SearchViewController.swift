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
  
  private struct SearchCollection {
    let artists: [Artist]
    let albums: [Album]
    let tracks: [Track]
    
    var isEmpty: Bool {
      get {
        return artists.isEmpty && albums.isEmpty && tracks.isEmpty
      }
    }
  }
  
  var seeds: SeedsState?
  
  private var searchData = SearchCollection(artists: [], albums: [], tracks: [])
  
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
    
    searchData = SearchCollection(
      artists: state.resources.artistsFor(ids: state.search.artistIDs),
      albums: state.resources.albumsFor(ids: state.search.albumIDs),
      tracks: state.resources.tracksFor(ids: state.search.trackIDs)
    )
    
    let noResults = searchData.isEmpty
    
    searchResultsTableView.isHidden = noResults
    noResultsView.isHidden = !noResults
    searchResultsTableView.reloadData()
    noResultsLabel.text = state.search.query == nil ? "Your search results will appear here" : "Your search had no results"
  }
  
  private func getResourceFor(section: Int) -> [Item]? {
    switch section {
    case 0:
      return searchData.tracks
    case 1:
      return searchData.albums
    case 2:
      return searchData.artists
    default:
      return nil
    }
  }
  
  private func numberOfRowsCapped(items: [Item]) -> Int {
    return items.count > 3 ? 3 : items.count
  }
  
  // MARK: UITableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let items = getResourceFor(section: section) else { return 0 }
    
    return numberOfRowsCapped(items: items)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    var count = 0
    
    if !searchData.tracks.isEmpty { count += 1 }
    if !searchData.albums.isEmpty { count += 1 }
    if !searchData.artists.isEmpty { count += 1 }
    
    return count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! InspectAllTableViewCell
    
    guard let items = getResourceFor(section: indexPath.section) else {
      return UITableViewCell()
    }
    
    let item = items[indexPath.row]
    
    cell.setupCellFor(item: item)
    
    cell.seededCell = seeds?.isInSeeds(item: item) == true
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let items = getResourceFor(section: section) else {
      return nil
    }
    
    let view = loadUIViewFromNib(SearchResultSectionHeaderView.self)
    
    view.actionButton.setTitle("See All", for: .normal)
    
    switch items.first {
    case _ as Artist:
      view.titleLabel.text = "Artists"
    case _ as Track:
      view.titleLabel.text = "Tracks"
    case _ as Album:
      view.titleLabel.text = "Albums"
    default:
      break
    }
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let items = getResourceFor(section: indexPath.section) else { return }
    
    let item = items[indexPath.row]
    
    if seeds?.isInSeeds(item: item) == true {
      mainStore.dispatch(RemoveSeed(item: item))
    } else {
      mainStore.dispatch(AddSeed(item: item))
    }
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
