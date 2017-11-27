//
//  MIDIPlayerController.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-27.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import UIKit

class MIDIPlayerController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // button action
    @IBAction func back(_ sender: UIButton) {
        performSegue(withIdentifier: "back", sender: self)
        
    }
    
    
}
