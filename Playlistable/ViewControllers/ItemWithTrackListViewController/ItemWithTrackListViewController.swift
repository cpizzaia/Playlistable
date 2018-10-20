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

class ItemWithTrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyStoreSubscriber {
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let item: Item?
    let tracks: [Track]
    let seeds: SeedsState
  }

  enum ItemType {
    case album
  }

  @IBOutlet var trackListTableView: UITableView!

  var itemType: ItemType?
  var props: Props?

  override func viewDidLoad() {
    super.viewDidLoad()

    trackListTableView.separatorStyle = .none
    trackListTableView.showsVerticalScrollIndicator = false
    trackListTableView.register(
      InspectAllTableViewCell.self,
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

  func mapStateToProps(state: AppState) -> ItemWithTrackListViewController.Props {
    return mapStateForAlbum(state: state)
  }

  func didReceiveNewProps(props: Props) {
    switch itemType {
    case .some(.album):
      newPropsForAlbum(props: props)
    default:
      break
    }

    title = props.item?.title

    trackListTableView.reloadData()
  }

  func newPropsForAlbum(props: Props) {
    guard let item = props.item as? Album else { return }

    if props.tracks.isEmpty {
      mainStore.dispatch(InspectAlbumActions.getAlbumTracks(album: item))
    }
  }

  func mapStateForAlbum(state: AppState) -> Props {
    guard
      let albumID = state.inspectAlbum.albumID,
      let album = state.resources.albumFor(id: albumID)
      else {
        return Props(item: nil, tracks: [], seeds: state.seeds)
    }

    if !state.inspectAlbum.trackIDs.isEmpty {
      let tracks = state.resources.tracksFor(ids: state.inspectAlbum.trackIDs)
      return Props(item: album, tracks: tracks, seeds: state.seeds)
    } else if !state.inspectAlbum.isRequestingTracks {
      return Props(item: album, tracks: [], seeds: state.seeds)
    }

    return Props(item: nil, tracks: [], seeds: state.seeds)
  }

  // MARK: UITableViewDelegate Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return props?.tracks.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "trackListCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    guard let tracks = props?.tracks else { return cell }

    let track = tracks[indexPath.row]

    cell.setupCellWithoutImage(forItem: track, action: nil)

    cell.seededCell = props?.seeds.isInSeeds(item: track) == true

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let tracks = props?.tracks else { return }

    let track = tracks[indexPath.row]

    if props?.seeds.isInSeeds(item: track) == true {
      mainStore.dispatch(SeedsActions.RemoveSeed(item: track))
    } else {
      if props?.seeds.isFull == true {
        presentSeedsFullAlert()
        return
      }

      mainStore.dispatch(SeedsActions.AddSeed(item: track))
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let item = props?.item else { return nil }

    let view = loadUIViewFromNib(ItemWithTrackListHeaderView.self)

    view.setup(forItem: item)

    return view
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UIScreen.main.bounds.width
  }

}
