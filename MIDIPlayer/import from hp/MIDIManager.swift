//
//  File.swift
//  honours project
//
//  Created by Yulun Wu on 2017-11-15.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

class MIDIManager {
    
    var musicSequence:MusicSequence?
    var musicTrack:MusicTrack?
    var musicPlayer:MusicPlayer?
    
    
    enum Notes:UInt8 {
        case C0 = 12, Cs0, D0, Ds0, E0, F0, Fs0, G0, Gs0, A0, As0, B0,
            C1, Cs1, D1, Ds1, E1, F1, Fs1, G1, Gs1, A1, As1, B1,
            C2, Cs2, D2, Ds2, E2, F2, Fs2, G2, Gs2, A2, As2, B2,
            C3, Cs3, D3, Ds3, E3, F3, Fs3, G3, Gs3, A3, As3, B3,
            C4, Cs4, D4, Ds4, E4, F4, Fs4, G4, Gs4, A4, As4, B4,
            C5, Cs5, D5, Ds5, E5, F5, Fs5, G5, Gs5, A5, As5, B5,
            C6, Cs6, D6, Ds6, E6, F6, Fs6, G6, Gs6, A6, As6, B6,
            C7, Cs7, D7, Ds7, E7, F7, Fs7, G7, Gs7, A7, As7, B7,
            C8
        
    }
    
    init(){
        print("new MIDIManager")
        createATestingMIDIFile()
        openAMIDIFile(fileName: "out")
        
        MusicPlayerSetSequence(musicPlayer!, musicSequence)
        MusicPlayerStart(musicPlayer!)
        
        
    }
    
    /*
    func noteForMidiNumber(midiNumber:Int) -> String {
    
        let noteArraySharps = ["", "", "", "", "", "", "", "", "", "", "", "",
            "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0",
            "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1",
            "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
            "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
            "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
            "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
            "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6",
            "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7",
            "C8", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
    
        return noteArraySharps[midiNumber];
    }
 */
    
    func createATestingMIDIFile(){
        NewMusicSequence(&musicSequence)
        MusicSequenceNewTrack(musicSequence!, &musicTrack)
        NewMusicPlayer(&musicPlayer)
        
        var time = MusicTimeStamp(2.0)
        
        insertANote(note: Notes.C4.rawValue, time: time, duration:8)
        time+=1
        
        insertANote(note: Notes.D4.rawValue, time: time, duration:7)
        time+=1
        
        insertANote(note: Notes.E4.rawValue, time: time, duration:6)
        time+=1
        
        insertANote(note: Notes.F4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.G4.rawValue, time: time, duration:4)
        time+=1
        
        insertANote(note: Notes.A4.rawValue, time: time, duration:3)
        time+=1
        
        insertANote(note: Notes.B4.rawValue, time: time, duration:2)
        time+=1
        
        insertANote(note: Notes.C5.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.E5.rawValue, time: time)
        
        insertANote(note: Notes.C5.rawValue, time: time)
        time+=0.5
        
        
        createMIDIFile(sequence: musicSequence!, filename: "out", ext: "mid")
        
        NewMusicSequence(&musicSequence)
        
        
    }
    
    func openAMIDIFile (fileName:String) {
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        if let fileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("\(fileName).mid") {
            MusicSequenceFileLoad(musicSequence!, fileURL as CFURL, MusicSequenceFileTypeID.midiType, MusicSequenceLoadFlags.smf_ChannelsToTracks)
            
            MusicSequenceGetIndTrack(musicSequence!, 0, &musicTrack)
            
            var hasCurrentEvent:DarwinBoolean = DarwinBoolean.init(true)
            var musicEventIterator:MusicEventIterator?
            var musicTimeStamp:MusicTimeStamp = 0.0
            var musicEventType:MusicEventType = 0
            var musicEventDataRef:UnsafeRawPointer?
            var eventDataSize:UInt32 = 0
            
            NewMusicEventIterator(musicTrack!, &musicEventIterator)
            MusicEventIteratorHasCurrentEvent (musicEventIterator!, &hasCurrentEvent);
            
            print(kMusicEventType_MIDINoteMessage)
            
            while (hasCurrentEvent).boolValue {
                // do work here
                MusicEventIteratorGetEventInfo(musicEventIterator!, &musicTimeStamp, &musicEventType, &musicEventDataRef, &eventDataSize)
                
                if musicEventType == kMusicEventType_MIDINoteMessage {
                    let eventData = musicEventDataRef!.load(as: MIDINoteMessage.self)
                    print(eventData)
                }
                print(musicTimeStamp,musicEventType,eventDataSize)
                MusicEventIteratorNextEvent (musicEventIterator!);
                MusicEventIteratorHasCurrentEvent (musicEventIterator!, &hasCurrentEvent);
            }
        
            
        } else {
            
            print("cannot find the file")
        }
    }
    
    
    
    func insertANote(note:UInt8, time:MusicTimeStamp, channel:UInt8 = 0, velocity:UInt8 = 60, releaseVelocity:UInt8 = 0, duration:Float32 = 1.0){
        var note = MIDINoteMessage(channel: channel,
                                   note: note,
                                   velocity: velocity,
                                   releaseVelocity: releaseVelocity,
                                   duration: duration )
        MusicTrackNewMIDINoteEvent(musicTrack!, time, &note)
    }
    
    func createMIDIFile(sequence:MusicSequence, filename:String, ext:String)  {
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        if let fileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("\(filename).\(ext)") {
        
            print("creating midi file at \(fileURL)")
            
            let timeResolution = determineTimeResolution(musicSequence: sequence)
            let status = MusicSequenceFileCreate(sequence, fileURL as CFURL, .midiType, [.eraseFile], Int16(timeResolution))
            if status != noErr {
                print("error:",status)
            }
        }
    }
    
    func determineTimeResolution(musicSequence:MusicSequence) -> UInt32 {
        var track:MusicTrack?
        var status = MusicSequenceGetTempoTrack(musicSequence, &track)
        
        
        if let tempoTrack = track {
            var propertyLength = UInt32(0)
            
            var junk = UInt32(0)
            status = MusicTrackGetProperty(tempoTrack,
                                           kSequenceTrackProperty_TimeResolution,
                                           &junk,
                                           &propertyLength)
            
            if status != noErr {
                print("error:", status)
                
            }
            var timeResolution = UInt32(0)
            status = MusicTrackGetProperty(tempoTrack,
                                           kSequenceTrackProperty_TimeResolution,
                                           &timeResolution,
                                           &propertyLength)
            
            if status != noErr {
                //checkError(status)
                print("error:", status)
                
            }
            
            return timeResolution
        } else {
            //os_log("error getting tempo track", log: MIDIManager.midiLog, type: .error)
            print("error getting tempo track")
            return 0
        }
    }
    
}

    
