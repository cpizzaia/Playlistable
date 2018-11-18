//
//  ClosureButton.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/17/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class DepressableClosureButton: UIButton {
  // MARK: Public Properties
  var touchDownClosure = {}
  var touchUpInsideClosure = {}
  var touchDragOutsideClosure = {}
  var touchCancelClosure = {}

  // MARK: Public Methods
  init() {
    super.init(frame: .zero)

    addTarget(self, action: #selector(executeTouchDownClosure), for: .touchDown)
    addTarget(self, action: #selector(executeTouchUpInsideClosure), for: .touchUpInside)
    addTarget(self, action: #selector(executeTouchDragOutsideClosure), for: .touchDragOutside)
    addTarget(self, action: #selector(executeTouchCancelClosure), for: .touchCancel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func executeTouchDownClosure() {
    touchDownClosure()
    depress()
  }

  @objc func executeTouchUpInsideClosure() {
    touchUpInsideClosure()
    rise()
  }

  @objc func executeTouchDragOutsideClosure() {
    touchDragOutsideClosure()
    rise()
  }

  @objc func executeTouchCancelClosure() {
    touchCancelClosure()
    rise()
  }

  // MARK: Private Methods
  private func depress() {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 5,
      options: [],
      animations: {
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    })
  }

  private func rise() {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 5,
      options: [.curveEaseInOut ],
      animations: {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
    })
  }
}
