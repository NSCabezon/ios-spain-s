import UIKit
import OpenCombine
import Foundation

public extension UIDatePicker {
    /// A publisher emitting date changes from this date picker.
    var datePublisher: AnyPublisher<Date, Never> {
        UIControlPropertyPublisher(
            control: self,
            keyPath: \.date,
            events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }

    /// A publisher emitting countdown duration changes from this date picker.
    var countDownDurationPublisher: AnyPublisher<TimeInterval, Never> {
        UIControlPropertyPublisher(
            control: self,
            keyPath: \.countDownDuration,
            events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }
}
