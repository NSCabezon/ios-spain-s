import UIKit
import OpenCombine

public extension UISegmentedControl {
    /// A publisher emitting selected segment index changes for this segmented control.
    var selectedSegmentIndexPublisher: AnyPublisher<Int, Never> {
        UIControlPropertyPublisher(
            control: self,
            keyPath: \.selectedSegmentIndex,
            events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }
}
