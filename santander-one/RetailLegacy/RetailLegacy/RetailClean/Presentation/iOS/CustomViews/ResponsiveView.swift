import UIKit

class ResponsiveView: UIView, CoachmarkUIView {
    
    // MARK: - Public attributes
    
    var coachmarkId: CoachmarkIdentifier?
    
    // MARK: - Private attributes
    
    private var completion: (() -> Void)?
    
    // MARK: - Public methods
    
    func addAction(_ completion: @escaping (() -> Void)) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(performAction))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.completion = completion
    }
    
    // MARK: - Actions
    
    @objc private func performAction() {
        self.completion?()
    }
}
