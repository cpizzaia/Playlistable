//
//  ItemWithTrackListViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/14/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class ItemWithTrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
  typealias StoreSubscriberStateType = AppState

  enum ItemType {
    case album
  }

  @IBOutlet var trackListTableView: UITableView!

  var item: Item?
  var itemType: ItemType?
  var tracks = [Track]()
  var seeds: SeedsState?

  override func viewDidLoad() {
    super.viewDidLoad()

    trackListTableView.separatorStyle = .none
    trackListTableView.showsVerticalScrollIndicator = false
    trackListTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "trackListCell"
    )

    trackListTableView.delegate = self
    trackListTableView.dataSource = self
    trackListTableView.backgroundColor = UIColor.clear

    view.backgroundColor = UIColor.myDarkBlack
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.navigationBar.isHidden = false

    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }

  func newState(state: AppState) {
    seeds = state.seeds

    switch itemType {
    case .some(.album):
      newStateForAlbum(state: state)
    default:
      tracks = []
      item = nil
    }

    title = item?.title

    trackListTableView.reloadData()
  }

  func newStateForAlbum(state: AppState) {
    guard let albumID = state.inspectAlbum.albumID else { return }
    guard let album = state.resources.albumFor(id: albumID) else { return }
    item = album

    if !state.inspectAlbum.trackIDs.isEmpty {
      tracks = state.resources.tracksFor(ids: state.inspectAlbum.trackIDs)
    } else if !state.inspectAlbum.isRequestingTracks {
      tracks = []
      mainStore.dispatch(InspectAlbumActions.getAlbumTracks(album: album))
    }
  }

  // MARK: UITableViewDelegate Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "trackListCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    let track = tracks[indexPath.row]

    cell.setupCellWithoutImage(forItem: track, action: nil)

    cell.seededCell = seeds?.isInSeeds(item: track) == true

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = tracks[indexPath.row]

    if seeds?.isInSeeds(item: track) == true {
      mainStore.dispatch(SeedsActions.RemoveSeed(item: track))
    } else {
      mainStore.dispatch(SeedsActions.AddSeed(item: track))
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let item = item else { return nil }

    let view = loadUIViewFromNib(ItemWithTrackListHeaderView.self)

    view.setup(forItem: item)

    return view
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UIScreen.main.bounds.width
  }

}
