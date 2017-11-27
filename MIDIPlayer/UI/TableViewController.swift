//
//  TableViewController.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-27.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import UIKit

enum TableMode:Int {
    case main, samples, saved
}

class TableViewController:UITableViewController {
    
    var mode = TableMode.main
    
    var mainMenuCellList = ["Samples","Saved MIDI Files"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    // override
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .main:
            return self.mainMenuCellList.count
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mode {
        case .main:
            
            print(indexPath.row)
            let cell = UITableViewCell()
            cell.textLabel?.text = self.mainMenuCellList[indexPath.row]
            return cell
            
        default:
            break
            
        }
        return UITableViewCell()
    }
    
}
