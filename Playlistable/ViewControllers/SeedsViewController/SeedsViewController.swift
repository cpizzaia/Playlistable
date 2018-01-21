//
//  SeedsViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/10/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SeedsViewController: UIViewController, StoreSubscriber, UITableViewDelegate, UITableViewDataSource {
  
  typealias StoreSubscriberStateType = AppState
  
  @IBOutlet var seedsTableView: UITableView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var generatePlaylistButton: UIButton!
  
  @IBAction func generatePlaylistButtonTapped(_ sender: UIButton) {
    generateFunction()
    tabBarController?.selectedIndex = 0
  }
  
  var seeds: SeedsState?
  var generatedPlaylistSeeds: SeedsState?
  var currentSeeds: SeedsState? {
    get {
      if seeds?.items.isEmpty == false {
        return seeds
      }
      
      if generatedPlaylistSeeds?.items.isEmpty == false {
        return generatedPlaylistSeeds
      }
      
      return nil
    }
  }
  
  var generateFunction = {}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    seedsTableView.delegate = self
    seedsTableView.dataSource = self
    
    seedsTableView.isScrollEnabled = false
    
    seedsTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "seedsCell"
    )
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.title = "Selected Tracks"
    
    mainStore.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    mainStore.unsubscribe(self)
  }
  
  func newState(state: AppState) {
    seeds = state.seeds
    generatedPlaylistSeeds = state.generatedPlaylist.seedsUsed
    guard let seeds = seeds else { return }
    
    generateFunction = {
      mainStore.dispatch(generatePlaylist(fromSeeds: seeds))
    }
    
    generatePlaylistButton.isHidden = seeds.items.isEmpty
    
    setTitleLabel()
    
    seedsTableView.reloadData()
  }
  
  private func setTitleLabel() {
    titleLabel.text = "You have selected the following items"
    
    if seeds?.items.isEmpty == true {
      
      if generatedPlaylistSeeds?.items.isEmpty == false {
        titleLabel.text = "Generated a playlist using these items"
      } else {
        titleLabel.text = "Your selected items will appear here"
      }
      
    }
  }
  
  
  
  // MARK: UITableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentSeeds?.items.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "seedsCell") as! InspectAllTableViewCell
    
    guard let items = currentSeeds?.items.values else { return cell }
    
    let item = Array(items)[indexPath.row]
    
    cell.setupCellWithImage(forItem: item, action: nil)
    
    cell.isUserInteractionEnabled = false
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
}
