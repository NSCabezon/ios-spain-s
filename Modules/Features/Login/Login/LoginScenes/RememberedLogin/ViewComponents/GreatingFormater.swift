//
//  GreatingFormater.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/11/20.
//

import UI
import CoreFoundationLib
import Foundation

final class GreatingFormater {
    private let nameLabelTrailingConstraint: CGFloat = 20.0
    private let headerLeadingConstraint: CGFloat = 25.0
    
    func setUpGreetingText(with userName: String?) -> NSAttributedString {
        guard let userName = userName else { return NSAttributedString() }
        let greetingText = localized("login_label_hello").text
        let builder = TextStylizer.Builder(fullText: greetingText + "\n" + userName)
        let lightStyle = TextStylizer.Builder.TextStyle(word: greetingText)
            .setStyle(.santander(family: .text, type: .light, size: 45))
        let regularFontDescriptor = UIFont.santander(family: .text, type: .regular, size: 45).fontDescriptor
        let regularFont = self.calculateNameFontSize(fontDescriptor: regularFontDescriptor, size: 45, name: userName)
        let regularStyle = TextStylizer.Builder.TextStyle(word: userName)
            .setStyle(regularFont)
        
        let attributedText: NSAttributedString = builder
            .addPartStyle(part: lightStyle)
            .addPartStyle(part: regularStyle)
            .build()
        
        return attributedText
    }
    
    func calculateNameFontSize(fontDescriptor: UIFontDescriptor, size: CGFloat, name: String) -> UIFont {
        let fontAttributes = [NSAttributedString.Key.font: UIFont(descriptor: fontDescriptor, size: size)]
        let nsString = name as NSString
        let margins = headerLeadingConstraint + nameLabelTrailingConstraint
        guard nsString.size(withAttributes: fontAttributes).width <= (UIScreen.main.bounds.size.width - margins) else {
            return self.calculateNameFontSize(fontDescriptor: fontDescriptor, size: size - 1, name: name)
        }
        let font = UIFont(descriptor: fontDescriptor, size: size)
        return font
    }
}
