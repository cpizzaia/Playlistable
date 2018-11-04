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

    if viewController.presentedViewController != nil {
      return UIViewController.findBestViewController(viewController.presentedViewController ?? UIViewController())

    } else if let splitViewController = viewController as? UISplitViewController {

      if splitViewController.viewControllers.count > 0 {
        return UIViewController.findBestViewController(splitViewController.viewControllers.last ?? UIViewController())
      } else {
        return viewController
      }

    } else if let navController = viewController as? UINavigationController {

      if navController.viewControllers.count > 0 {
        return UIViewController.findBestViewController(navController.topViewController ?? UIViewController())
      } else {
        return viewController
      }

    } else if let tabBarController = viewController as? UITabBarController {

      if tabBarController.viewControllers?.count ?? 0 > 0 {
        return UIViewController.findBestViewController(tabBarController.selectedViewController ?? UIViewController())
      } else {
        return viewController
      }
    } else {

      return viewController

    }
  }

  func presentSeedsFullAlert() {
    presentAlertView(
      title: "Selected Items Full",
      message: "Press OK to continue to generating a playlist or cancel to go back and remove items.",
      successActionTitle: "OK",
      failureActionTitle: "Cancel",
      success: {
        runOnMainThread {
          self.tabBarController?.selectedIndex = 1
        }
    },
      failure: {}
    )
  }

  func presentSavePlaylistAlert() {

  }

  func presentAlertView(title: String, message: String, completion: @escaping () -> Void) {

    let alertViewController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )

    alertViewController.addAction(
      UIAlertAction.init(title: "OK", style: .default, handler: { _ in completion() })
    )

    present(alertViewController, animated: true, completion: {})
  }

  func presentAlertView(title: String, message: String, successActionTitle: String, failureActionTitle: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let successAction = UIAlertAction(title: successActionTitle, style: .default, handler: { _ in success() })
    let cancelAction = UIAlertAction(title: failureActionTitle, style: .default, handler: { _ in failure() })

    alertViewController.addAction(cancelAction)
    alertViewController.addAction(successAction)

    present(alertViewController, animated: true, completion: {})
  }

  func presentAlertViewWithTextInput(title: String, message: String, successActionTitle: String, failureActionTitle: String, success: @escaping (String) -> Void, failure: @escaping () -> Void) {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let successAction = UIAlertAction(title: successActionTitle, style: .default, handler: { _ in
      guard let text = alertViewController.textFields?.first?.text else { return }

      success(text)
    })
    let cancelAction = UIAlertAction(title: failureActionTitle, style: .default, handler: { _ in failure() })

    alertViewController.addAction(cancelAction)
    alertViewController.addAction(successAction)

    alertViewController.addTextField(configurationHandler: nil)

    present(alertViewController, animated: true, completion: {})
  }
}
