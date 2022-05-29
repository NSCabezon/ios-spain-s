import UIKit

class ResponsiveView: UIView {
    private var completion: (() -> Void)?

    func addAction(_ completion: @escaping (() -> Void)) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(performAction))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.completion = completion
    }

    @objc private func performAction() {
        self.completion?()
    }
}
