import UIKit

extension RadioButtonCustomView {
    
    class RadioView: UIView {
        
        private lazy var centerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = centralColor
            return view
        }()
        
        private lazy var circleView: UIView = {
            let circleView = UIView()
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.backgroundColor = .clear
            return circleView
        }()
        
        var centralColor: UIColor = .red {
            didSet {
                centerView.backgroundColor = centralColor
            }
        }
        
        var borderColor: UIColor = .gray {
            didSet {
                layer.borderColor = borderColor.cgColor
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }
        
        private func setupView() {
            layer.borderWidth = 1.0
            layer.borderColor = borderColor.cgColor
            addSubview(centerView)
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            centerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.65).isActive = true
            centerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65).isActive = true
            addSubview(circleView)
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            circleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            circleView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            centerView.layer.cornerRadius = centerView.bounds.height / 2
            layer.cornerRadius = bounds.height / 2
        }
        
        func setSelected(_ isSelected: Bool) {
            centerView.isHidden = !isSelected
        }
        
        func setAccessibilityIdentifiers(identifier: String) {
            centerView.isAccessibilityElement = true
            centerView.accessibilityIdentifier = identifier + "_centerView"
            circleView.accessibilityIdentifier = identifier + "_circleView"
        }
    }
}
