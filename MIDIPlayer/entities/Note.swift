//
//  Note.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-29.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import AudioToolbox

class Note {
    
    var noteInfo:MIDINoteMessage!
    var time:MusicTimeStamp!
    
    init(noteInfo n:MIDINoteMessage, time t:MusicTimeStamp!) {
        noteInfo = n
        time = t
    }

}
