import UIKit
import OpenCombine

public extension UIStepper {
    /// A publisher emitting value changes for this stepper.
    var valuePublisher: AnyPublisher<Double, Never> {
        UIControlPropertyPublisher(
            control: self,
            keyPath: \.value,
            events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }
}
