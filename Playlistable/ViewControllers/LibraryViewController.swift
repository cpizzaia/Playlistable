//
//  LibraryViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 10/24/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var libraryTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    libraryTableView.register(
      UINib(nibName: "LibraryTableViewCell", bundle: nil),
      forCellReuseIdentifier: "libraryCell"
    )
    
    libraryTableView.dataSource = self
    libraryTableView.delegate = self
    
    libraryTableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.title = "Library"
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  // MARK: Table View Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = libraryTableView.dequeueReusableCell(withIdentifier: "libraryCell") as! LibraryTableViewCell
    
    cell.setupCellWith(title: "Saved Tracks")
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let viewController = loadUIViewControllerFromNib(InspectAllViewController.self)
    
    viewController.type = .savedTracks
    
    navigationController?.pushViewController(viewController, animated: true)
  }
}
