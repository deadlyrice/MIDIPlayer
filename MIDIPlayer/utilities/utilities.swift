//
//  utilities.swift
//  MIDIPlayer
//
//  Created by Yulun Wu on 2017-11-27.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation
import AudioToolbox

func getSampleList() -> Array<String> {
    var sampleList = [String]()
    
    let folderURL = URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true)
    let fileManager = FileManager.default
    let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
    let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]
    let enumerator = fileManager.enumerator(
        at: folderURL,
        includingPropertiesForKeys: keys,
        options: options,
        errorHandler: {(url, error) -> Bool in
            return true
    })
    
    if enumerator != nil {
        while let file = enumerator!.nextObject() {
            let pathURL = URL(fileURLWithPath: (file as! URL).absoluteString, relativeTo: folderURL)
            if pathURL.path.hasSuffix(".mid"){
                sampleList.append(pathURL.pathComponents.last!)
            }
        }
    }
    return sampleList
}

func getSavedList() -> Array<String> {
    var savedList = [String]()
    
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let folderURL = URL(fileURLWithPath: documentsDirectory, isDirectory: true)
    let fileManager = FileManager.default
    let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
    let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]
    let enumerator = fileManager.enumerator(
        at: folderURL,
        includingPropertiesForKeys: keys,
        options: options,
        errorHandler: {(url, error) -> Bool in
            return true
    })
    
    if enumerator != nil {
        while let file = enumerator!.nextObject() {
            let pathURL = URL(fileURLWithPath: (file as! URL).absoluteString, relativeTo: folderURL)
            if pathURL.path.hasSuffix(".mid"){
                savedList.append(pathURL.pathComponents.last!)
            }
        }
    }
    
    return savedList
    
}

func getSequenceFromASampleFile(fileName:String) -> MusicSequence {
    
    var musicSequence:MusicSequence?
    NewMusicSequence(&musicSequence)
    
    var name = fileName
    if !name.hasSuffix(".mid"){
        name.append(".mid")
    }
    
    if let fileURL = Bundle.main.url(forResource: name, withExtension: nil){
        
        //print(fileURL)
        MusicSequenceFileLoad(musicSequence!,
                              fileURL as CFURL,
                              .midiType,
                              .smf_ChannelsToTracks)
    }
    return musicSequence!
    
}

func getSequenceFromASavedFile(fileName:String) -> MusicSequence {
    
    var musicSequence:MusicSequence?
    NewMusicSequence(&musicSequence)
    
    var name = fileName
    if !name.hasSuffix(".mid"){
        name.append(".mid")
    }
    
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    if let fileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(name) {
        //print(fileURL)
        MusicSequenceFileLoad(musicSequence!,
                              fileURL as CFURL,
                              .midiType,
                              .smf_ChannelsToTracks)
    }
    return musicSequence!
    
}

func createMIDIFile(sequence:MusicSequence, fileName:String)  {
    
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    var name = fileName
    if !name.hasSuffix(".mid"){
        name.append(".mid")
    }
    
    if let fileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(name) {
        
        //print("creating midi file at \(fileURL)")
        
        let timeResolution = determineTimeResolution(musicSequence: sequence)
        let status = MusicSequenceFileCreate(sequence, fileURL as CFURL, .midiType, [.eraseFile], Int16(timeResolution))
        if status != noErr {
            CheckError(status)
        }
    }
}

func deleteAFile(fileName:String) {
    
    let fileManager = FileManager.default
    
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    if let fileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName) {
        print("delete \(fileURL)")
        do {
            try fileManager.removeItem(at: fileURL)
        } catch let e as NSError {
            print("error: \(e)")
            
        }
    }
    
    
}

func renameAFile(fileName:String, newName:String) {
    
    let fileManager = FileManager.default
    
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    if let fileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName) {
        
        var name = newName
        if !name.hasSuffix(".mid"){
            name.append(".mid")
        }
        
        print("rename \(fileName) to \(name)")
        
        
        if let newFileURL = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(name){
            do {
                try fileManager.moveItem(at: fileURL, to: newFileURL)
            } catch let e as NSError {
                print("error: \(e)")
            
            }
        }
    }
    
    
}


func determineTimeResolution(musicSequence:MusicSequence) -> UInt32 {
    var track:MusicTrack?
    var status = MusicSequenceGetTempoTrack(musicSequence, &track)
    
    if let tempoTrack = track {
        var propertyLength = UInt32(0)
        
        var timeResolution = UInt32(0)
        status = MusicTrackGetProperty(tempoTrack,
                                       kSequenceTrackProperty_TimeResolution,
                                       &timeResolution,
                                       &propertyLength)
        
        if status != noErr {
            CheckError(status)
            
        }
        
        return timeResolution
    } else {
        print("error getting tempo track")
        return 0
    }
}

func getTrackListFromMusicSeqence(musicSequence: MusicSequence) -> Array<MusicTrack> {
    var musicTrackList = Array<MusicTrack>()
    
    for i:UInt32 in 0...1000 {
        var musicTrack:MusicTrack?
        MusicSequenceGetIndTrack(musicSequence, i, &musicTrack)
        
        if (musicTrack == nil){
            
            break
        } else {
            musicTrackList.append(musicTrack!)
            
        }
        
    }
    
    //print("There are \(musicTrackList.count) music tracks")
    
    return musicTrackList
}

func getNoteListFromMusicTrack(musicTrack:MusicTrack) -> Array<Note> {
    var noteList = Array<Note>()
    
    var hasCurrentEvent:DarwinBoolean = DarwinBoolean.init(true)
    var musicEventIterator:MusicEventIterator?
    var musicEventType:MusicEventType = 0
    var musicTimeStamp:MusicTimeStamp = 0.0
    var musicEventDataRef:UnsafeRawPointer?
    var eventDataSize:UInt32 = 0
    
    NewMusicEventIterator(musicTrack, &musicEventIterator)
    MusicEventIteratorHasCurrentEvent (musicEventIterator!, &hasCurrentEvent);
    
    while (hasCurrentEvent).boolValue {
        // do work here
        MusicEventIteratorGetEventInfo(musicEventIterator!, &musicTimeStamp, &musicEventType, &musicEventDataRef, &eventDataSize)
        
        if musicEventType == kMusicEventType_MIDINoteMessage {
            let eventData = musicEventDataRef!.load(as: MIDINoteMessage.self)
            let note = Note(noteInfo: eventData, time: musicTimeStamp)
            noteList.append(note)
            
        }
        MusicEventIteratorNextEvent (musicEventIterator!);
        MusicEventIteratorHasCurrentEvent (musicEventIterator!, &hasCurrentEvent);
    }
    
    return noteList
}

func getTempoTrack (musicSequence:MusicSequence) -> MusicTrack? {
    var tempoTrack:MusicTrack?
        
    MusicSequenceGetTempoTrack(musicSequence, &tempoTrack)
    
    return tempoTrack
    
}

func convertBeatToTime(inSequence:MusicSequence,inBeat:MusicTimeStamp) -> Float64 {
    
    var outSeconds:Float64 = 0
    
    MusicSequenceGetSecondsForBeats(inSequence, inBeat, &outSeconds)
    return outSeconds
}

func convertTimeToBeat(inSequence:MusicSequence,inSeconds: Float64) -> MusicTimeStamp {
    
    var outBeat:MusicTimeStamp = 0
    
    MusicSequenceGetBeatsForSeconds(inSequence, inSeconds, &outBeat)
    return outBeat
}
