//
//  RenamePageController.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-29.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import UIKit

class RenamePageController: ViewController, UITextFieldDelegate {
    
    var fileName:String!
    
    @IBOutlet weak var fileNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileNameTextField.delegate = self
        fileNameTextField.text = fileName
        fileNameTextField.becomeFirstResponder()
        fileNameTextField.selectAll(nil)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        fileNameTextField.selectAll(nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // action
    @IBAction func cancel(_ sender: UIButton) {
        performSegue(withIdentifier: "cancel", sender: self)
    }
    
    @IBAction func rename(_ sender: UIButton) {
        if let newName = fileNameTextField.text {
            if newName != "" {
                renameAFile(fileName: fileName, newName: newName)
                performSegue(withIdentifier: "cancel", sender: self)
            } else {
                print("please enter a name")
                
            }
        } else {
            
            print("name is nil")
        }
    }
    
    
}
