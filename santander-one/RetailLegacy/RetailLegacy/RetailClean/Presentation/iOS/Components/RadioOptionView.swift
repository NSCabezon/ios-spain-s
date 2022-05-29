import UIKit

extension RadioButtonCustomView {
    
    class RadioOptionView: UIView {
        
        private lazy var radialView: RadioView = {
            let radioView = RadioView()
            radioView.translatesAutoresizingMaskIntoConstraints = false
            return radioView
        }()
        
        private lazy var selectionTapGesture: UITapGestureRecognizer = {
            let tap = UITapGestureRecognizer(target: self, action: #selector(pressed))
            return tap
        }()
        
        @objc func pressed() {
            setSelected(true)
            self.pressedAction?(true)
        }
        
        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        var titleSelectedColor = UIColor.sanGreyDark
        var titleNonSelectedColor = UIColor.sanGreyMedium
        var pressedAction: ((Bool) -> Void)?
        
        var radioBorderColor: UIColor {
            get {
                return radialView.borderColor
            }
            set {
                radialView.borderColor = newValue
            }
        }
        
        var radioCentralColor: UIColor {
            get {
                return radialView.centralColor
            }
            set {
                radialView.centralColor = newValue
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
            addSubview(radialView)
            radialView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
            radialView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 10).isActive = true
            radialView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4).isActive = true
            radialView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            radialView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            radialView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            addSubview(titleLabel)
            titleLabel.centerYAnchor.constraint(equalTo: radialView.centerYAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: radialView.trailingAnchor, constant: 16.0).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0).isActive = true
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12).isActive = true
            titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16)))
            addGestureRecognizer(selectionTapGesture)
        }
        
        func setTitle(_ title: String) {
            titleLabel.text = title
        }
        
        func setSelected(_ isSelected: Bool) {
            radialView.setSelected(isSelected)
            let titleColor = isSelected ? UIColor.sanGreyDark : UIColor.sanGreyMedium
            titleLabel.applyStyle(LabelStylist(textColor: titleColor, font: .latoSemibold(size: 16)))
        }
        
        func setAccessibilityIdentifiers(identifier: String) {
            titleLabel.accessibilityIdentifier = identifier + "_title"
            radialView.setAccessibilityIdentifiers(identifier: identifier)
        }
    }
}
