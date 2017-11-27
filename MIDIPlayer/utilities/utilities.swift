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

func getSequenceFromASampleFile(fileName:String) -> MusicSequence {
    
    var musicSequence:MusicSequence?
    NewMusicSequence(&musicSequence)
    
    if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "mid"){
        MusicSequenceFileLoad(musicSequence!, fileURL as CFURL, MusicSequenceFileTypeID.midiType, MusicSequenceLoadFlags.smf_ChannelsToTracks)
    }
    return musicSequence!
    
}
