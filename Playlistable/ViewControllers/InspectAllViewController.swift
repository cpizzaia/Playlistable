//
//  InspectAllViewController.swift
//  Playlistable
//
//  Created by Cody Pizzaia on 11/8/17.
//  Copyright © 2017 Cody Pizzaia. All rights reserved.
//

import Foundation
import UIKit

class InspectAllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var inspectAllTableView: UITableView!
  
  var tracks = [Track]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    inspectAllTableView.dataSource = self
    inspectAllTableView.delegate = self
    
    inspectAllTableView.register(
      UINib(nibName: "InspectAllTableViewCell", bundle: nil),
      forCellReuseIdentifier: "inspectAllCell"
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    inspectAllTableView.reloadData()
  }
  
  // MARK: UITableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "inspectAllCell") as! InspectAllTableViewCell
    
    cell.setupCellFor(item: tracks[indexPath.row])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  
}
