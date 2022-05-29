//
//  MultiselectionStackView.swift
//  UI
//
//  Created by David Gálvez Alonso on 03/02/2020.
//

import UIKit

class MultiselectionStackView: UIStackView {
    let maxButtonsPerLines = 3
    private var optionValues = [ValueOptionType?]()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
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
    
    func addValues(_ values: [ValueOptionType]) {
        self.optionValues = values
        clearOptions()
        let rowOptions = stride(from: 0, to: values.count, by: maxButtonsPerLines).map { Array(values[$0..<min($0 + maxButtonsPerLines, values.count)]) }
        for row in rowOptions {
            let emptyViewsCount = maxButtonsPerLines - row.count
            let emptyViewArray = [ValueOptionType?](repeating: nil, count: emptyViewsCount)
            let options = ButtonsRowStack()
            options.heightAnchor.constraint(equalToConstant: 96).isActive = true
            stackView.addArrangedSubview(options)
            options.addValues(row + emptyViewArray)
        }
    }
    
    private func clearOptions() {
        for case let view as ButtonsRowStack in stackView.arrangedSubviews {
            view.clear()
            view.removeFromSuperview()
        }
    }
    
    func reloadValues(_ valueSelected: String, disabledOptions: [String]? = nil) {
        optionValues.forEach { $0?.setDisabledIfMatchesString(disabledOptions: disabledOptions)}
        optionValues.forEach { $0?.setHighlightedIfMatchesString(value: valueSelected)}
    }
}

extension MultiselectionStackView {
    
    class ButtonsRowStack: UIView {
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.axis = .horizontal
            stackView.spacing = 8
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
        
        func addValues(_ values: [ValueOptionType?], font: UIFont? = nil) {
            self.optionValues = values
            for value in values {
                guard let value = value else {
                    stackView.addArrangedSubview(UIView())
                    continue
                }
                let button = SelectionButton()
                button.setTitleColor(UIColor.lisboaGray, for: .normal)
                button.titleLabel?.font = font ?? UIFont.santander(family: .text, type: .regular, size: 14.0)
                button.titleLabel?.numberOfLines = 0
                button.drawRoundedAndShadowedNew()
                button.optionData = value
                button.setTitle(value.displayableValue, for: .normal)
                button.addTarget(self, action: #selector(optionPressed(_:)), for: .touchUpInside)
                button.accessibilityIdentifier = value.accessibilityIdentifier
                stackView.addArrangedSubview(button)
            }
        }
        
        @objc func optionPressed(_ button: SelectionButton) {
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

class ValueOptionType {
    let value: String
    let displayableValue: String
    var action: (() -> Void)?
    var highlightAction: ((Bool) -> Void)? {
        didSet {
            highlightAction?(isHighlighted)
        }
    }
    var isHighlighted: Bool
    var isDisabled: Bool? {
        didSet {
            
        }
    }
    
    var accessibilityIdentifier: String
    
    init(value: String, displayableValue: String, isHighlighted: Bool = false, action: (() -> Void)? = nil, isDisabled: Bool? = false, accessibilityIdentifier: String) {
        self.action = action
        self.value = value
        self.displayableValue = displayableValue
        self.highlightAction = nil
        self.isHighlighted = isHighlighted
        self.isDisabled = isDisabled
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    func setHighlightedIfMatches(value: String?) {
        var rawText = value?.replacingOccurrences(of: ".", with: "")
        rawText = rawText?.replacingOccurrences(of: ",", with: ".")
        
        guard let value = rawText else {
            highlightAction?(false)
            isHighlighted = false
            return
        }
        let result = Decimal(string: value) == Decimal(string: self.value)
        isHighlighted = result
        highlightAction?(result)
    }
    
    func setHighlightedIfMatchesString(value: String?) {
        let result = value == self.value
        isHighlighted = result
        highlightAction?(result)
    }
    
    func setDisabledIfMatchesString(disabledOptions: [String]?) {
        self.isDisabled = disabledOptions?.contains(self.value)
    }
}

class SelectionButton: UIButton {
    var optionData: ValueOptionType? {
        didSet {
            optionData?.highlightAction = { [weak self] shouldHighlight in
                self?.isHighlighted = shouldHighlight
                self?.backgroundColor = shouldHighlight ? self?.selectedBackgroundColor : self?.nonSelectedBackgroundColor
                self?.layer.borderColor = shouldHighlight ? self?.selectedBorderColor.cgColor : self?.nonSelectedBorderColor.cgColor
                let titleColor = shouldHighlight ? self?.selectedTitleColor : self?.noSelectedTitleColor
                self?.setTitleColor(titleColor, for: .normal)
                
                self?.isEnabled = !(self?.optionData?.isDisabled ?? false)
                self?.alpha = !(self?.optionData?.isDisabled ?? false) ? 1 : 0.4
                self?.layer.shadowOpacity = !(self?.optionData?.isDisabled ?? false) ? 1.0 : 0.0
                self?.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
            }
        }
    }
    
    var selectedBackgroundColor: UIColor = .darkTorquoise
    var nonSelectedBackgroundColor: UIColor = UIColor.white
    var selectedBorderColor: UIColor = .darkTorquoise
    var nonSelectedBorderColor: UIColor = UIColor.lightSkyBlue
    var selectedTitleColor: UIColor = UIColor.white
    var noSelectedTitleColor: UIColor = .lisboaGray
}
