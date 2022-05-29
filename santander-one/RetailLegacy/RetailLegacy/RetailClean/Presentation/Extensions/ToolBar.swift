import UIKit

extension UIToolbar {
    func clearBackground() {
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        backgroundColor = .clear
    }
}
