import UIKit
import UI
import CoreFoundationLib

class LanguageOnboardingStackView: UIStackView {
    let maxLanguagesPerLines = 3
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
        let rowOptions = stride(from: 0, to: values.count, by: maxLanguagesPerLines).map { Array(values[$0..<min($0 + maxLanguagesPerLines, values.count)])
        }
        for row in rowOptions {
            let emptyViewsCount = maxLanguagesPerLines - row.count
            let emptyViewArray = [ValueOptionType?](repeating: nil, count: emptyViewsCount)
            let options = LanguageRowStack()
            options.heightAnchor.constraint(equalToConstant: 96).isActive = true
            stackView.addArrangedSubview(options)
            options.addLanguages(row + emptyViewArray)
        }
    }
    
    private func clearOptions() {
        for case let view as LanguageRowStack in stackView.arrangedSubviews {
            view.clear()
            view.removeFromSuperview()
        }
    }
    
    func reloadValues(_ values: [ValueOptionType], _ languageSelected: String) {
        for option in self.optionValues {
            option?.setHighlightedIfMatchesString(value: languageSelected)
        }
    }
}

extension LanguageOnboardingStackView {
    
    class LanguageRowStack: UIView {
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
        
        func addLanguages(_ values: [ValueOptionType?]) {
            self.optionValues = values
            for value in values {
                guard let value = value else {
                    stackView.addArrangedSubview(UIView())
                    continue
                }
                let button = LanguageOptionButton()
                let style = ButtonStylist(textColor: UIColor.lisboaGrayNew, font: .santanderTextBold(size: 18))
                (button as UIButton).applyStyle(style)
                button.drawRoundedAndShadowedNew(radius: 5, borderColor: .mediumSky, widthOffSet: 0, heightOffSet: 2)
                button.optionData = value
                button.titleLabel?.lineBreakMode = .byWordWrapping
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.textAlignment = .center
                let languageName = value.localizedValue?.capitalizedBySentence() ?? LocalizedStylableText.empty
                button.set(localizedStylableText: languageName, state: .normal)
                button.accessibilityIdentifier = AccessibilityOnboardingOptions.personalAreaBtnLanguage + languageName.text
                button.addTarget(self, action: #selector(optionPressed(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
        }
        
        @objc func optionPressed(_ button: LanguageOptionButton) {
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
