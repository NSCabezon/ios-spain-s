import UIKit
import OpenCombine

public extension UIRefreshControl {
    /// A publisher emitting refresh status changes from this refresh control.
    var isRefreshingPublisher: AnyPublisher<Bool, Never> {
        UIControlPropertyPublisher(
            control: self,
            keyPath: \.isRefreshing,
            events: [.allEditingEvents, .valueChanged]
        ).eraseToAnyPublisher()
    }
}
