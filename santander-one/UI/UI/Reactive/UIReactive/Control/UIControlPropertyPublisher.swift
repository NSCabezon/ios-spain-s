import Foundation
import OpenCombine
import UIKit

/// A Control Property is a publisher that emits the value at the provided keypath
/// whenever the specific control events are triggered. It also emits the keypath's
/// initial value upon subscription.
///
/// Use `UIControlPropertyPublisher`extend UIKit reactive api adding propety publisher
///
/// In the example below, we add the `textPublisher` to track when the `UITextField.text` changes
///
///     public extension UITextField {
///         var textPublisher: AnyPublisher<String?, Never> {
///              UIControlPropertyPublisher(
///              control: self,
///              keyPath: \.text,
///              events: [.allEditingEvents, .valueChanged])
///              .eraseToAnyPublisher()
///         }
///      }
///
/// Usages
///
///     let textfield = UITextField(frame: .zero)
///     textfield.textPublisher
///       .sink { newValue in
///           print(newValue)
///       }.store(in: &subscriptions)
///
/// - parameter control: UI Control.
/// - parameter keyPath: A Key Path from the UI Control to the requested value.
/// - parameter events: Control Events.
///
public struct UIControlPropertyPublisher<Control: UIControl, Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never
    private let control: Control
    private let keyPath: KeyPath<Control, Value>
    private let events: UIControl.Event
    
    public init(control: Control,
                keyPath: KeyPath<Control, Value>,
                events: UIControl.Event) {
        self.control = control
        self.keyPath = keyPath
        self.events = events
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Value == S.Input {
        let subscription = Subscription(subscriber: subscriber, control: control, keyPath: keyPath, events: events)
        subscriber.receive(subscription: subscription)
    }
}

extension UIControlPropertyPublisher {
    private final class Subscription<S: Subscriber, Control: UIControl, Value>: OpenCombine.Subscription where S.Input == Value {
        private var subscriber: S?
        weak private var control: Control?
        private let keyPath: KeyPath<Control, Value>
        private let events: UIControl.Event
        private var initialValue = false
        
        init(subscriber: S,
             control: Control,
             keyPath: KeyPath<Control, Value>,
             events: UIControl.Event) {
            self.control = control
            self.subscriber = subscriber
            self.keyPath = keyPath
            self.events = events
            control.addTarget(self, action: #selector(handleEvent), for: events)
        }
        
        func request(_ demand: Subscribers.Demand) {
            if !initialValue, demand > .none, let control = control,
                let subscriber = subscriber {
                _ = subscriber.receive(control[keyPath: keyPath])
                initialValue = true
            }
        }
        
        func cancel() {
            control?.removeTarget(self, action: #selector(handleEvent), for: events)
            subscriber = nil
        }
        
        @objc func handleEvent() {
            guard let control = self.control else { return }
            _ = subscriber?.receive(control[keyPath: keyPath])
        }
    }
}
