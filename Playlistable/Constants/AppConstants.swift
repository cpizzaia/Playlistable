//
//  AppConstants.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

// FIXME: The global container view puts a view over everything,
// this is so we can detect if it's displayed and adjust for it's height,
// there is probably a better way to do this than a global variable.
var isPlayerBarHidden = false
private var playerBarHeight = CGFloat(45.0)
var heightForFooterWithPlayerBar: CGFloat {
  return isPlayerBarHidden ? 0 : playerBarHeight
}

func log(_ message: String, functionName: String = #function, line: Int = #line, fileName: String = #file) {
  let className: String = fileName.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
  let statement = "[MT:\(Thread.isMainThread)] \(className) -> \(functionName)[L:\(line)]: \(message)"

  print(statement)
}

func loadUIViewControllerFromNib<T: UIViewController>(_ className: T.Type) -> T {

  return Bundle.main.loadNibNamed(String(describing: className), owner: nil)?.first as? T ?? T()
}

func loadUIViewFromNib<T: UIView>(_ className: T.Type) -> T {

  return Bundle.main.loadNibNamed(String(describing: className), owner: nil)?.first as? T ?? T()
}

func delay(_ delay: Double, closure:@escaping () -> Void) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure
  )
}

func runOnMainThread(_ block: @escaping () -> Void) {
  if Thread.isMainThread { return block() }

  DispatchQueue.main.async(execute: block)
}

func trackURI(fromID id: String) -> String {
  return "spotify:track:\(id)"
}

func playlistURI(fromID id: String) -> String {
  return "spotify:playlist:\(id)"
}

func rand<T>(_ min: T, _ max: T) -> T where T: BinaryInteger {
  let _min = min + 1
  let difference = max - _min
  return T(arc4random_uniform(UInt32(difference))) + _min
}
