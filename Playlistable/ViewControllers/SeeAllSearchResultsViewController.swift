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

class SeeAllSearchResultsViewController: UIViewController, MyStoreSubscriber, UITableViewDelegate, UITableViewDataSource {
  typealias StoreSubscriberStateType = AppState
  struct Props {
    let items: [Item]
    let seeds: SeedsState
  }

  enum ControllerType {
    case artists
    case tracks
    case albums
  }

  // MARK: Public Properties
  var props: Props?

  // MARK: Private Properties
  private let tableView = UITableView(frame: .zero, style: .grouped)
  private let type: ControllerType

  // MARK: Public Methods
  init(type: ControllerType) {
    self.type = type

    super.init(nibName: nil, bundle: nil)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

  func mapStateToProps(state: AppState) -> SeeAllSearchResultsViewController.Props {
    var items = [Item]()

    guard let currentQuery = state.search.currentQuery, let searchResults = state.search.querySearchResults[currentQuery] else {
      return Props(items: items, seeds: state.seeds)
    }

    switch type {
    case .artists:
      items = state.resources.artistsFor(ids: searchResults.artistIDs)
    case .tracks:
      items = state.resources.tracksFor(ids: searchResults.trackIDs)
    case .albums:
      items = state.resources.albumsFor(ids: searchResults.albumIDs)
    }

    return Props(items: items, seeds: state.seeds)
  }

  func didReceiveNewProps(props: Props) {
    tableView.reloadData()
  }

  // MARK: Private Methods
  private func setupViews() {
    view.backgroundColor = UIColor.myDarkBlack
    setupTableView()
  }

  private func setupTableView() {
    view.addSubview(tableView)

    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(
      InspectAllTableViewCell.self,
      forCellReuseIdentifier: "searchResultCell"
    )

    tableView.backgroundColor = UIColor.clear
    tableView.separatorStyle = .none
  }

  // MARK: UITableViewMethods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return props?.items.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    guard let items = props?.items else { return cell }

    let item = items[indexPath.row]

    cell.seededCell = props?.seeds.isInSeeds(item: item) == true

    if let album  = item as? Album {
      cell.setupCellWithImage(forItem: item, action: {
        mainStore.dispatch(InspectAlbumActions.InspectAlbum(albumID: album.id))

        let vc = ItemWithTrackListViewController(itemType: .album)

        self.navigationController?.pushViewController(vc, animated: true)
      })
    } else {
      cell.setupCellWithImage(forItem: item, action: nil)
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let items = props?.items else { return }

    let item = items[indexPath.row]

    guard item is Track || item is Artist else {
      tableView.deselectRow(at: indexPath, animated: false)
      return
    }

    if props?.seeds.isInSeeds(item: item) == true {
      mainStore.dispatch(SeedsActions.RemoveSeed(item: item))
    } else {
      if props?.seeds.isFull == true {
        presentSeedsFullAlert()
        return
      }

      mainStore.dispatch(SeedsActions.AddSeed(item: item))
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
}
