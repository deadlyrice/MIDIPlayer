//
//  CreatingPageViewController.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-28.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import UIKit

class CreatingPageViewController: UIViewController {
    
    @IBOutlet weak var fileNameTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // override
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "edit") {
            
            let midiPlayerController = (segue.destination as! MIDIPlayerController)
            midiPlayerController.fileName = fileNameTextField.text
            midiPlayerController.mode = .create
            
            
        }
    }
    
    
    // action
    
    @IBAction func cancel(_ sender: UIButton) {
        performSegue(withIdentifier: "cancel", sender: self)
        
    }
    
    @IBAction func create(_ sender: UIButton) {
        if let name = fileNameTextField.text{
            if name.isEmpty {
                print("Please enter the file name.")
            } else {
                print("Creating the file")
                performSegue(withIdentifier: "edit", sender: self)
            }
        } else {
            
            print("Name is nil")
        }
        
        
        
    }
}
