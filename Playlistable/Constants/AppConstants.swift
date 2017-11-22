//
//  AppConstants.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

func log(_ message: String, functionName: String = #function, line: Int = #line, fileName: String = #file) {
  let className: String = fileName.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
  let statement = "[MT:\(Thread.isMainThread)] \(className) -> \(functionName)[L:\(line)]: \(message)"
  
  print(statement)
}


func loadUIViewControllerFromNib<T: UIViewController>(_ className: T.Type) -> T {
  
  return Bundle.main.loadNibNamed(String(describing: className), owner: nil)?.first as! T
}

func delay(_ delay:Double, closure:@escaping ()->()) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

struct KeychainKeys {
  static let playlistableSavedTracksPlaylistID = "playlistableSavedTracksPlaylistID"
}
