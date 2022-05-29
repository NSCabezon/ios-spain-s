import Foundation

public extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        if #available(iOS 10.2, *) {
            return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
        } else {
            return false
        }
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        if #available(iOS 10.2, *) {
            return unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false
        } else {
            return false
        }
    }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}
