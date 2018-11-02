//
//  MyNavigationController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/1/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class MyNavigationController: UINavigationController {
  // MARK: Public Methods
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)

    navigationBar.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont.myFontBold(withSize: 17),
      NSAttributedString.Key.foregroundColor: UIColor.myWhite
    ]

    navigationBar.backgroundColor = UIColor.myLightBlack
    navigationBar.barTintColor = UIColor.myLightBlack
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
