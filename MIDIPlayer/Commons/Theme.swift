//
//  Theme.swift
//  MIDIPlayer
//
//  Shared visual theme for the redesigned UI ("clean & modern light").
//

import UIKit

enum Theme {

    // MARK: Palette
    static let background  = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)   // soft off-white
    static let card        = UIColor.white
    static let accent      = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0)   // indigo
    static let accentSoft  = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 0.14)
    static let danger      = UIColor(red: 0.91, green: 0.30, blue: 0.36, alpha: 1.0)
    static let textPrimary = UIColor(red: 0.13, green: 0.14, blue: 0.20, alpha: 1.0)
    static let textMuted   = UIColor(red: 0.45, green: 0.47, blue: 0.55, alpha: 1.0)
    static let hairline    = UIColor(red: 0.88, green: 0.89, blue: 0.93, alpha: 1.0)
    static let noteBar     = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0)
    static let noteBarActive = UIColor(red: 1.00, green: 0.45, blue: 0.30, alpha: 1.0)  // warm highlight
    static let rollRowDark = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)

    // MARK: Fonts
    static func font(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    static func rounded(_ size: CGFloat, _ weight: UIFont.Weight = .semibold) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        if let d = base.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: d, size: size)
        }
        return base
    }

    // MARK: Card styling
    static func styleCard(_ view: UIView, radius: CGFloat = 16) {
        view.backgroundColor = card
        view.layer.cornerRadius = radius
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
    }

    // MARK: Button styles
    // NOTE: deliberately NOT using UIButton.Configuration so that existing
    // setTitle(_:for:) calls (e.g. Play <-> Stop) keep working unchanged.

    private static func enableShrink(_ button: UIButton) {
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.lineBreakMode = .byClipping
    }

    /// A filled rounded button (primary actions like Play).
    static func stylePrimary(_ button: UIButton, color: UIColor = Theme.accent) {
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = Theme.rounded(17, .semibold)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.contentEdgeInsets = UIEdgeInsets(top: 11, left: 15, bottom: 11, right: 15)
        enableShrink(button)
    }

    /// A subtle tinted rounded button (secondary actions).
    static func styleSecondary(_ button: UIButton, color: UIColor = Theme.accent) {
        button.backgroundColor = color.withAlphaComponent(0.12)
        button.setTitleColor(color, for: .normal)
        button.tintColor = color
        button.titleLabel?.font = Theme.rounded(14, .medium)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 11, bottom: 9, right: 11)
        enableShrink(button)
    }

    /// Apply background + recursive control styling to a simple screen
    /// (used by the Create / Rename pages).
    static func applyScreenTheme(_ vc: UIViewController) {
        vc.view.backgroundColor = background
        styleControlsRecursively(in: vc.view)
    }

    private static func styleControlsRecursively(in root: UIView) {
        for sub in root.subviews {
            if let b = sub as? UIButton {
                let t = (b.currentTitle ?? "").lowercased()
                if t.contains("delete") {
                    styleSecondary(b, color: danger)
                } else if t.contains("cancel") || t.contains("back") {
                    styleSecondary(b)
                } else {
                    stylePrimary(b)
                }
            } else if let tf = sub as? UITextField {
                styleTextField(tf)
            } else if let label = sub as? UILabel {
                label.textColor = textPrimary
                label.font = rounded(label.font.pointSize, .medium)
            }
            styleControlsRecursively(in: sub)
        }
    }

    static func styleTextField(_ tf: UITextField) {
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
        tf.textColor = Theme.textPrimary
        tf.font = Theme.rounded(15, .medium)
        tf.layer.cornerRadius = 10
        tf.layer.cornerCurve = .continuous
        tf.layer.masksToBounds = true
        tf.textAlignment = .center
        // padding
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        tf.leftView = pad
        tf.leftViewMode = .always
    }
}
