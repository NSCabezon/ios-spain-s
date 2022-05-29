import UIKit
import OpenCombine

public extension UISlider {
    /// A publisher emitting value changes for this slider.
    var valuePublisher: AnyPublisher<Float, Never> {
        UIControlPropertyPublisher(
            control: self,
            keyPath: \.value,
            events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }
}
