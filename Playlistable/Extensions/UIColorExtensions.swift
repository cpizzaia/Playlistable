//
//  UIColorExtensions.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 1/20/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  static var myDarkBlack: UIColor {
    return UIColor(rgb: 0x101010)
  }

  static var myLightBlack: UIColor {
    return UIColor(rgb: 0x212121)
  }

  static var myWhite: UIColor {
    return UIColor(rgb: 0xFFFFFF)
  }

  static var myAccent: UIColor {
    return UIColor(rgb: 0xE0AC00)
  }

  static var myGray: UIColor {
    return UIColor(rgb: 0x999999)
  }

  static var myDarkGray: UIColor { // so far only used for duration bar background
    return UIColor(rgb: 0x323232)
  }

  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")

    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }

  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
}
