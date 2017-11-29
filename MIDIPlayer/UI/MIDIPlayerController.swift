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
import AVFoundation

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

class MIDIPlayerController: UIViewController {
    
    var musicSequence:MusicSequence?
    var musicTrack:MusicTrack?
    var musicPlayer:MusicPlayer?
    var avMIDIPlayer:AVMIDIPlayer?
    var fileName:String!
    var mode:TableMode!
    var timer:Timer!
    
    @IBOutlet weak var timeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMusicSequence()
        
        createAVMIDIPlayer(musicSequence: musicSequence!)
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // button action
    @IBAction func back(_ sender: UIButton) {
 
        performSegue(withIdentifier: "back", sender: self)
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        createMIDIFile(sequence: musicSequence!, fileName: fileName)
    }
    
    @IBAction func play(_ sender: UIButton) {
        
        
        if (avMIDIPlayer?.isPlaying)! {
            avMIDIPlayer?.stop()
            sender.titleLabel?.text = "play"
            sender.setTitle("play", for: .normal)
        } else {
            
            avMIDIPlayer?.play({ () -> Void in
                print("finished")
                //self.avMIDIPlayer?.currentPosition = 0
            })
            sender.setTitle("stop", for: .normal)
        }
 
    }
    
    @IBAction func reset(_ sender: UIButton) {
        
        avMIDIPlayer?.currentPosition = 0
    }
    
    // selector
    @objc func tick (){
        timeTextField.text = "\((avMIDIPlayer!.currentPosition*100).rounded()/100)"
    }
    
    // override
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (avMIDIPlayer?.isPlaying)! {
            avMIDIPlayer?.stop()
        }
    }
    
    
    
    // functions
    func getMusicSequence () {
        switch mode {
        case .samples:
            musicSequence = getSequenceFromASampleFile(fileName: fileName)
            MusicSequenceGetIndTrack(musicSequence!, 0, &musicTrack)
            break
        case .main:
            break
        case .saved:
            musicSequence = getSequenceFromASavedFile(fileName: fileName)
            MusicSequenceGetIndTrack(musicSequence!, 0, &musicTrack)
            break
        case .create:
            NewMusicSequence(&musicSequence)
            MusicSequenceNewTrack(musicSequence!, &musicTrack)
            createATestingMIDIFile()
            
            break
        default:
            break
        }
        
    }
    
    
    func createAVMIDIPlayer(musicSequence: MusicSequence) {
        
        //let bankURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2")
        
        // http://www.ntonyx.com/sf_f.htm
        let bankURL = Bundle.main.url(forResource: "32MbGMStereo", withExtension: "sf2")
        
        var status = noErr
        var data: Unmanaged<CFData>?
        
        let resolution = determineTimeResolution(musicSequence: musicSequence)
        print(resolution)
        
        status = MusicSequenceFileCreateData (musicSequence,
                                              .midiType,
                                              .eraseFile,
                                              Int16(resolution), &data)
        
        if status != noErr {
            CheckError(status)
        }
        
        if let md = data {
            let midiData = md.takeUnretainedValue() as Data
            do {
                try self.avMIDIPlayer = AVMIDIPlayer(data: midiData as Data, soundBankURL: bankURL)
                //print("created midi player with sound bank url \(bankURL)")
            } catch let error as NSError {
                print("nil midi player")
                print("Error \(error.localizedDescription)")
            }
            data?.release()
            
            self.avMIDIPlayer?.prepareToPlay()
        }
        
    }
    
    
    func createAVMIDIPlayerFromMIDIFIle() {
        
        let midiFileURL = Bundle.main.url(forResource: fileName, withExtension: nil)
        
        let bankURL = Bundle.main.url(forResource: "32MbGMStereo", withExtension: "sf2")
        
        do {
            try self.avMIDIPlayer = AVMIDIPlayer(contentsOf: midiFileURL!, soundBankURL: bankURL)
            //print("created midi player with sound bank url \(bankURL)")
        } catch let error {
            print("Error \(error.localizedDescription)")
        }
        
        self.avMIDIPlayer?.prepareToPlay()
    }
    
    func createATestingMIDIFile(){
        
        var time = MusicTimeStamp(2.0)
        
        insertANote(note: Notes.C4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.D4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.E4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.F4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.G4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.A4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.B4.rawValue, time: time, duration:1)
        time+=1
        
        insertANote(note: Notes.C5.rawValue, time: time)
        time+=1
        
        
    }
    
    func insertANote(note:UInt8, time:MusicTimeStamp, channel:UInt8 = 0, velocity:UInt8 = 60, releaseVelocity:UInt8 = 0, duration:Float32 = 1.0){
        var note = MIDINoteMessage(channel: channel,
                                   note: note,
                                   velocity: velocity,
                                   releaseVelocity: releaseVelocity,
                                   duration: duration )
        MusicTrackNewMIDINoteEvent(musicTrack!, time, &note)
    }
    
}
