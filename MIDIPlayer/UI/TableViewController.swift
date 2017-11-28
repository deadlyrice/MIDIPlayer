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
    case main, samples, saved, create
}

class TableViewController:UITableViewController {
    
    var mode = TableMode.main
    
    var mainMenuCellList = ["Samples","Saved MIDI Files", "Create a new MIDI file"]
    var sampleCellList:Array<String>!
    var savedCellList:Array<String>!
    var selectedRowName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    // override
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .main:
            return self.mainMenuCellList.count
            
        case .samples:
            return self.sampleCellList.count
            
        case .saved:
            return self.savedCellList.count
        case .create:
            return 0
        }
        //return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        switch mode {
            
        case .main:
            cell.textLabel?.text = self.mainMenuCellList[indexPath.row]
            break
            
        case .samples:
            cell.textLabel?.text = self.sampleCellList[indexPath.row]
            break
            
        case .saved:
            cell.textLabel?.text = self.savedCellList[indexPath.row]
            break
        case .create:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath){
        switch mode {
        case .main:
            if (didSelectRowAt.row == 0) {
                mode = .samples
                self.reloadData()
                tableView.reloadData()
                
            } else if (didSelectRowAt.row == 1) {
                mode = .saved
                self.reloadData()
                tableView.reloadData()
            } else if (didSelectRowAt.row == 2) {
                mode = .create
                //print("create")
                performSegue(withIdentifier: "create a new midi file", sender: self)
                
            }
            break
        case .samples:
            if (didSelectRowAt.row == 0) {
                
                mode = .main
                tableView.reloadData()
            } else if didSelectRowAt.row < self.sampleCellList.count {
                //print(tableView.cellForRow(at: didSelectRowAt)?.textLabel?.text)
                self.selectedRowName = tableView.cellForRow(at: didSelectRowAt)?.textLabel?.text
                performSegue(withIdentifier: "edit", sender: self)
            }
            
            break
        case .saved:
            if (didSelectRowAt.row == 0) {
                
                mode = .main
                tableView.reloadData()
            } /*else if (didSelectRowAt.row == 1) {
                //self.selectedRowName = tableView.cellForRow(at: didSelectRowAt)?.textLabel?.text
                performSegue(withIdentifier: "create a new midi file", sender: self)
                
            }*/ else if (didSelectRowAt.row < self.savedCellList.count) {
                self.selectedRowName = tableView.cellForRow(at: didSelectRowAt)?.textLabel?.text
                performSegue(withIdentifier: "edit", sender: self)
                
            }
            
            break
        case .create:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "edit") {
            if selectedRowName != nil {
                let midiPlayerController = (segue.destination as! MIDIPlayerController)
                midiPlayerController.fileName = selectedRowName!
                midiPlayerController.musicSequence = getSequenceFromASampleFile(fileName: self.selectedRowName!)
            }
            
        } 
    }
    
    // functions
    func reloadData(){
        sampleCellList = getSampleList()
        sampleCellList.insert("back", at: 0)
        savedCellList = getSavedList()
        savedCellList.insert("back", at: 0)
        
    }
    
    
}
