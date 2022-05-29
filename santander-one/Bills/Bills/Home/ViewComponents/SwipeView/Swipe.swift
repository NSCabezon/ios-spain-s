//
//  Swipe.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/15/20.
//

import Foundation

final class Swipe {
    var originalPoint = CGPoint()
    var maxValue: (right: CGFloat, left: CGFloat) = (-90, 90)
    var allow: (right: Bool, left: Bool) = (false, false)
    let defaultPosition: CGFloat = 0
    let range: ClosedRange<CGFloat> = -106...106
    
    func translation(in xPosition: CGFloat, ondirection: HorizontalDirection) -> CGPoint {
        if ondirection == .right {
            return CGPoint(x: originalPoint.x + min(xPosition, 100), y: originalPoint.y)
        } else if ondirection == .left {
            return CGPoint(x: originalPoint.x + max(xPosition, -100), y: originalPoint.y)
        } else {
            return originalPoint
        }
    }
}
