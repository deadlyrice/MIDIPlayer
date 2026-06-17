//
//  PianoRollView.swift
//  MIDIPlayer
//
//  A lightweight piano-roll visualization of a track's notes.
//  Vertical axis = pitch (with a piano keyboard down the left edge),
//  horizontal axis = time (beats). A playhead sweeps during playback.
//

import UIKit

struct RollNote {
    let pitch: Int       // MIDI note number (60 = C4 in this app's convention: 12 = C0)
    let start: Double    // start time in beats
    let duration: Double // duration in beats
}

class PianoRollView: UIView {

    var notes: [RollNote] = [] {
        didSet { recomputeRanges(); setNeedsDisplay() }
    }

    /// Current playback position in beats. Drives the playhead + active-note highlight.
    var currentBeat: Double = 0 {
        didSet { setNeedsDisplay() }
    }

    var isPlaying: Bool = false {
        didSet { setNeedsDisplay() }
    }

    private let keyboardWidth: CGFloat = 42
    private let minRowHeight: CGFloat = 7
    private let topPad: CGFloat = 8
    private let bottomPad: CGFloat = 8

    private var lowPitch = 48   // C3
    private var highPitch = 72  // C5
    private var totalBeats = 8.0

    private let blackKeyClasses: Set<Int> = [1, 3, 6, 8, 10]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.card
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = Theme.card
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        contentMode = .redraw
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    private func recomputeRanges() {
        guard !notes.isEmpty else {
            lowPitch = 48; highPitch = 72; totalBeats = 8.0
            return
        }
        let pitches = notes.map { $0.pitch }
        lowPitch = (pitches.min() ?? 48) - 1
        highPitch = (pitches.max() ?? 72) + 1
        if highPitch - lowPitch < 12 {            // keep at least an octave for context
            let pad = (12 - (highPitch - lowPitch))
            lowPitch -= pad / 2
            highPitch += pad - pad / 2
        }
        let end = notes.map { $0.start + $0.duration }.max() ?? 8.0
        totalBeats = max(end, 4.0)
    }

    private func noteName(_ pitch: Int) -> String {
        let octave = pitch / 12 - 1
        return "C\(octave)"
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let rollX = keyboardWidth
        let rollW = bounds.width - keyboardWidth
        let gridTop = topPad
        let gridH = bounds.height - topPad - bottomPad
        let rows = max(highPitch - lowPitch + 1, 1)
        let rowH = max(gridH / CGFloat(rows), minRowHeight)
        let pxPerBeat = rollW / CGFloat(totalBeats)

        func yFor(pitch: Int) -> CGFloat {
            // higher pitch = higher on screen
            return gridTop + CGFloat(highPitch - pitch) * rowH
        }

        // ---- Row shading (darker rows behind black-key pitches) ----
        for p in lowPitch...highPitch {
            if blackKeyClasses.contains(((p % 12) + 12) % 12) {
                ctx.setFillColor(Theme.rollRowDark.cgColor)
                ctx.fill(CGRect(x: rollX, y: yFor(pitch: p), width: rollW, height: rowH))
            }
        }

        // ---- Horizontal octave lines (at each C) ----
        ctx.setLineWidth(1)
        for p in lowPitch...highPitch where p % 12 == 0 {
            ctx.setStrokeColor(Theme.hairline.cgColor)
            let y = yFor(pitch: p) + rowH
            ctx.move(to: CGPoint(x: rollX, y: y))
            ctx.addLine(to: CGPoint(x: bounds.width, y: y))
            ctx.strokePath()
        }

        // ---- Vertical beat gridlines (bar lines every 4 beats) ----
        var beat = 0
        while Double(beat) <= totalBeats {
            let x = rollX + CGFloat(beat) * pxPerBeat
            let isBar = beat % 4 == 0
            ctx.setStrokeColor((isBar ? Theme.hairline : Theme.hairline.withAlphaComponent(0.5)).cgColor)
            ctx.setLineWidth(isBar ? 1 : 0.5)
            ctx.move(to: CGPoint(x: x, y: gridTop))
            ctx.addLine(to: CGPoint(x: x, y: gridTop + gridH))
            ctx.strokePath()
            beat += 1
        }

        // ---- Note bars ----
        for note in notes {
            guard note.pitch >= lowPitch && note.pitch <= highPitch else { continue }
            let x = rollX + CGFloat(note.start) * pxPerBeat
            let w = max(CGFloat(note.duration) * pxPerBeat - 2, 3)
            let y = yFor(pitch: note.pitch) + 1
            let h = max(rowH - 2, 4)
            let active = isPlaying && currentBeat >= note.start && currentBeat <= note.start + note.duration
            let barRect = CGRect(x: x + 1, y: y, width: w, height: h)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: min(3, h / 2))
            ctx.setFillColor((active ? Theme.noteBarActive : Theme.noteBar).cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }

        // ---- Keyboard gutter ----
        ctx.setFillColor(Theme.card.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: keyboardWidth, height: bounds.height))
        for p in lowPitch...highPitch {
            let y = yFor(pitch: p)
            let isBlack = blackKeyClasses.contains(((p % 12) + 12) % 12)
            let keyRect = CGRect(x: 0, y: y, width: keyboardWidth, height: rowH)
            ctx.setFillColor((isBlack ? Theme.textPrimary.withAlphaComponent(0.82) : UIColor.white).cgColor)
            ctx.fill(keyRect.insetBy(dx: 0, dy: 0.5))
            // C labels
            if p % 12 == 0 && rowH >= 9 {
                let label = noteName(p) as NSString
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: Theme.rounded(min(rowH - 2, 10), .semibold),
                    .foregroundColor: Theme.textMuted
                ]
                let size = label.size(withAttributes: attrs)
                label.draw(at: CGPoint(x: keyboardWidth - size.width - 4,
                                       y: y + (rowH - size.height) / 2), withAttributes: attrs)
            }
        }
        // keyboard right border
        ctx.setStrokeColor(Theme.hairline.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: keyboardWidth, y: 0))
        ctx.addLine(to: CGPoint(x: keyboardWidth, y: bounds.height))
        ctx.strokePath()

        // ---- Playhead ----
        if currentBeat > 0 || isPlaying {
            let x = rollX + CGFloat(currentBeat) * pxPerBeat
            ctx.setStrokeColor(Theme.noteBarActive.cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: CGPoint(x: x, y: gridTop))
            ctx.addLine(to: CGPoint(x: x, y: gridTop + gridH))
            ctx.strokePath()
        }

        // ---- Empty state ----
        if notes.isEmpty {
            let msg = "No notes yet — add one below" as NSString
            let attrs: [NSAttributedString.Key: Any] = [
                .font: Theme.rounded(14, .medium),
                .foregroundColor: Theme.textMuted
            ]
            let size = msg.size(withAttributes: attrs)
            msg.draw(at: CGPoint(x: rollX + (rollW - size.width) / 2,
                                 y: gridTop + (gridH - size.height) / 2), withAttributes: attrs)
        }
    }
}
