//
//  UITextView+Extensions.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 31/08/2020.
//

import UIKit
import CoreFoundationLib

extension UITextView {
    
    public func configureText(withLocalizedString localizedString: LocalizedStylableText,
                              andConfiguration configuration: LocalizedStylableTextConfiguration? = nil) {
        if localizedString.styles != nil || configuration != nil {
            self.attributedText = localizedString.asAttributedString(for: self, configuration)
        } else {
            self.text = localizedString.text
        }
    }
    
    public func configureText(withKey key: String,
                              andConfiguration configuration: LocalizedStylableTextConfiguration? = nil) {
        let localizedString: LocalizedStylableText = localized(key)
        self.configureText(withLocalizedString: localizedString, andConfiguration: configuration)
    }
}
