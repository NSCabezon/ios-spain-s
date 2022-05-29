//
//  UIPanGestureRecognizer+extension.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/15/20.
//

import Foundation

enum HorizontalDirection {
    case left
    case right
    case none
}

extension UIPanGestureRecognizer {
    func direction() -> HorizontalDirection {
        guard let view = self.view else { return .none }
        switch velocity(in: view).x {
        case let value where value > 0 :
            return .right
        case let value where value < 0 :
            return .left
        default:
            return .none
        }
    }
}
