import UIKit
import OpenCombine

public extension UIPageControl {
    /// A publisher emitting current page changes for this page control.
    var currentPagePublisher: AnyPublisher<Int, Never> {
        self.publisher(keyPath: \.currentPage)
            .eraseToAnyPublisher()
    }
}
