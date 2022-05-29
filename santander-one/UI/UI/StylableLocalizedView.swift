//
//  StylableLocalizedView.swift
//  UI
//
//  Created by Tania Castellano Brasero on 22/10/2019.
//

import CoreFoundationLib

protocol StylableLocalizedButton: LocalizedStylableTextProcessor {
    func set(localizedStylableText: LocalizedStylableText, state: UIControl.State, completion: (() -> Void)?)
}

protocol StylableLocalizedField: LocalizedStylableTextProcessor {
    func set(localizedStylableText: LocalizedStylableText)
    func setOnPlaceholder(localizedStylableText: LocalizedStylableText)
    func setOnPlaceholder(localizedStylableText: LocalizedStylableText, attributes: [NSAttributedString.Key: Any]?)
}

protocol StylableLocalizedView: LocalizedStylableTextProcessor {
    func set(localizedStylableText: LocalizedStylableText)
}

protocol LocalizedStylableTextProcessor {}

extension LocalizedStylableTextProcessor {
    func processAttributedTextFrom(localizedStylableText: LocalizedStylableText, withFont font: UIFont, andAlignment alignment: NSTextAlignment) -> NSAttributedString? {
        return self.attributedTextFrom(localizedStylableText: localizedStylableText, withFont: font, andAlignment: alignment)
    }
    
    func processAttributedTextInMainThreadFrom(localizedStylableText: LocalizedStylableText, withFont font: UIFont, andAlignment alignment: NSTextAlignment) -> NSAttributedString? {
            return attributedTextFrom(localizedStylableText: localizedStylableText, withFont: font, andAlignment: alignment)
    }
    
    private func attributedTextFrom(localizedStylableText: LocalizedStylableText, withFont font: UIFont, andAlignment alignment: NSTextAlignment ) -> NSAttributedString? {
        guard let styles = localizedStylableText.styles else {
            return nil
        }
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        let attributed = NSMutableAttributedString(string: localizedStylableText.text, attributes: [NSAttributedString.Key.paragraphStyle: style])
        styles.forEach { style in
            switch style.attribute {
            case .font(let emphasis, let factor):
                if let font = font.font(with: emphasis, factor: CGFloat(factor)) {
                    attributed.addAttributes([.font: font], range: style.range)
                }
            case .color(let hexString):
                attributed.addAttributes([.foregroundColor: UIColor.fromHex(hexString.replace("#", ""))], range: style.range)
            case .underline:
                attributed.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], range: style.range)
            case .link:
                break
            }
        }
        return attributed
    }
}
