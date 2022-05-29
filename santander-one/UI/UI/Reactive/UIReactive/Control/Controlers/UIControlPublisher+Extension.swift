//
//  UIControl.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 2/21/22.
//

import Foundation
import UIKit
import OpenCombine

public extension UIControl {
    /// A Control Event is a publisher that emits whenever the provided
    /// Control Events fire.
    func publisher(for event: UIControl.Event) -> AnyPublisher<UIControl, Never> {
        return UIControlPublisher(control: self, events: event)
            .eraseToAnyPublisher()
    }
    
    /// A Control Property is a publisher that emits the value at the provided keypath
    /// whenever the specific control events are triggered. It also emits the keypath's
    /// initial value upon subscription.
    func publisher<Value>(for keyPath: KeyPath<UIControl, Value>) -> AnyPublisher<Value, Never> {
        return UIControlPropertyPublisher(control: self, keyPath: keyPath, events: [.allEditingEvents, .valueChanged])
            .eraseToAnyPublisher()
    }
}
