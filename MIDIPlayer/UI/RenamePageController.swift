//
//  RenamePageController.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-29.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import UIKit

class RenamePageController: ViewController {
    
    var fileName:String!
    
    @IBOutlet weak var fileNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileNameTextField.text = fileName
        fileNameTextField.becomeFirstResponder()
        fileNameTextField.selectAll(nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        fileNameTextField.selectAll(nil)
        
    }
    
    
    // action
    @IBAction func cancel(_ sender: UIButton) {
        performSegue(withIdentifier: "cancel", sender: self)
    }
    
    @IBAction func rename(_ sender: UIButton) {
        
    }
    
    
}
