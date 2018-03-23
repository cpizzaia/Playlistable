//
//  BigButton.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/21/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class BigButton: UIButton {

  private var styled = false
  override func layoutSubviews() {
    super.layoutSubviews()
    if styled { return }
    styled = true

    layer.cornerRadius = frame.size.height / 2
    clipsToBounds = true

    backgroundColor = UIColor.myAccent
    titleLabel?.font = UIFont.myFontBold(withSize: 15)

    setTitleColor(UIColor.myWhite, for: .normal)
  }
}
