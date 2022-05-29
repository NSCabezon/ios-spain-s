import UIKit

extension ButtonStackView {
    
    class OptionView: UIView {
        
        private(set) var option: TransactionDetailActionType?
        
        private var button: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.sanGreyDark, for: .normal)
            let fontSize: CGFloat = UIScreen.main.isIphone4or5 ? 12.0 : 14.0
            button.titleLabel?.font = UIFont.latoBold(size: fontSize)
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.textAlignment = .center
            button.heightAnchor.constraint(equalToConstant: 62).isActive = true
    
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }
        
        private func setupView() {
            button.embedInto(container: self, insets: UIEdgeInsets(top: 2, left: 8, bottom: -2, right: -8))
            backgroundColor = .uiWhite
        }
        
        func config(_ info: TransactionDetailActionType) {
            self.option = info
            button.set(localizedStylableText: info.title, state: .normal)
            button.setTitleColor(info.textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        }
        
        @objc func buttonPressed() {
            option?.action?()
        }
        
    }
}
