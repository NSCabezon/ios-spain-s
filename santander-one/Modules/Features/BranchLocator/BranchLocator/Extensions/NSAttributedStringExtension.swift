//
//  NSAttributedStringExtension.swift
//  BranchLocator
//
//  Created by Daniel Rincon on 17/07/2019.
//

import Foundation

extension NSAttributedString {
    
    var trailingNewlineChopped: NSAttributedString {
        if string.hasSuffix("\n") {
            return self.attributedSubstring(from: NSRange(location: 0, length: length - 1))
        } else {
            return self
        }
    }
}
