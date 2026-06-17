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
    case main, samples, saved, create, rename, delete
}

class TableViewController:UITableViewController {
    
    var mode = TableMode.main
    
    var mainMenuCellList = ["Samples","Saved MIDI Files", "Create a new MIDI file", "rename a MIDI file", "delete a MIDI file"]
    var sampleCellList:Array<String>!
    var savedCellList:Array<String>!
    var selectedRowName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = Theme.background
        tableView.separatorColor = Theme.hairline
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
        tableView.rowHeight = 60
        tableView.tableHeaderView = makeHeader()

        reloadData()
    }

    private func makeHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "MIDI Player"
        label.font = Theme.rounded(28, .bold)
        label.textColor = Theme.textPrimary
        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -10),
        ])
        return header
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
        case .rename:
            return self.savedCellList.count
            
        case .delete:
            return self.savedCellList.count
        default:
            return 0
        }
        //return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.backgroundColor = .clear
        cell.accessoryType = .none
        let selectedBG = UIView()
        selectedBG.backgroundColor = Theme.accentSoft
        cell.selectedBackgroundView = selectedBG

        var content = cell.defaultContentConfiguration()
        var title = ""
        var icon: String? = nil
        var tint = Theme.accent
        var textColor = Theme.textPrimary
        var isHeaderRow = false   // bold "back"/menu emphasis

        switch mode {
        case .main:
            title = mainMenuCellList[indexPath.row]
            let icons = ["music.note.list", "folder", "plus.circle", "pencil", "trash"]
            icon = indexPath.row < icons.count ? icons[indexPath.row] : nil
            if indexPath.row == 4 { tint = Theme.danger }
            cell.accessoryType = .disclosureIndicator
        case .samples, .saved, .rename, .delete:
            let list = (mode == .samples) ? sampleCellList! : savedCellList!
            let raw = list[indexPath.row]
            if indexPath.row == 0 {
                title = "Back"; icon = "chevron.backward"; textColor = Theme.accent; isHeaderRow = true
            } else {
                title = raw.replacingOccurrences(of: ".mid", with: "")
                if mode == .delete {
                    icon = "trash"; tint = Theme.danger
                } else {
                    icon = "music.note"
                    cell.accessoryType = .disclosureIndicator
                }
            }
        default:
            break
        }

        content.text = title
        content.textProperties.font = Theme.rounded(17, isHeaderRow ? .semibold : .regular)
        content.textProperties.color = textColor
        if let icon = icon {
            content.image = UIImage(systemName: icon)
            content.imageProperties.tintColor = tint
            content.imageToTextPadding = 14
            content.imageProperties.maximumSize = CGSize(width: 22, height: 22)
        }
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath){
        switch mode {
        case .main:
            switch didSelectRowAt.row {
            case 0:
                mode = .samples
                self.reloadData()
                tableView.reloadData()
                break
            case 1:
                mode = .saved
                self.reloadData()
                tableView.reloadData()
                break
            case 2:
                mode = .create
                performSegue(withIdentifier: "create a new midi file", sender: self)
                break
            case 3:
                mode = .rename
                self.reloadData()
                tableView.reloadData()
                break
            case 4:
                mode = .delete
                self.reloadData()
                tableView.reloadData()
                break
                
            default:
                break
            }
        case .samples:
            if (didSelectRowAt.row == 0) {
                
                mode = .main
                tableView.reloadData()
            } else if didSelectRowAt.row < self.sampleCellList.count {

                self.selectedRowName = self.sampleCellList[didSelectRowAt.row]
                performSegue(withIdentifier: "edit", sender: self)
            }
            
            break
        case .saved:
            if (didSelectRowAt.row == 0) {
                
                mode = .main
                tableView.reloadData()
            } else if (didSelectRowAt.row < self.savedCellList.count) {
                self.selectedRowName = self.savedCellList[didSelectRowAt.row]
                performSegue(withIdentifier: "edit", sender: self)

            }
            
            break
        case .rename:
            if (didSelectRowAt.row == 0) {
                
                mode = .main
                tableView.reloadData()
            } else if (didSelectRowAt.row < self.savedCellList.count) {
                let name = self.savedCellList[didSelectRowAt.row]
                self.selectedRowName = name
                performSegue(withIdentifier: "rename", sender: self)
            }
        case .delete:
            if (didSelectRowAt.row == 0) {
                
                mode = .main
                tableView.reloadData()
            } else if (didSelectRowAt.row < self.savedCellList.count) {
                do {
                    let name = self.savedCellList[didSelectRowAt.row]
                    let alert = UIAlertController(title: "Are you sure to delete \(name)?", message: nil, preferredStyle: .alert)
                    let alertNOAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    alert.addAction(alertNOAction)
                    let alertYESAction = UIAlertAction(title: "Yes", style: .default , handler: {(UIAlertAction) in
                        deleteAFile(fileName: name)
                        self.mode = .main
                        tableView.reloadData()
                        
                    })
                    alert.addAction(alertYESAction)
                    self.present(alert, animated: true, completion: nil)
                
                
                    
                }
            }
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "edit") {
            if selectedRowName != nil {
                let midiPlayerController = (segue.destination as! MIDIPlayerController)
                midiPlayerController.fileName = selectedRowName!
                midiPlayerController.mode = mode
                
            }
            
        } else if (segue.identifier == "rename") {
            let renamePageController = (segue.destination as! RenamePageController)
            renamePageController.fileName = selectedRowName!
            
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
