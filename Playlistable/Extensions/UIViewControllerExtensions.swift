//
//  UIViewControllerExtension.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/22/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  static func currentViewController() -> UIViewController? {
    guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return nil}
    return UIViewController.findBestViewController(viewController)
  }
  
  private static func findBestViewController(_ viewController: UIViewController) -> UIViewController {
    
    if (viewController.presentedViewController != nil) {
      return UIViewController.findBestViewController(viewController.presentedViewController!)
      
    } else if let splitViewController = viewController as? UISplitViewController {
      
      if splitViewController.viewControllers.count > 0 {
        return UIViewController.findBestViewController(splitViewController.viewControllers.last!)
      } else {
        return viewController
      }
      
    } else if let navController = viewController as? UINavigationController {
      
      if navController.viewControllers.count > 0 {
        return UIViewController.findBestViewController(navController.topViewController!)
      } else {
        return viewController
      }
      
    } else if let tabBarController = viewController as? UITabBarController {
      
      if tabBarController.viewControllers?.count ?? 0 > 0 {
        return UIViewController.findBestViewController(tabBarController.selectedViewController!)
      } else {
        return viewController
      }
    } else {
      
      return viewController
      
    }
  }
}
