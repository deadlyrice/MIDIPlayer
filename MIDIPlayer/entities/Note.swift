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
    var note:UInt8!
    var time:MusicTimeStamp!
    var channel:UInt8!
    var velocity:UInt8!
    var releaseVelocity:UInt8!
    var duration:Float32
    
    init(note n:UInt8, time t:MusicTimeStamp, duration d:Float32, channel c:UInt8 = 0, velocity v:UInt8 = 100, releaseVelocity rv:UInt8 = 0) {
        note = n
        time = t
        duration = d
        channel = c
        velocity = v
        releaseVelocity = rv
    }
}
