//
//  PianoKeyboardView.swift
//  MIDIPlayer
//
//  A tappable multi-octave piano keyboard for entering / auditioning notes.
//  Emits note names that match NotePickerString (e.g. "C4", "F#3").
//

import UIKit

class PianoKeyboardView: UIView {

    /// Called with a note name like "C4" / "F#3" when a key is tapped.
    var onKeyTapped: ((String) -> Void)?

    var startOctave = 3
    var octaveCount = 2

    private let whiteClasses = [0, 2, 4, 5, 7, 9, 11]            // C D E F G A B
    private let blackAfterWhiteIndex = [0, 1, 3, 4, 5]           // black sits after these white keys
    private let blackClassForWhiteIndex = [1, 3, 6, 8, 10]       // C# D# F# G# A#
    private let names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    private var whiteKeys: [(rect: CGRect, name: String)] = []
    private var blackKeys: [(rect: CGRect, name: String)] = []
    private var highlighted: String? { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.card
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        contentMode = .redraw
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildKeys()
        setNeedsDisplay()
    }

    private func rebuildKeys() {
        whiteKeys.removeAll(); blackKeys.removeAll()
        let whiteCount = 7 * octaveCount
        guard whiteCount > 0 else { return }
        let whiteW = bounds.width / CGFloat(whiteCount)
        let blackW = whiteW * 0.62
        let blackH = bounds.height * 0.6

        var wIndex = 0
        for o in 0..<octaveCount {
            let octave = startOctave + o
            // white keys
            for (i, cls) in whiteClasses.enumerated() {
                let x = CGFloat(wIndex) * whiteW
                let rect = CGRect(x: x, y: 0, width: whiteW, height: bounds.height)
                whiteKeys.append((rect, "\(names[cls])\(octave)"))
                // black key after this white (if any)
                if let bi = blackAfterWhiteIndex.firstIndex(of: i) {
                    let bx = x + whiteW - blackW / 2
                    let brect = CGRect(x: bx, y: 0, width: blackW, height: blackH)
                    blackKeys.append((brect, "\(names[blackClassForWhiteIndex[bi]])\(octave)"))
                }
                wIndex += 1
            }
        }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        // white keys
        for key in whiteKeys {
            let isHi = key.name == highlighted
            ctx.setFillColor((isHi ? Theme.accentSoft : UIColor.white).cgColor)
            ctx.fill(key.rect)
            ctx.setStrokeColor(Theme.hairline.cgColor)
            ctx.setLineWidth(1)
            ctx.stroke(key.rect)
            // label C keys
            if key.name.hasPrefix("C") && !key.name.hasPrefix("C#") {
                let label = key.name as NSString
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: Theme.rounded(10, .semibold),
                    .foregroundColor: Theme.textMuted
                ]
                let size = label.size(withAttributes: attrs)
                label.draw(at: CGPoint(x: key.rect.midX - size.width / 2,
                                       y: key.rect.maxY - size.height - 4), withAttributes: attrs)
            }
        }
        // black keys (on top)
        for key in blackKeys {
            let isHi = key.name == highlighted
            ctx.setFillColor((isHi ? Theme.accent : Theme.textPrimary.withAlphaComponent(0.85)).cgColor)
            let path = UIBezierPath(roundedRect: key.rect, cornerRadius: 3)
            ctx.addPath(path.cgPath); ctx.fillPath()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self) else { return }
        // black keys take priority (drawn on top)
        if let hit = blackKeys.first(where: { $0.rect.contains(p) }) {
            tap(hit.name)
        } else if let hit = whiteKeys.first(where: { $0.rect.contains(p) }) {
            tap(hit.name)
        }
    }

    private func tap(_ name: String) {
        highlighted = name
        onKeyTapped?(name)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            if self?.highlighted == name { self?.highlighted = nil }
        }
    }
}
