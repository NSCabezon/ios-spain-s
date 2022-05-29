//
//  EmojiValidator.swift
//  PersonalArea
//
//  Created by Ignacio González Miró on 23/7/21.
//

import Foundation
import CoreFoundationLib

public final class EmojiValidator: TextFieldValidatorProtocol {
    var emojiRanges: [(Int, Int)] = []
    
    public init() {
        self.emojiRanges = [
            (8205, 11093),
            (12336, 12953),
            (65039, 65039),
            (126980, 129685)
        ]
    }
    
    public func isEmoji(_ str: String) -> Bool {
        guard !str.isEmpty else {
            return false
        }
        let codePoint = str.unicodeScalars[str.unicodeScalars.startIndex].value
        let emojiList = self.emojiRanges.filter({ codePoint >= $0.0 && codePoint <= $0.1 })
        return !emojiList.isEmpty
    }
}
