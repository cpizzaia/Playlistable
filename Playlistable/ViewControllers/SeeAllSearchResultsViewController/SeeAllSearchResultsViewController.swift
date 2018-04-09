//
//  SeeAllSearchResultsViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 12/17/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SeeAllSearchResultsViewController: UIViewController, StoreSubscriber, UITableViewDelegate, UITableViewDataSource {
  typealias StoreSubscriberStateType = AppState

  @IBOutlet var resultsTableView: UITableView!

  enum ControllerType {
    case artists
    case tracks
    case albums
  }

  // MARK: Public Properties
  var type: ControllerType?

  // MARK: Private Properties
  private var items = [Item]()
  private var seeds: SeedsState?

  override func viewDidLoad() {
    super.viewDidLoad()

    resultsTableView.delegate = self
    resultsTableView.dataSource = self
    resultsTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "searchResultCell"
    )

    resultsTableView.backgroundColor = UIColor.clear
    resultsTableView.separatorStyle = .none

    view.backgroundColor = UIColor.myDarkBlack
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)

    navigationController?.navigationBar.isHidden = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }

  func newState(state: AppState) {
    seeds = state.seeds

    switch type {
    case .some(.artists):
      items = state.resources.artistsFor(ids: state.search.artistIDs)
    case .some(.tracks):
      items = state.resources.tracksFor(ids: state.search.trackIDs)
    case .some(.albums):
      items = state.resources.albumsFor(ids: state.search.albumIDs)
    default:
      break
    }

    resultsTableView.reloadData()
  }

  // MARK: UITableViewMethods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    let item = items[indexPath.row]

    cell.seededCell = seeds?.isInSeeds(item: item) == true

    if let album  = item as? Album {
      cell.setupCellWithImage(forItem: item, action: {
        mainStore.dispatch(InspectAlbumActions.InspectAlbum(albumID: album.id))

        let vc = loadUIViewControllerFromNib(ItemWithTrackListViewController.self)

        vc.itemType = .album

        self.navigationController?.pushViewController(vc, animated: true)
      })
    } else {
      cell.setupCellWithImage(forItem: item, action: nil)
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]

    if seeds?.isInSeeds(item: item) == true {
      mainStore.dispatch(SeedsActions.RemoveSeed(item: item))
    } else {
      if seeds?.isFull == true {
        presentSeedsFullAlert()
        return
      }

      mainStore.dispatch(SeedsActions.AddSeed(item: item))
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView()

    view.backgroundColor = UIColor.myDarkBlack

    return view
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForFooterWithPlayerBar
  }
}
