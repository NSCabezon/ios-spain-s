import Foundation
import OpenCombine
import UIKit

/// A Control Event is a publisher that emits whenever the provided
/// Control Events fire.
///
/// Use `publisher(for:)` to handle de view events
///
/// In the example below, the `publisher(for:)` is used to handle the `UIButton` `.touchUpInside` event
///
///     myButton.publisher(for: .touchUpInside)
///        .map{ $0 as? UIButton }
///        .sink { button in
///           print("TouchUpInside: \(button)")
///     }.store(in: &subscription)
///
///
///     // Prints: "TouchUpInside: Optional(<UIButton: 0x7b5800000c00 ...."
///
/// - parameter control: UI Control.
/// - parameter events: Control Events.
///
public struct UIControlPublisher<Control: UIControl>: Publisher {

    public typealias Output = Control
    public typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

private extension UIControlPublisher {
    final class UIControlSubscription<S: Subscriber, Control: UIControl>: Subscription where S.Input == Control {
        private var subscriber: S?
        private let control: Control

        init(subscriber: S, control: Control, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(eventHandler), for: event)
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        @objc private func eventHandler() {
            _ = subscriber?.receive(control)
        }
    }
}
