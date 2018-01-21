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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = 10
    clipsToBounds = true
    
    backgroundColor = UIColor.myWhite
    titleLabel?.font = UIFont.myFont(withSize: 17)
    
    setTitleColor(UIColor.myDarkBlack, for: .normal)
  }
}
