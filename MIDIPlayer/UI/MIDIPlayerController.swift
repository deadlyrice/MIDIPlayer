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

let NoteString = ["","","","","","","","","","","","",
                  "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0",
                  "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1",
                  "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
                  "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
                  "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
                  "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
                  "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6",
                  "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7",
                  "C8"]

let NotePickerString = ["C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0",
                        "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1",
                        "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
                        "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
                        "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
                        "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
                        "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6",
                        "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7",
                        "C8"]

class MIDIPlayerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    var musicSequence:MusicSequence?
    var musicTrack:MusicTrack?
    var musicPlayer:MusicPlayer?
    var avMIDIPlayer:AVMIDIPlayer?
    var fileName:String!
    var mode:TableMode!
    var timer:Timer!
    var musicTrackList:Array<MusicTrack>!
    var noteList:Array<Note>!
    var timeResolution:UInt32!
    let textViewTitle = "Index|Note |Channel|Time |Beat |Duration\n"
    
    var musicSequenceModifiedFlag = true
    
    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var trackTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var channelTextField: UITextField!
    @IBOutlet weak var beatTimeTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    
    
    var trackPickerView:UIPickerView!
    var notePickerView:UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set picker views
        let screenSize = UIScreen.main.bounds
        trackPickerView = UIPickerView(frame: CGRect(x: screenSize.minX, y: screenSize.minY, width: screenSize.width, height: screenSize.height/3))
        trackPickerView.delegate = self
        trackPickerView.dataSource = self
        trackTextField.inputView = trackPickerView
        
        notePickerView = UIPickerView(frame: CGRect(x: screenSize.minX, y: screenSize.minY, width: screenSize.width, height: screenSize.height/3))
        notePickerView.delegate = self
        notePickerView.dataSource = self
        noteTextField.inputView = notePickerView
        notePickerView.selectRow(48, inComponent: 0, animated: false)
        noteTextField.text = NotePickerString[48]
        
        textView.isEditable = false
        textView.isScrollEnabled = true
        
        getMusicSequence()
        musicTrackList = getTrackListFromMusicSeqence(musicSequence: musicSequence!)
        if musicTrackList.isEmpty {
            return
        }
        musicTrack = musicTrackList[0]
        trackTextField.text = "Track 0"
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
        timeResolution = determineTimeResolution(musicSequence: musicSequence!)
        updateTextView()
        

  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == trackPickerView {
            return musicTrackList.count
        } else if pickerView == notePickerView {
            return NotePickerString.count
            
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == trackPickerView {
            return "Track \(row)"
        } else if pickerView == notePickerView {
            return NotePickerString[row]
            
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == trackPickerView {
            trackTextField.text = "Track \(row)"
            //self.view.endEditing(true)
            changeTrack(index: row)
        } else if pickerView == notePickerView {
            noteTextField.text = NotePickerString[row]
            
        }
    }
    
    // button action
    @IBAction func back(_ sender: UIButton) {
 
        performSegue(withIdentifier: "back", sender: self)
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        createMIDIFile(sequence: musicSequence!, fileName: fileName)
        let alert = UIAlertController(title: "\(fileName!) has been saved", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func play(_ sender: UIButton) {
        if (musicTrackList.isEmpty) {return}
        
        var cp:TimeInterval = 0
        
        if musicSequenceModifiedFlag {
            if avMIDIPlayer != nil {
                cp = avMIDIPlayer!.currentPosition
                avMIDIPlayer = nil
            }
            
            createAVMIDIPlayer(musicSequence: musicSequence!)
            if avMIDIPlayer != nil {
                let dur = avMIDIPlayer?.duration
                if cp > dur! {
                    avMIDIPlayer?.currentPosition = 0
                    cp = 0
                }
                
                timeTextField.text = "\((cp * 100).rounded(.up)/100)"
                durationLabel.text = "\((dur! * 100).rounded(.up)/100)"
            } else {
                
                return
            }
            musicSequenceModifiedFlag = false
        }
        
        if (avMIDIPlayer?.isPlaying)! {
            avMIDIPlayer?.stop()
            print("Stop")
            sender.setTitle("Play", for: .normal)
            stopTimer()
        } else  {
            avMIDIPlayer?.play(nil)
            print("play")
            sender.setTitle("Stop", for: .normal)
            startTimer()
        }
 
    }
    
    @IBAction func reset(_ sender: UIButton) {
        
        if (musicTrackList.isEmpty || avMIDIPlayer == nil) {return}
        
        avMIDIPlayer?.currentPosition = 0
        timeTextField.text = "\((avMIDIPlayer!.currentPosition*100).rounded()/100)"
    }
    
    @IBAction func deleteATrack(_ sender: UIButton) {
        print("delete a track")
        
        if musicTrackList.isEmpty {
            return
        }
        
        MusicSequenceDisposeTrack(musicSequence!, musicTrack!)
        
        musicSequenceModifiedFlag = true
        
        musicTrackList = getTrackListFromMusicSeqence(musicSequence: musicSequence!)
        if musicTrackList.isEmpty {
            timeTextField.text = ""
            durationLabel.text = ""
            textView.text = ""
            trackTextField.text = ""
            
            avMIDIPlayer = nil
            timeResolution = determineTimeResolution(musicSequence: musicSequence!)
            return
        }
        trackPickerView.reloadAllComponents()
        let row = trackPickerView.selectedRow(inComponent: 0)
        musicTrack = musicTrackList[row]
        trackTextField.text =  "Track \(row)"
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
        timeResolution = determineTimeResolution(musicSequence: musicSequence!)
        updateTextView()
        //reloadData()

    }
    
    @IBAction func addATrack(_ sender: UIButton) {
        print("add a track")
        
        var newTrack:MusicTrack?
        
        /*
        if trackPickerView == nil {
            let screenSize = UIScreen.main.bounds
            trackPickerView = UIPickerView(frame: CGRect(x: screenSize.minX, y: screenSize.minY, width: screenSize.width, height: screenSize.height/3))
            trackPickerView.delegate = self
            trackPickerView.dataSource = self
            trackTextField.inputView = trackPickerView
        }*/
        
        MusicSequenceNewTrack(musicSequence!, &newTrack)
        musicTrackList = getTrackListFromMusicSeqence(musicSequence: musicSequence!)
        trackPickerView.reloadAllComponents()
        if musicTrackList.count == 1 {
            musicTrack = musicTrackList[0]
            noteList = Array<Note>()//getNoteListFromMusicTrack(musicTrack: musicTrack!)
            updateTextView()
            trackTextField.text = "Track 0"
            //avMIDIPlayer = nil
        }
    }
    
    @IBAction func addANote(_ sender: UIButton) {
        print("Add a note")
        
        if beatTimeTextField.text == "" ||
            channelTextField.text == "" ||
            durationTextField.text == "" ||
            noteTextField.text == ""{
            return
            
        }
        
        let time = Double(beatTimeTextField.text!)!
        let channel = UInt8(channelTextField.text!)!
        let duration = Float32(durationTextField.text!)!
        let note = UInt8(NotePickerString.index(of:noteTextField.text!)!)
        
        
        insertANote(note: note, time : time, channel: channel , duration: duration)
        
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
        //createAVMIDIPlayer(musicSequence: musicSequence!)
        updateTextView()
        musicSequenceModifiedFlag = true
        //timeTextField.text = "\((avMIDIPlayer!.currentPosition * 100).rounded(.up)/100)"
        //durationLabel.text = "\((avMIDIPlayer!.duration*100).rounded(.up)/100)"
    }
    
    @IBAction func deleteANote(_ sender: UIButton) {
        print("Delete A note")
    }
    
    // timer functions
    func startTimer () {
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.01,
                                         target: self,
                                         selector: #selector(tick),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    // selector
    @objc func tick (){
        
        if musicTrackList.isEmpty || avMIDIPlayer == nil {
            
            return
        }
        
        if (avMIDIPlayer!.duration * 100).rounded(.up) <= (avMIDIPlayer!.currentPosition*100).rounded(.up) {
            print("it is the end")
            avMIDIPlayer?.currentPosition = 0
            avMIDIPlayer?.stop()
        }
        
        if avMIDIPlayer!.isPlaying{
            timeTextField.text = "\((avMIDIPlayer!.currentPosition*100).rounded(.up)/100)"
            playButton.setTitle("Stop", for: .normal)
            highlightPlayingNotesInTextView ()
            
        } else {
            
            playButton.setTitle("Play", for: .normal)
        }
    }
    
    // override
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (avMIDIPlayer == nil) {return}
        
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
            mode = .saved
            
            break
        default:
            break
        }
        
    }
    
    
    func createAVMIDIPlayer(musicSequence: MusicSequence) {
        
        // http://www.ntonyx.com/sf_f.htm
        let bankURL = Bundle.main.url(forResource: "32MbGMStereo", withExtension: "sf2")
        
        var status = noErr
        var data: Unmanaged<CFData>?
        
        timeResolution = determineTimeResolution(musicSequence: musicSequence)
        
        status = MusicSequenceFileCreateData (musicSequence,
                                              .midiType,
                                              .eraseFile,
                                              Int16(timeResolution),
                                              &data)
        
        if status != noErr {
            CheckError(status)
        }
        
        if let md = data {
            let midiData = md.takeUnretainedValue() as Data
            do {
                try self.avMIDIPlayer = AVMIDIPlayer(data: midiData as Data, soundBankURL: bankURL)
                
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
        
        var time = MusicTimeStamp(1.0)
        
        insertANote(note: Notes.C4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.D4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.E4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.F4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.G4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.A4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.B4.rawValue, time: time)
        time+=1
        
        insertANote(note: Notes.C5.rawValue, time: time)
        time+=1
        
        
    }
    
    func insertANote(note:UInt8,
                     time:MusicTimeStamp,
                     channel:UInt8 = 0,
                     velocity:UInt8 = 100,
                     releaseVelocity:UInt8 = 0,
                     duration:Float32 = 1.0){
        
        if musicTrack == nil {return}
        
        var note = MIDINoteMessage(channel: channel,
                                   note: note,
                                   velocity: velocity,
                                   releaseVelocity: releaseVelocity,
                                   duration: duration )
        MusicTrackNewMIDINoteEvent(musicTrack!, time, &note)
    }
    
    func updateTextView () {
        
        textView.text = ""
        textView.insertText(textViewTitle)
        
        for (index,note) in noteList.enumerated() {
            var indexString = "\(index)".prefix(5)
            indexString += String(repeating: " ", count: (5 - indexString.count))
            
            var noteString = NoteString[Int(note.noteInfo.note)].prefix(5)
            noteString += String(repeating: " ", count: (5 - noteString.count))
            
            var channelString = "\(note.noteInfo.channel)".prefix(7)
            channelString += String(repeating: " ", count: (7 - channelString.count))
            
            var timeString = "\(convertBeatToTime(inSequence: musicSequence!,inBeat: note.time!))".prefix(5)
            timeString += String(repeating: " ", count: (5 - timeString.count))
            
            var beatString = "\(note.time!)".prefix(5)
            beatString += String(repeating: " ", count: (5 - beatString.count))
            
            var durationString = "\(note.noteInfo.duration)".prefix(7)
            durationString += String(repeating: " ", count: (7 - durationString.count))
            
            //var releaseVelocityString = "\(note.noteInfo.releaseVelocity)".prefix(5)
            //releaseVelocityString += String(repeating: " ", count: (5 - releaseVelocityString.count))
            
            //var velocityString = "\(note.noteInfo.velocity)".prefix(5)
            //velocityString += String(repeating: " ", count: (5 - velocityString.count))
            
            //textView.insertText("\(indexString) \(noteString) \(channelString) \(timeString) \(durationString) \(releaseVelocityString) \(velocityString)\n")
            
            textView.insertText("\(indexString) \(noteString) \(channelString) \(timeString) \(beatString) \(durationString) \n")
        }
        
    }
    
    func highlightPlayingNotesInTextView () {
        
        if avMIDIPlayer == nil {return}
        
        if avMIDIPlayer!.isPlaying {
            var highlightLine = Array<Int>()
            
            let currentPosition = convertTimeToBeat(inSequence: musicSequence!, inSeconds: avMIDIPlayer!.currentPosition)
            
            for (index,note) in noteList.enumerated() {
                if !((Double(note.noteInfo.duration) + note.time) <  currentPosition) &&
                    !(note.time > currentPosition) {
                    
                    highlightLine.append(index)

                } else if !highlightLine.isEmpty {
                    
                    break
                }
                
            }
            
            if highlightLine.isEmpty {return}
            
            let startPosition = (1 + highlightLine.first!) * (textViewTitle.count )
            let length = (highlightLine.last! - highlightLine.first! + 1) * (textViewTitle.count)
            
            textView.selectedRange = NSMakeRange(startPosition , length)
            textView.scrollRangeToVisible(NSMakeRange(startPosition, (textViewTitle.count * 10)))
   
            let attributedString = NSMutableAttributedString(string: textView.text)
            attributedString.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.red, range: textView.selectedRange)
            textView.attributedText = attributedString
            textView.font = UIFont(name: "Courier new", size: 12)
        }
        
    }
    
    func changeTrack (index:Int) {
        print("Change Track to Track \(index)")
        musicTrack = musicTrackList[index]
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
        updateTextView()
    }
    
    func reloadData(){
        
        musicTrackList = getTrackListFromMusicSeqence(musicSequence: musicSequence!)
        if musicTrackList.isEmpty {
            timeTextField.text = ""
            durationLabel.text = ""
            textView.text = ""
            trackTextField.text = ""
            
            avMIDIPlayer = nil
            timeResolution = determineTimeResolution(musicSequence: musicSequence!)
            createAVMIDIPlayer(musicSequence: musicSequence!)
            //print(avMIDIPlayer?.duration)
            return
        }
        trackPickerView.reloadAllComponents()
        
        if musicTrack == nil {
            musicTrack = musicTrackList[0]
            trackTextField.text = "Track 0"
        } else {
            let row = trackPickerView.selectedRow(inComponent: 0)
            musicTrack = musicTrackList[row]
            trackTextField.text =  "Track \(row)"
        }
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
        timeResolution = determineTimeResolution(musicSequence: musicSequence!)
        updateTextView()
        
        
    }
    
}
