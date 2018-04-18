//
//  MyStoreSubscriber.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 4/17/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift

protocol MyStoreSubscriber: StoreSubscriber {
  associatedtype Props

  var props: Props? { get set }

  func mapStateToProps(state: StoreSubscriberStateType) -> Props

  func didReceiveNewProps(props: Props)
}

extension MyStoreSubscriber {
  func newState(state: StoreSubscriberStateType) {
    self.props = mapStateToProps(state: state)

    if let props = props {
      didReceiveNewProps(props: props)
    }
  }
}
