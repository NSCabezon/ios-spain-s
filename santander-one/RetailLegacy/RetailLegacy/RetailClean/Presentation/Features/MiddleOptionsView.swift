import UIKit

class MiddleOptionsView: UIView {
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 0
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        containerStackView.embedInto(container: self)
    }
    
    func setVerticalViews(_ views: [UIView]) {
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        views.forEach { containerStackView.addArrangedSubview($0) }
    }
}
