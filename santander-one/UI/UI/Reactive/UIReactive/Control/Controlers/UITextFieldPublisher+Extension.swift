import UIKit
import OpenCombine

public extension UITextField {
    /// A publisher emitting any text changes to a this text field.
    var textPublisher: AnyPublisher<String?, Never> {
        UIControlPropertyPublisher(
         control: self,
         keyPath: \.text,
         events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }

    /// A publisher emitting any attributed text changes to this text field.
    var attributedTextPublisher: AnyPublisher<NSAttributedString?, Never> {
        UIControlPropertyPublisher(
         control: self,
         keyPath: \.attributedText,
         events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }

    /// A publisher that emits whenever the user taps the return button and ends the editing on the text field.
    var returnPublisher: AnyPublisher<Void, Never> {
        UIControlPublisher(
            control: self,
            events: .editingDidEndOnExit
        ).map {_ in}
        .eraseToAnyPublisher()
    }

    /// A publisher that emits whenever the user taps the text fields and begin the editing.
    var didBeginEditingPublisher: AnyPublisher<Void, Never> {
        UIControlPublisher(
            control: self,
            events: .editingDidBegin
        ).map { _ in }
        .eraseToAnyPublisher()
    }
}
