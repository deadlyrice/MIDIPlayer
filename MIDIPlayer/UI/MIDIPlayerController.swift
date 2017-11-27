//
//  MIDIPlayerController.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-27.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class MIDIPlayerController: UIViewController {
    
    var musicSequence:MusicSequence!
    var fileName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(fileName)
    }
    
    // button action
    @IBAction func back(_ sender: UIButton) {
        performSegue(withIdentifier: "back", sender: self)
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        createMIDIFile(sequence: musicSequence, filename: fileName, ext: "mid")
    }
    
}
