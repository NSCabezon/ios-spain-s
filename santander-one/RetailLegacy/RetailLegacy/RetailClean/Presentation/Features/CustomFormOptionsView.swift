import UIKit

protocol CustomFormOptionActionType: Executable {
    var title: LocalizedStylableText { get }
}

struct CustomFormOptionAction: CustomFormOptionActionType, Executable {
    
    let title: LocalizedStylableText
    var action: (() -> Void)?
    
    func execute() {
        action?()
    }
    
}

class CustomFormOptionsView: UIView {
    
    private weak var mainStackView: UIStackView?
    
    var normalButtonStyle: ButtonStylist = ButtonStylist(textColor: .sanRed, font: UIFont.latoBold(size: 16.0), borderColor: .sanRed, borderWidth: 1, backgroundColor: .uiWhite)
    var selectedButtonStyle: ButtonStylist = ButtonStylist(textColor: .lisboaGray, font: UIFont.latoBold(size: 16.0), borderColor: .lisboaGray, borderWidth: 1, backgroundColor: .uiWhite)
    var highlightedNormalButtonStyle: ButtonStylist = ButtonStylist(textColor: .uiWhite, font: UIFont.latoBold(size: 16.0), borderColor: .sanRed, borderWidth: 1, backgroundColor: .sanRed)
    var highlightedSelectedButtonStyle: ButtonStylist = ButtonStylist(textColor: .uiWhite, font: UIFont.latoBold(size: 16.0), borderColor: .lisboaGray, borderWidth: 1, backgroundColor: .lisboaGray)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
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
        let mainStack = createMainStackView()
        mainStackView = mainStack
        addSubview(mainStack)
        
        mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 18.0).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -22.0).isActive = true
        mainStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 18.0).isActive = true
        mainStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -18.0).isActive = true
    }
    
    private func createMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
        
        return stackView
    }
    
    private func createRowStackViewWith(views: [UIView]) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 10
        views.forEach { (view) in
            stackView.addArrangedSubview(view)
        }
        return stackView
    }
    
    private func createRow(options: [CustomFormOptionActionType]) -> UIStackView {
        guard !options.isEmpty else {
            fatalError()
        }
        let buttons = options.map { createButtonWith(info: $0) }
        return createRowStackViewWith(views: buttons)
    }
    
    private func createButtonWith(info: CustomFormOptionActionType) -> UIButton {
        let button = StyledButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setStyles(normal: normalButtonStyle, selected: selectedButtonStyle)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.set(localizedStylableText: info.title, state: .normal)
        button.addTarget(self, action: #selector(actionPressed(_:)), for: .touchUpInside)
        button.action = info.execute
        button.accessibilityIdentifier = info.title.text
        return button
    }
    
    func setActions(_ options: [CustomFormOptionActionType]) {
        removeContainedViews()
        let rowActions = stride(from: 0, to: options.count, by: 2).map {
            Array(options[$0 ..< Swift.min($0 + 2, options.count)])
        }
        
        for (index, row) in rowActions.enumerated() {
            let v = createRow(options: row)
            if index == rowActions.count - 1 {
                (v.arrangedSubviews.last as? StyledButton)?.setStyles(normal: highlightedNormalButtonStyle, selected: highlightedSelectedButtonStyle)
            }
            mainStackView?.addArrangedSubview(v)
        }
    }
    
    @objc func actionPressed(_ sender: StyledButton) {
        sender.action?()
    }
    
    // MARK: - Helpers
    
    private func removeContainedViews() {
        guard let mainStackView = mainStackView else {
            return
        }
        for v in mainStackView.arrangedSubviews {
            v.removeFromSuperview()
        }
    }
}
