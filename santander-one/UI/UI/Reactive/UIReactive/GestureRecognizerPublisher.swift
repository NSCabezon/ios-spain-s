//
//  GestureRecognizerPublisher.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 3/10/22.
//

import UIKit
import OpenCombine
import Foundation

/// Publish each time the specified gesture takes place.
///
/// Use `publisher(gesture:)` to handle user gesture on views
///
/// In the example below, the `publisher(gesture:)` is used to handle the `View` tap gesture
///
///     let view = UIView()
///     cancellable = view.publisher(gesture: .tap)
///         .sink { gesture in
///             print(gesture.state)
///         }
///
/// Print each time the user that the view
/// 
///     // Prints: "UIGestureRecognizerState"
///
/// - Parameter gesture: The `UIGestureRecognizer` to take care of.
/// - Returns: A publisher that publishes each time the expecified gesture is performed by the user
///
public struct GestureRecognizerPublisher<View: UIView, Gesture: UIGestureRecognizer>: Publisher {
    public typealias Output = Gesture
    public typealias Failure = Never
    private let view: View
    private let gesture: Gesture
    
    public init(view: View, gesture: Gesture) {
        self.view = view
        self.gesture = gesture
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Gesture == S.Input {
        let subscription = Subscription(subscriber: subscriber, view: view, gesture: gesture)
        subscriber.receive(subscription: subscription)
    }
}

private extension GestureRecognizerPublisher {
    
    final class Subscription<S: Subscriber, View: UIView, Gesture: UIGestureRecognizer>: OpenCombine.Subscription where S.Input == Gesture {
        private var subscriber: S?
        private var gesture: Gesture
        private weak var view: View?
        
        init(subscriber: S, view: View, gesture: Gesture) {
            self.subscriber = subscriber
            self.view = view
            self.gesture = gesture
            gesture.addTarget(self, action: #selector(handleGesture(recognizer:)))
            view.addGestureRecognizer(gesture)
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            subscriber = nil
            view?.removeGestureRecognizer(gesture)
        }
        
        @objc func handleGesture(recognizer: UIGestureRecognizer) {
            guard let gesture = recognizer as? Gesture else { return }
            _ = subscriber?.receive(gesture)
        }
    }
}
