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

class SearchViewController: UIViewController, UISearchBarDelegate, StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  
  @IBOutlet var noResultsView: UIView!
  @IBOutlet var noResultsLabel: UILabel!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var searchResultsTableView: UITableView!
  
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
  }
}
