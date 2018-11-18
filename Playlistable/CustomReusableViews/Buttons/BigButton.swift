//
//  BigButton.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/21/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class BigButton: DepressableClosureButton {
  // MARK: Public Methods
  override init() {
    super.init()

    clipsToBounds = true
    backgroundColor = UIColor.myAccent
    titleLabel?.font = UIFont.myFontBold(withSize: 15)
    setTitleColor(UIColor.myWhite, for: .normal)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.height / 2
  }
}
