import UIKit

public struct Placeholder {
    
    var placeholderImage: String?
    var insets: CGFloat?
    
    public init(_ placeholderImage: String, _ insets: CGFloat) {
        self.placeholderImage = placeholderImage
        self.insets = insets
    }
    
}
