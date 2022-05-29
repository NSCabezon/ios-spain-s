import UIKit

extension CGRect {
    mutating func move(to point: CGPoint) {
        origin = point
    }
    
    mutating func resize(to size: CGSize) {
        self.size = size
    }
    
    mutating func resize(factor: CGFloat) {
        size = CGSize(width: size.width * factor, height: size.height * factor)
    }
}
