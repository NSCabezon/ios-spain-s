import UIKit

extension OptionsStackView {
    
    class AmountRowStack: UIView {
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.axis = .horizontal
            stackView.spacing = 9
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        private var optionValues = [ValueOptionType?]()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }
        
        func setupView() {
            addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        func addAmounts(_ values: [ValueOptionType?]) {
            self.optionValues = values
            for value in values {
                guard let value = value else {
                    stackView.addArrangedSubview(UIView())
                    continue
                }
                let button = OptionButton()
                
                let style = ButtonStylist(textColor: .sanGreyDark, font: .latoRegular(size: 18))
                (button as UIButton).applyStyle(style)
                button.backgroundColor = .uiWhite
                button.drawRoundedAndShadowed()                
                button.optionData = value
                button.setTitle(value.displayableValue, for: .normal)
                button.addTarget(self, action: #selector(optionPressed(_:)), for: .touchUpInside)
                button.accessibilityIdentifier = "amountBtn"
                stackView.addArrangedSubview(button)
            }
        }
        
        @objc func optionPressed(_ button: OptionButton) {
            let optionData = button.optionData
            optionData?.action?()
        }
        
        var count: Int {
            return stackView.arrangedSubviews.count
        }
        
        func clear() {
            for view in stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
    }
    
}
