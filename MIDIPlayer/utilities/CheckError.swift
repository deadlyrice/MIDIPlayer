//
//  CheckError.swift
//  honours project
//
//  Created by Yulun Wu on 2017-11-15.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import AudioToolbox


func CheckError(_ error:OSStatus){
    if error == 0 {return}
    
    switch (error){
    
    case kAudioToolboxErr_InvalidSequenceType :
        print( " kAudioToolboxErr_InvalidSequenceType")
    
    case kAudioToolboxErr_TrackIndexError :
        print( " kAudioToolboxErr_TrackIndexError")
    
    case kAudioToolboxErr_TrackNotFound :
        print( " kAudioToolboxErr_TrackNotFound")
    
    case kAudioToolboxErr_EndOfTrack :
        print( " kAudioToolboxErr_EndOfTrack")
    
    case kAudioToolboxErr_StartOfTrack :
        print( " kAudioToolboxErr_StartOfTrack")
    
    case kAudioToolboxErr_IllegalTrackDestination    :
        print( " kAudioToolboxErr_IllegalTrackDestination")
    
    case kAudioToolboxErr_NoSequence         :
        print( " kAudioToolboxErr_NoSequence")
    
    case kAudioToolboxErr_InvalidEventType        :
        print( " kAudioToolboxErr_InvalidEventType")
    
    case kAudioToolboxErr_InvalidPlayerState    :
        print( " kAudioToolboxErr_InvalidPlayerState")
        
    default:
        print("Cannot identify the error!")
    }
    
}
