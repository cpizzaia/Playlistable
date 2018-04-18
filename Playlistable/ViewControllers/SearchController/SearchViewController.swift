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

class SearchViewController: UIViewController, UISearchBarDelegate, MyStoreSubscriber, UITableViewDelegate, UITableViewDataSource {
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let searchData: SearchCollection
    let seeds: SeedsState
    let searchQuery: String?
  }

  @IBOutlet var noResultsView: UIView!
  @IBOutlet var noResultsLabel: UILabel!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var searchResultsTableView: UITableView!

  struct SearchCollection {
    let artists: [Artist]
    let tracks: [Track]
    let albums: [Album]

    var isEmpty: Bool {
      return artists.isEmpty && tracks.isEmpty && albums.isEmpty
    }
  }

  var props: Props?
  var sections = [Int: [Item]]()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.myDarkBlack

    searchBar.delegate = self
    searchResultsTableView.delegate = self
    searchResultsTableView.dataSource = self

    searchResultsTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "searchCell"
    )

    searchResultsTableView.showsVerticalScrollIndicator = false
    searchResultsTableView.separatorStyle = .none
    searchResultsTableView.backgroundColor = UIColor.clear

    noResultsLabel.font = UIFont.myFont(withSize: 17)
    noResultsLabel.textColor = UIColor.myWhite

    noResultsView.backgroundColor = UIColor.clear

    searchBar.barTintColor = UIColor.myLightBlack
    searchBar.placeholder = "Search"

    let cancelButtonAttributes: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.myWhite]

    UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedStringKey: Any], for: UIControlState.normal)
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

  func mapStateToProps(state: AppState) -> SearchViewController.Props {
    return Props(
      searchData: SearchCollection(
        artists: state.resources.artistsFor(ids: state.search.artistIDs),
        tracks: state.resources.tracksFor(ids: state.search.trackIDs),
        albums: state.resources.albumsFor(ids: state.search.albumIDs)
      ),
      seeds: state.seeds,
      searchQuery: state.search.query
    )
  }

  func didReceiveNewProps(props: Props) {
    searchResultsTableView.isHidden = true
    noResultsView.isHidden = false

    let noResults = props.searchData.isEmpty

    searchResultsTableView.isHidden = noResults
    noResultsView.isHidden = !noResults
    searchResultsTableView.reloadData()
    noResultsLabel.text = props.searchQuery == nil ? "Start by searching for your favorite music" : "Your search had no results"
  }

  private func getResourceFor(section: Int) -> [Item]? {
    return sections[section]
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
    sections = [:]

    if !(props?.searchData.tracks.isEmpty == true) {
      sections[count] = props?.searchData.tracks ?? []
      count += 1
    }

    if !(props?.searchData.artists.isEmpty == true) {
      sections[count] = props?.searchData.artists ?? []
      count += 1
    }

    if !(props?.searchData.albums.isEmpty == true) {
      sections[count] = props?.searchData.albums ?? []
      count += 1
    }

    return count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    guard let items = getResourceFor(section: indexPath.section) else {
      return UITableViewCell()
    }

    let item = items[indexPath.row]

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

    cell.seededCell = props?.seeds.isInSeeds(item: item) == true

    return cell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let items = getResourceFor(section: section) else {
      return nil
    }

    let view = loadUIViewFromNib(SearchResultSectionHeaderView.self)

    switch items.first {
    case _ as Artist:
      view.setupView(withTitle: "Artists", buttonTitle: "See All", andAction: {
        let vc = loadUIViewControllerFromNib(SeeAllSearchResultsViewController.self)

        vc.type = .artists

        self.navigationController?.pushViewController(vc, animated: true)
      })
    case _ as Track:
      view.setupView(withTitle: "Tracks", buttonTitle: "See All", andAction: {
        let vc = loadUIViewControllerFromNib(SeeAllSearchResultsViewController.self)

        vc.type = .tracks

        self.navigationController?.pushViewController(vc, animated: true)
      })
    case _ as Album:
      view.setupView(withTitle: "Albums", buttonTitle: "See All", andAction: {
        let vc = loadUIViewControllerFromNib(SeeAllSearchResultsViewController.self)

        vc.type = .albums

        self.navigationController?.pushViewController(vc, animated: true)
      })
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

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForFooterWithPlayerBar
  }

  // MARK: UISearchBar Methods
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else { return }
    mainStore.dispatch(SearchActions.search(query: query))

    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
  }

  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.setShowsCancelButton(false, animated: true)
  }
}
