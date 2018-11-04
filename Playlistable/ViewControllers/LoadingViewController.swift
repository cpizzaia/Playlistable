//
//  LoadingViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/1/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController, MyStoreSubscriber {
  // MARK: Public Types
  typealias StoreSubscriberStateType = AppState

  struct Props {
    let isAuthed: Bool
    let hasUser: Bool
    let hasPremium: Bool
  }

  // MARK: Public Properties
  var props: Props?

  // MARK: Public Methods
  init() {
    super.init(nibName: nil, bundle: nil)

    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    mainStore.unsubscribe(self)
  }

  func mapStateToProps(state: AppState) -> Props {
    return Props(
      isAuthed: state.spotifyAuth.isAuthed,
      hasUser: state.spotifyAuth.userID != nil,
      hasPremium: state.spotifyAuth.isPremium == true
    )
  }

  func didReceiveNewProps(props: Props) {
    if !props.isAuthed {
      return present(IntroViewController(), animated: true, completion: nil)
    }

    if props.isAuthed && props.hasUser && props.hasPremium {
      let vc = PlayAndTabBarContainerViewController()

      return present(vc, animated: true, completion: nil)
    }
  }

  // MARK: Private Properties
  private func setupViews() {
    view.backgroundColor = .myDarkBlack

    let imageView = UIImageView()

    view.addSubview(imageView)

    imageView.snp.makeConstraints { make in
      make.height.equalTo(imageView.snp.width)
      make.width.equalTo(view.snp.width).multipliedBy(0.2)
      make.centerX.equalTo(view)
      make.centerY.equalTo(view).multipliedBy(0.95)
    }

    imageView.image = UIImage(named: "logo")
  }
}
