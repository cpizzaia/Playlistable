//
//  GeneratedPlaylistViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/12/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit
import ReSwift
import SVProgressHUD

class GeneratedPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyStoreSubscriber {
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let tracks: [Track]
    let currentlyPlayingTrack: Track?
    var noTracks: Bool {
      return tracks.isEmpty
    }
    let playlistID: String?
    let userID: String?
    let isGenerating: Bool
  }

  @IBOutlet var noPlaylistView: UIView!
  @IBOutlet var noPlaylistViewLabel: UILabel!
  @IBOutlet var playlistView: UIView!
  @IBOutlet var playlistTableView: UITableView!

  var props: Props?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.myDarkBlack

    noPlaylistView.backgroundColor = UIColor.clear
    noPlaylistViewLabel.font = UIFont.myFont(withSize: 17)
    noPlaylistViewLabel.textColor = UIColor.myWhite

    playlistView.backgroundColor = UIColor.clear

    playlistTableView.delegate = self
    playlistTableView.dataSource = self
    playlistTableView.delaysContentTouches = false
    playlistTableView.backgroundColor = UIColor.myDarkBlack
    playlistTableView.separatorStyle = .none

    playlistTableView.register(
      InspectAllTableViewCell.self,
      forCellReuseIdentifier: "generatedTrackCell"
    )

    // Adding view above section header to make color the same
    var frame = playlistTableView.bounds
    frame.origin.y = -frame.size.height

    let bgView = UIView(frame: frame)
    bgView.backgroundColor = UIColor.myLightBlack

    playlistTableView.insertSubview(bgView, at: 0)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    mainStore.subscribe(self)

    navigationItem.title = "Generated Playlist"
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }

  func mapStateToProps(state: AppState) -> GeneratedPlaylistViewController.Props {
    let tracks: [Track]
    let currentlyPlayingTrack: Track?

    if let playlistID = state.generatedPlaylist.playlistID, let playlist = state.resources.playlistFor(id: playlistID) {
      tracks = state.resources.tracksFor(ids: playlist.trackIDs)
    } else {
      tracks = []
    }

    if let playingTrackID = state.spotifyPlayer.playingTrackID {
      currentlyPlayingTrack = state.resources.tracks[playingTrackID]
    } else {
      currentlyPlayingTrack = nil
    }

    return Props(
      tracks: tracks,
      currentlyPlayingTrack: currentlyPlayingTrack,
      playlistID: state.generatedPlaylist.playlistID,
      userID: state.spotifyAuth.userID,
      isGenerating: state.generatedPlaylist.isGenerating
    )
  }

  func didReceiveNewProps(props: Props) {

    noPlaylistView.isHidden = !props.noTracks
    playlistView.isHidden = props.noTracks

    if props.isGenerating {
      noPlaylistView.isHidden = true
      playlistView.isHidden = true
      SVProgressHUD.show()
    } else {
      SVProgressHUD.dismiss()
    }

    if props.noTracks {
      navigationItem.setLeftBarButton(nil, animated: false)
    } else if navigationItem.leftBarButtonItem == nil {

      let leftNavigatorButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePlaylist))

      leftNavigatorButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.myFont(withSize: 17)], for: .normal)

      navigationItem.setLeftBarButton(leftNavigatorButton, animated: true)
    }

    playlistTableView.reloadData()
  }

  @objc private func savePlaylist() {
    presentAlertViewWithTextInput(
      title: "Save Playlist",
      message: "Enter a name for your playlist",
      successActionTitle: "OK",
      failureActionTitle: "Cancel",
      success: { playlistName in
        guard let userID = self.props?.userID else { return }
        mainStore.dispatch(GeneratePlaylistActions.createSavedPlaylist(
          userID: userID,
          name: playlistName,
          trackIDs: self.props?.tracks.map { $0.id } ?? [],
          success: {
            self.presentAlertView(
              title: "Save Successful",
              message: "Your playlist has been saved to your Spotify, it may take some time to appear",
              completion: {}
            )
          },
          failure: {
            self.presentAlertView(
              title: "Save Failed",
              message: "Please try again",
              completion: {}
            )
          }
        ))
      },
      failure: {}
    )
  }

  // MARK: Table View Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return props?.tracks.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "generatedTrackCell") as? InspectAllTableViewCell else { return UITableViewCell() }

    guard let tracks = props?.tracks else { return cell }

    let track = tracks[indexPath.row]

    cell.setupCellWithImage(forItem: track, action: nil)

    cell.currentlyPlaying = track.id == props?.currentlyPlayingTrack?.id

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let playlistID = props?.playlistID else { return }

    mainStore.dispatch(SpotifyPlayerActions.playPlaylist(
      id: playlistID,
      startingWithTrack: indexPath.row,
      shouldShuffle: false
    ))
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = loadUIViewFromNib(GeneratedPlaylistHeaderView.self)

    view.setupView(action: {
      guard
        let props = self.props,
        let playlistID = props.playlistID
      else { return }

      mainStore.dispatch(SpotifyPlayerActions.playPlaylist(
        id: playlistID,
        startingWithTrack: rand(props.tracks.startIndex, props.tracks.endIndex - 1),
        shouldShuffle: true
      ))
    })

    return view
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UIScreen.main.bounds.height * 0.075
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForFooterWithPlayerBar
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView()

    view.backgroundColor = .clear

    return view
  }
}
