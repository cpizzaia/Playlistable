//
//  UITextViewExtension.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 3/18/18.
//  Copyright © 2018 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
  func setHeightForTextInside() {
    let contentSize = sizeThatFits(bounds.size)
    var newFrame = frame
    newFrame.size.height = contentSize.height
    frame = newFrame
    
    let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: bounds.height / bounds.width, constant: 1)
    
    addConstraint(aspectRatioTextViewConstraint)
  }
  
}
