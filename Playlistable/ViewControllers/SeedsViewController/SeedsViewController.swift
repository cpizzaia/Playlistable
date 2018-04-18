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

class SeedsViewController: UIViewController, MyStoreSubscriber, UITableViewDelegate, UITableViewDataSource {

  typealias StoreSubscriberStateType = AppState

  struct Props {
    let seeds: SeedsState
    let generatedPlaylistSeeds: SeedsState?
    var currentSeeds: SeedsState? {
      if seeds.items.isEmpty == false {
        return seeds
      }

      if generatedPlaylistSeeds?.items.isEmpty == false {
        return generatedPlaylistSeeds
      }

      return nil
    }
  }

  @IBOutlet var seedsTableView: UITableView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var generatePlaylistButton: UIButton!

  @IBAction func generatePlaylistButtonTapped(_ sender: UIButton) {
    generateFunction()
    tabBarController?.selectedIndex = 0
  }

  var props: Props?

  var generateFunction = {}

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.myDarkBlack

    seedsTableView.delegate = self
    seedsTableView.dataSource = self

    seedsTableView.isScrollEnabled = false

    seedsTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "seedsCell"
    )

    seedsTableView.separatorStyle = .none
    seedsTableView.backgroundColor = UIColor.clear

    titleLabel.font = UIFont.myFont(withSize: 17)
    titleLabel.textColor = UIColor.myWhite

    generatePlaylistButton.setTitleColor(UIColor.myWhite, for: .normal)
    generatePlaylistButton.titleLabel?.font = UIFont.myFont(withSize: 17)
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

  func mapStateToProps(state: AppState) -> SeedsViewController.Props {
    return Props(seeds: state.seeds, generatedPlaylistSeeds: state.generatedPlaylist.seedsUsed)
  }

  func didReceiveNewProps(props: Props) {
    generateFunction = {
      mainStore.dispatch(GeneratePlaylistActions.generatePlaylist(fromSeeds: props.seeds))
    }

    generatePlaylistButton.isHidden = props.seeds.items.isEmpty

    setTitleLabel()

    seedsTableView.reloadData()
  }

  private func setTitleLabel() {
    titleLabel.text = "You have selected the following items"

    if props?.seeds.items.isEmpty == true {

      if props?.generatedPlaylistSeeds?.items.isEmpty == false {
        titleLabel.text = "Generated a playlist using these items"
      } else {
        titleLabel.text = "Your selected items will appear here"
      }

    }
  }

  // MARK: UITableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return props?.currentSeeds?.items.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "seedsCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    guard let items = props?.currentSeeds?.items.values else { return cell }

    let item = Array(items)[indexPath.row]

    if props?.seeds.items.isEmpty == true {
      cell.setupCellWithImage(forItem: item, action: nil)
    } else {
      cell.setupCellWithImage(forItem: item, actionSymbol: "x", action: {
        mainStore.dispatch(SeedsActions.RemoveSeed(item: item))
      })
    }

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

}
