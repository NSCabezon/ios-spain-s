import UIKit
import OpenCombine

public extension UISwitch {
    /// A publisher emitting on status changes for this switch.
    var isOnPublisher: AnyPublisher<Bool, Never> {
       UIControlPropertyPublisher(
        control: self,
        keyPath: \.isOn,
        events: [.allEditingEvents, .valueChanged]
       ).eraseToAnyPublisher()
    }
}
