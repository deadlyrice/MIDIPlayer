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
    var mode = TableMode.main
    var timer:Timer!
    var musicTrackList:Array<MusicTrack>!
    var noteList:Array<Note>!
    var timeResolution:UInt32!
    let textViewTitle = "Index|Note |Channel|Time |Beat |Duration\n"
    var musicSequenceModifiedFlag = true
    var instrumentList:Array<Instrument>!

    // Redesigned UI: piano-roll visualization + tappable keyboard.
    var pianoRoll: PianoRollView!
    var keyboard: PianoKeyboardView!
    var auditionEngine: AVAudioEngine?
    var auditionSampler: AVAudioUnitSampler?

    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var trackTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var beatTimeTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var noteIndexTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addATrackButton: UIButton!
    @IBOutlet weak var deleteATrackButton: UIButton!
    @IBOutlet weak var addANoteButton: UIButton!
    @IBOutlet weak var deleteANoteButton: UIButton!
    @IBOutlet weak var instrumentTextField: UITextField!
    @IBOutlet weak var changeInstrumentButton: UIButton!
    @IBOutlet weak var loopLabel: UILabel!
    
    var trackPickerView:UIPickerView!
    var notePickerView:UIPickerView!
    var instrumentPickerView:UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModernUI()
        instrumentList = getInstrumentList()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
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
        instrumentPickerView = UIPickerView(frame: CGRect(x: screenSize.minX, y: screenSize.minY, width: screenSize.width, height: screenSize.height/3))
        instrumentPickerView.delegate = self
        instrumentPickerView.dataSource = self
        instrumentTextField.inputView = instrumentPickerView
        instrumentPickerView.selectRow(0, inComponent: 0, animated: false)
        instrumentTextField.text = instrumentList[0].name
        textView.isEditable = false
        textView.isScrollEnabled = true
        enableButtonsAfterStop()
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

    // MARK: - Redesigned UI

    func setupModernUI() {
        view.backgroundColor = Theme.background
        let originalSubviews = view.subviews   // to hide leftovers later

        // Visualization views
        pianoRoll = PianoRollView(); pianoRoll.translatesAutoresizingMaskIntoConstraints = false
        keyboard = PianoKeyboardView(); keyboard.translatesAutoresizingMaskIntoConstraints = false
        keyboard.onKeyTapped = { [weak self] name in self?.selectNoteFromKeyboard(name) }

        // New buttons for storyboard actions that have no outlet
        let resetButton = makeActionButton("Reset", #selector(reset(_:)))
        let loopBtn     = makeActionButton("Loop",  #selector(loopButton(_:)))
        let backBtn     = makeActionButton("Back",  #selector(back(_:)))
        let saveBtn     = makeActionButton("Save",  #selector(save(_:)))

        // Style the reused (outlet-backed) controls
        Theme.stylePrimary(playButton)
        for b in [addATrackButton, deleteATrackButton, changeInstrumentButton, addANoteButton, deleteANoteButton] {
            guard let b = b else { continue }
            let isDelete = (b.currentTitle ?? "").lowercased().contains("delete")
            Theme.styleSecondary(b, color: isDelete ? Theme.danger : Theme.accent)
        }
        for tf in [timeTextField, trackTextField, instrumentTextField, noteTextField, beatTimeTextField, durationTextField, noteIndexTextField] {
            guard let tf = tf else { continue }
            stripSizeConstraints(tf); Theme.styleTextField(tf)
            tf.heightAnchor.constraint(equalToConstant: 38).isActive = true
        }
        loopLabel.text = loopLabel.text ?? "True"
        loopLabel.textColor = Theme.accent
        loopLabel.font = Theme.rounded(14, .semibold)
        durationLabel.textColor = Theme.textMuted
        durationLabel.font = Theme.rounded(14, .semibold)
        [playButton, resetButton, loopBtn, backBtn, saveBtn, addATrackButton, deleteATrackButton,
         changeInstrumentButton, addANoteButton, deleteANoteButton].forEach { $0.map { stripSizeConstraints($0) } }

        // --- Assemble layout ---
        timeTextField.widthAnchor.constraint(equalToConstant: 52).isActive = true
        let transport = hRow([playButton, resetButton, loopBtn, loopLabel, spacerView(),
                              timeTextField, sectionLabel("/"), durationLabel], spacing: 8, fill: false)

        let trackFields = hRow([trackTextField, instrumentTextField], spacing: 10, fill: true)
        let trackButtons = hRow([addATrackButton, deleteATrackButton, changeInstrumentButton], spacing: 8, fill: true)
        let trackCard = card(vStack([sectionLabel("TRACK", header: true), trackFields, trackButtons]))

        let noteHeaders = hRow([sectionLabel("Note"), sectionLabel("Beat"), sectionLabel("Dur"), sectionLabel("Idx")], spacing: 6, fill: true)
        let noteFields = hRow([noteTextField, beatTimeTextField, durationTextField, noteIndexTextField], spacing: 6, fill: true)
        let noteButtons = hRow([addANoteButton, deleteANoteButton], spacing: 8, fill: true)
        let noteCard = card(vStack([sectionLabel("ADD / EDIT NOTE", header: true), noteHeaders, noteFields, noteButtons, keyboard]))

        let bottom = hRow([backBtn, saveBtn], spacing: 8, fill: true)

        let root = vStack([card(transport), trackCard, pianoRoll, noteCard, bottom])
        root.spacing = 12
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            root.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -8),
            pianoRoll.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            keyboard.heightAnchor.constraint(equalToConstant: 92),
        ])
        pianoRoll.setContentHuggingPriority(.defaultLow, for: .vertical)
        pianoRoll.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        // Hide the leftover storyboard controls we didn't reuse.
        for v in originalSubviews where v.superview === view && (v is UIButton || v is UILabel) {
            v.isHidden = true
        }
        textView.isHidden = true

        setupAudition()
    }

    // MARK: Layout helpers

    private func stripSizeConstraints(_ v: UIView) {
        let bad = v.constraints.filter {
            ($0.firstItem as? UIView) === v && $0.secondItem == nil &&
            ($0.firstAttribute == .width || $0.firstAttribute == .height)
        }
        v.removeConstraints(bad)
    }

    private func makeActionButton(_ title: String, _ action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.addTarget(self, action: action, for: .touchUpInside)
        let isDelete = title.lowercased().contains("delete")
        Theme.styleSecondary(b, color: isDelete ? Theme.danger : Theme.accent)
        return b
    }

    private func spacerView() -> UIView {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return v
    }

    private func sectionLabel(_ text: String, header: Bool = false) -> UILabel {
        let l = UILabel()
        l.text = text
        l.textColor = header ? Theme.textMuted : Theme.textMuted
        l.font = header ? Theme.rounded(12, .bold) : Theme.rounded(13, .semibold)
        l.textAlignment = header ? .left : .center
        if header { l.text = text }   // keep section text as-is
        return l
    }

    private func hRow(_ views: [UIView], spacing: CGFloat, fill: Bool = false) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .horizontal
        s.spacing = spacing
        s.alignment = .center
        s.distribution = fill ? .fillEqually : .fill
        return s
    }

    private func vStack(_ views: [UIView]) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .vertical
        s.spacing = 10
        s.alignment = .fill
        return s
    }

    private func card(_ content: UIView) -> UIView {
        let c = UIView()
        Theme.styleCard(c)
        content.translatesAutoresizingMaskIntoConstraints = false
        c.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -14),
            content.topAnchor.constraint(equalTo: c.topAnchor, constant: 12),
            content.bottomAnchor.constraint(equalTo: c.bottomAnchor, constant: -12),
        ])
        return c
    }

    // MARK: Keyboard note entry + audition

    private func selectNoteFromKeyboard(_ name: String) {
        noteTextField.text = name
        if let row = NotePickerString.firstIndex(of: name) {
            notePickerView?.selectRow(row, inComponent: 0, animated: true)
            audition(pitch: row)
        }
    }

    private func setupAudition() {
        guard let url = Bundle.main.url(forResource: "GeneralUserGS", withExtension: "sf2") else { return }
        let engine = AVAudioEngine()
        let sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        do {
            try engine.start()
            try sampler.loadSoundBankInstrument(at: url, program: 0,
                                                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                bankLSB: UInt8(kAUSampler_DefaultBankLSB))
            auditionEngine = engine
            auditionSampler = sampler
        } catch {
            print("Audition setup failed: \(error.localizedDescription)")
        }
    }

    private func audition(pitch: Int) {
        guard let sampler = auditionSampler, pitch >= 0, pitch <= 127 else { return }
        let note = UInt8(pitch)
        sampler.startNote(note, withVelocity: 96, onChannel: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sampler.stopNote(note, onChannel: 0)
        }
    }

    func refreshPianoRoll() {
        guard pianoRoll != nil else { return }
        let list = noteList ?? []
        pianoRoll.notes = list.map {
            RollNote(pitch: Int($0.noteInfo.note),
                     start: Double($0.time),
                     duration: Double($0.noteInfo.duration))
        }
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
        } else if pickerView == instrumentPickerView {
            return instrumentList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == trackPickerView {
            return "Track \(row)"
        } else if pickerView == notePickerView {
            return NotePickerString[row]
        } else if pickerView == instrumentPickerView {
            return instrumentList[row].name
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == trackPickerView {
            trackTextField.text = "Track \(row)"
            changeTrack(index: row)
        } else if pickerView == notePickerView {
            noteTextField.text = NotePickerString[row]
        } else if pickerView == instrumentPickerView {
            instrumentTextField.text = instrumentList[row].name
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
            enableButtonsAfterStop()
            pianoRoll?.isPlaying = false
        } else  {
            if timeTextField.text != "" {
                if let t = Double(timeTextField.text!){
                    if t >= 0 && t < (avMIDIPlayer?.duration)! {
                        avMIDIPlayer?.currentPosition = t
                    } else {
                        avMIDIPlayer?.currentPosition = 0
                    }
                }
            }
            if isTheEnd() {
                avMIDIPlayer?.currentPosition = 0.0
            }
            avMIDIPlayer?.play({() in
                DispatchQueue.main.async {
                    if self.loopLabel.text == "True" && (self.isTheEnd()) {
                        self.avMIDIPlayer?.currentPosition = 0;
                        self.play(sender);
                    } else  {
                        sender.setTitle("Play", for: .normal)
                        self.enableButtonsAfterStop()
                        self.pianoRoll?.isPlaying = false
                    }
                }
            })
            print("play")
            sender.setTitle("Stop", for: .normal)
            startTimer()
            disableButtonsWhilePlaying()
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        if (musicTrackList.isEmpty || avMIDIPlayer == nil) {return}
        avMIDIPlayer?.currentPosition = 0
        timeTextField.text = "\((avMIDIPlayer!.currentPosition*100).rounded()/100)"
        pianoRoll?.currentBeat = 0
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
    }
    
    @IBAction func addATrack(_ sender: UIButton) {
        addATrack()
    }
    
    func addATrack(){
        print("add a track")
        if musicTrackList.count >= 64 {return}
        var newTrack:MusicTrack?
        MusicSequenceNewTrack(musicSequence!, &newTrack)
        musicTrackList = getTrackListFromMusicSeqence(musicSequence: musicSequence!)
        trackPickerView.reloadAllComponents()
        var i:UInt32 = 100
        MusicSequenceGetTrackIndex(musicSequence!, newTrack!, &i)
        if musicTrackList.count == 1 {
            musicTrack = musicTrackList[0]
            noteList = Array<Note>()
            updateTextView()
            trackTextField.text = "Track 0"
        }
    }
    
    @IBAction func addANote(_ sender: UIButton) {
        print("Add a note")
        if beatTimeTextField.text == "" ||
            durationTextField.text == "" ||
            noteTextField.text == ""{
            return
        }
        if (musicTrack == nil || musicTrackList == nil) {addATrack()}
        let time = Double(beatTimeTextField.text!)!
        let duration = Float32(durationTextField.text!)!
        let note = UInt8(NotePickerString.index(of:noteTextField.text!)!)
        let chan = UInt8(trackPickerView.selectedRow(inComponent: 0))
        insertANote(note: note + 12, time : time ,channel: chan, duration: duration)
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
        updateTextView()
        beatTimeTextField.text = "\(time + 1)"
        musicSequenceModifiedFlag = true
    }
    
    @IBAction func deleteANote(_ sender: UIButton) {
        print("Delete A note")
        if self.musicTrackList==nil || musicTrack==nil ||
            noteList.isEmpty || musicTrackList.isEmpty ||
            noteIndexTextField.text == "" {
            return
        }
        if let index = Int(noteIndexTextField.text!){
            deleteANoteAt(index: index)
            updateTextView()
            musicSequenceModifiedFlag = true
        }
    }
    
//    Voice Message           Status Byte      Data Byte1          Data Byte2
//    -------------           -----------   -----------------   -----------------
//    Note off                      8x      Key number          Note Off velocity
//    Note on                       9x      Key number          Note on velocity
//    Polyphonic Key Pressure       Ax      Key number          Amount of pressure
//    Control Change                Bx      Controller number   Controller value
//    Program Change                Cx      Program number      None
//    Channel Pressure              Dx      Pressure value      None
//    Pitch Bend                    Ex      MSB                 LSB
    
    // Before changeing instrument, we first need to set MSB to 0 and LSB to 32
    // Using Bx to change MSB and LSB
    // Using Cx to change program
    // Check out this link for control change message: https://www.midi.org/specifications/item/table-3-control-change-messages-data-bytes-2
    @IBAction func changeInstrument(_ sender: UIButton) {
        if instrumentTextField.text == nil {return}
        if musicTrackList.isEmpty {return}
        let index = instrumentPickerView.selectedRow(inComponent: 0)
        let instrument = instrumentList[index]
        MusicSequenceGetIndTrack(musicSequence!, UInt32(trackPickerView.selectedRow(inComponent: 0)), &musicTrack)
        // set MSB to 0x00
        var status = UInt8(0xB0 + trackPickerView.selectedRow(inComponent: 0))
        var inMessage = MIDIChannelMessage(status: status, data1: UInt8(instrument.MSB), data2: 0x00, reserved: 0)
        MusicTrackNewMIDIChannelEvent(musicTrack!, 0, &inMessage)
        // set LSB to 0x20
        status = UInt8(0xB0 + trackPickerView.selectedRow(inComponent: 0))
        inMessage = MIDIChannelMessage(status: status, data1: UInt8(instrument.LSB), data2: 0x20, reserved: 0)
        MusicTrackNewMIDIChannelEvent(musicTrack!, 0, &inMessage)
        // change program
        status = UInt8(0xC0 + trackPickerView.selectedRow(inComponent: 0))
        inMessage = MIDIChannelMessage(status: status, data1: UInt8(instrument.program), data2: 0, reserved: 0)
        MusicTrackNewMIDIChannelEvent(musicTrack!, 0, &inMessage)
        print("change instrument")
        musicSequenceModifiedFlag = true
    }
    
    @IBAction func loopButton(_ sender: UIButton) {
        let loopLabelText = loopLabel.text;
        if loopLabelText == "True" {
            loopLabel.text = "False"
        } else {
            loopLabel.text = "True"
        }
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
        if avMIDIPlayer!.isPlaying{
            timeTextField.text = "\((avMIDIPlayer!.currentPosition*100).rounded(.up)/100)"
            highlightPlayingNotesInTextView ()
            pianoRoll?.isPlaying = true
            pianoRoll?.currentBeat = convertTimeToBeat(inSequence: musicSequence!, inSeconds: avMIDIPlayer!.currentPosition)
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
            mode = .saved
            break
        default:
            break
        }
    }
    
    func createAVMIDIPlayer(musicSequence: MusicSequence) {
        // http://www.ntonyx.com/sf_f.htm
        let bankURL = Bundle.main.url(forResource: "GeneralUserGS", withExtension: "sf2")
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
                print("Error \(error.localizedDescription)")
            }
            data?.release()
            self.avMIDIPlayer?.prepareToPlay()
        }
    }
    
    func createAVMIDIPlayerFromMIDIFIle() {
        let midiFileURL = Bundle.main.url(forResource: fileName, withExtension: nil)
        let bankURL = Bundle.main.url(forResource: "GeneralUserGS", withExtension: "sf2")
        do {
            try self.avMIDIPlayer = AVMIDIPlayer(contentsOf: midiFileURL!, soundBankURL: bankURL)
        } catch let error {
            print("Error \(error.localizedDescription)")
        }
        self.avMIDIPlayer?.prepareToPlay()
    }
    
    func createATestingMIDIFile(){
        var time = MusicTimeStamp(1.0)
        for i:UInt8 in 0...24 {
            insertANote(note: Notes.C4.rawValue + i, time: time)
            time+=1
        }
        /*
        insertANote(note: Notes.C4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.D4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.E4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.F4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.G4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.A4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.B4.rawValue, time: time, duration:5)
        time+=1
        
        insertANote(note: Notes.C5.rawValue, time: time, duration:5)
        time+=1
        */
        //MusicTrackClear(musicTrack!, 3, 3.5)
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
    
    func deleteANoteAt(index:Int){
        if index >= noteList.count {
            return
        }
        let beatTime = noteList[index].time!
        var tempNoteList = Array<Note>()
        for (i,note) in noteList.enumerated() {
            if note.time >= beatTime && note.time < beatTime + 0.1 && i != index {
                tempNoteList.append(note)
            } else if note.time > beatTime + 0.1 {
                break
            }
        }
        MusicTrackClear(musicTrack!, beatTime, beatTime + 0.1)
        for note in tempNoteList {
            insertANote(note:note.noteInfo.note,
                        time:note.time,
                        channel:note.noteInfo.channel,
                        velocity:note.noteInfo.velocity,
                        releaseVelocity:note.noteInfo.releaseVelocity,
                        duration:note.noteInfo.duration)
        }
        noteList = getNoteListFromMusicTrack(musicTrack: musicTrack!)
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
        refreshPianoRoll()
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
                }
            }
            if highlightLine.isEmpty {return}
            let startPosition = (1 + highlightLine.first!) * (textViewTitle.count )
            let length = (highlightLine.last! - highlightLine.first! + 1) * (textViewTitle.count)
            textView.selectedRange = NSMakeRange(startPosition , length)
            textView.scrollRangeToVisible(NSMakeRange(startPosition, (textViewTitle.count * 10)))
            let attributedString = NSMutableAttributedString(string: textView.text)
            attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.red, range: textView.selectedRange)
            textView.attributedText = attributedString
            textView.font = UIFont(name: "Courier new", size: 12)
        }
    }
    
    func changeTrack (index:Int) {
        print("Change Track to Track \(index)")
        MusicSequenceGetIndTrack(musicSequence!, UInt32(index), &musicTrack)
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
    
    func disableButtonsWhilePlaying () {
        addATrackButton.isEnabled = false
        deleteATrackButton.isEnabled = false
        addANoteButton.isEnabled = false
        deleteANoteButton.isEnabled = false
        changeInstrumentButton.isEnabled = false
    }
    
    func enableButtonsAfterStop () {
        addATrackButton.isEnabled = true
        deleteATrackButton.isEnabled = true
        addANoteButton.isEnabled = true
        deleteANoteButton.isEnabled = true
        changeInstrumentButton.isEnabled = true
    }
    
    func isTheEnd()->Bool {
        if avMIDIPlayer == nil {return false}
        let cPosition = avMIDIPlayer!.currentPosition.rounded(.up)
        let duration = avMIDIPlayer!.duration.rounded(.up)
        return cPosition >= duration
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
