//
//  UIGestureRecognizer.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 3/10/22.
//

import Foundation
import UIKit
import OpenCombine

/// A helper method that allow you to use a `GestureType` instead of pasing the gesture instance
///
///     view.publisher(gesture: .tap)
///     .....

public extension UIView {
    func publisher(gesture: UIGestureRecognizer.GestureType) -> AnyPublisher<UIGestureRecognizer, Never> {
        return GestureRecognizerPublisher(view: self, gesture: gesture.getGestureRecognizer())
            .subscribe(on: DispatchQueue.OCombine(.main))
            .eraseToAnyPublisher()
    }
}

public extension UIGestureRecognizer {
    enum GestureType {
        case tap, pan
        
        public func getGestureRecognizer() -> UIGestureRecognizer {
            switch self {
            case .tap:
                return UITapGestureRecognizer()
            case .pan:
                return UIPanGestureRecognizer()
            }
        }
    }
}
