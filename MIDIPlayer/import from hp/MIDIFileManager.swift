//
//  FileManager.swift
//  honours project
//
//  Created by Yulun Wu on 2017-11-27.
//  Copyright © 2017 Yulun Wu. All rights reserved.
//

import Foundation

class MIDIFileManager {
    var midiFileList:Array<File>!
    
    init () {
        midiFileList = Array<File>()
        extractAllMIDIFiles()
        print(midiFileList)
    }
    
    func extractAllMIDIFiles() {
        
        midiFileList.removeAll()
        
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
                    
                    let f = File(name: pathURL.pathComponents.last!)
                    f.path = pathURL
                    midiFileList.append(f)
                }
            }
        }
    }
    
    
}


