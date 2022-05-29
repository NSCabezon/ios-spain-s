//
//  LanguageSelectorViewController.swift
//  PersonalArea
//
//  Created by alvola on 26/11/2019.
//

import UI
import UIKit
import CoreFoundationLib

protocol LanguageSelectorViewProtocol: UIViewController {
    var presenter: LanguageSelectorPresenterProtocol { get set }
    func setLanguages(_ values: [LanguageType])
    func setCurrentLanguage(_ language: LanguageType)
    func showAlert(_ message: LocalizedStylableText)
}

final class LanguageSelectorViewController: UIViewController, LanguageSelectorViewProtocol {

    var presenter: LanguageSelectorPresenterProtocol
    
    var currentLanguage: LanguageType?
    var currentSavedLanguage: LanguageType?
    
    private var languages: [LanguageType]?
    
    @IBOutlet private weak var stackView: LanguageOnboardingStackView?
    @IBOutlet private weak var separationView: UIView?
    @IBOutlet private weak var changeButton: WhiteLisboaButton?
    
    init(presenter: LanguageSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "LanguageSelectorViewController", bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.applyGradientBackground(colors: [.white, .bg])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    func setLanguages(_ values: [LanguageType]) {
        self.languages = values
        self.setStackViews()
    }
    
    func setCurrentLanguage(_ language: LanguageType) {
        self.currentSavedLanguage = language
        self.currentLanguage = language
    }
    
    func showAlert(_ message: LocalizedStylableText) {
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .failure)
    }
    
    // MARK: - privateMethods
    
    private func setStackViews() {
        self.stackView?.addValues(self.languages?.map({ (language) in
            let localizedLanguageName: LocalizedStylableText = localized(language.languageName)
            let isHighlighted = language == self.currentLanguage
            return ValueOptionType(value: language.languageName, displayableValue: language.languageName.camelCasedString, localizedValue: localizedLanguageName, isHighlighted: isHighlighted, action: { [weak self] in
                self?.setLanguage(language: language)
            })
        }) ?? [])
    }
    
    private func setLanguage(language: LanguageType) {
        self.currentLanguage = language
        self.stackView?.reloadValues(self.currentLanguage?.languageName ?? "")
    }
    
    private func commonInit() {
        self.configureView()
        self.configureButton()
    }
    
    private func configureView() {
        self.separationView?.backgroundColor = .mediumSky
    }
    
    private func configureButton() {
        self.changeButton?.setTitle(localized("personalArea_button_changeLanguage"), for: .normal)
        self.changeButton?.addSelectorAction(target: self, #selector(self.saveIfChanged))
        self.changeButton?.accessibilityIdentifier = AccesibilityConfigurationPersonalArea.changeLanguage
    }
    
    private func configureNavigationBar() {
        let style: NavigationBarBuilder.Style
        if #available(iOS 11.0, *) {
            style = .clear(tintColor: .santanderRed)
        } else {
            style = .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed)
        }
        let builder = NavigationBarBuilder(
            style: style,
            title: .title(key: "toolbar_title_language")
        )
        builder.setLeftAction(.back(action: #selector(self.backDidPress)))
        builder.setRightActions(.close(action: #selector(self.closeDidPress)))
        builder.build(on: self, with: nil)
    }
    
    @objc private func backDidPress() { presenter.backDidPress() }
    @objc private func closeDidPress() { presenter.closeDidPress() }
    
    @objc private func saveIfChanged() {
        if let currentLanguage = self.currentLanguage, currentLanguage != self.currentSavedLanguage {
            self.presenter.saveCurrentLanguage(currentLanguage)
        } else {
            self.presenter.backDidPress()
        }
    }
}

final class LanguageOnboardingStackView: UIStackView {
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
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        addSubview(self.stackView)
        self.stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func addValues(_ values: [ValueOptionType]) {
        self.optionValues = values
        self.clearOptions()
        let rowOptions = stride(from: 0, to: values.count, by: self.maxLanguagesPerLines).map { Array(values[$0..<min($0 + self.maxLanguagesPerLines, values.count)]) }
        for row in rowOptions {
            let emptyViewsCount = self.maxLanguagesPerLines - row.count
            let emptyViewArray = [ValueOptionType?](repeating: nil, count: emptyViewsCount)
            let options = LanguageRowStack()
            options.heightAnchor.constraint(equalToConstant: 96).isActive = true
            self.stackView.addArrangedSubview(options)
            options.addLanguages(row + emptyViewArray)
        }
    }
    
    private func clearOptions() {
        for case let view as LanguageRowStack in self.stackView.arrangedSubviews {
            view.clear()
            view.removeFromSuperview()
        }
    }
    
    func reloadValues(_ languageSelected: String) {
        self.optionValues.forEach { $0?.setHighlightedIfMatchesString(value: languageSelected) }
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
            self.setupView()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setupView()
        }
        
        func setupView() {
            addSubview(self.stackView)
            self.stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            self.stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        func addLanguages(_ values: [ValueOptionType?]) {
            self.optionValues = values
            for value in values {
                guard let value = value else {
                    stackView.addArrangedSubview(UIView())
                    continue
                }
                let button = LanguageOptionButton()
                button.setTitleColor(UIColor.gray, for: .normal)
                button.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
                button.titleLabel?.lineBreakMode = .byWordWrapping
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.textAlignment = .center
                button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
                button.drawRoundedAndShadowedNew()
                button.optionData = value
                button.set(localizedStylableText: value.localizedValue?.capitalizedBySentence() ?? LocalizedStylableText.empty, state: .normal)
                button.addTarget(self, action: #selector(optionPressed(_:)), for: .touchUpInside)
                self.stackView.addArrangedSubview(button)
            }
        }
        
        @objc func optionPressed(_ button: LanguageOptionButton) {
            let optionData = button.optionData
            optionData?.action?()
        }
        
        var count: Int {
            return self.stackView.arrangedSubviews.count
        }
        
        func clear() {
            for view in self.stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
    }
}

class ValueOptionType {
    let value: String
    let displayableValue: String
    var localizedValue: LocalizedStylableText?
    var action: (() -> Void)?
    var highlightAction: ((Bool) -> Void)? {
        didSet {
            self.highlightAction?(isHighlighted)
        }
    }
    var isHighlighted: Bool
    
    init(value: String, displayableValue: String, localizedValue: LocalizedStylableText?, isHighlighted: Bool = false, action: (() -> Void)? = nil) {
        self.action = action
        self.value = value
        self.displayableValue = displayableValue
        self.localizedValue = localizedValue
        self.highlightAction = nil
        self.isHighlighted = isHighlighted
    }
    
    func setHighlightedIfMatches(value: String?) {
        var rawText = value?.replacingOccurrences(of: ".", with: "")
        rawText = rawText?.replacingOccurrences(of: ",", with: ".")
        
        guard let value = rawText else {
            self.highlightAction?(false)
            self.isHighlighted = false
            return
        }
        let result = Decimal(string: value) == Decimal(string: self.value)
        self.isHighlighted = result
        self.highlightAction?(result)
    }
    
    func setHighlightedIfMatchesString(value: String?) {
        let result = value == self.value
        self.isHighlighted = result
        self.highlightAction?(result)
    }
}

class LanguageOptionButton: UIButton {
    var optionData: ValueOptionType? {
        didSet {
            self.optionData?.highlightAction = { [weak self] shouldHighlight in
                self?.isHighlighted = shouldHighlight
                self?.backgroundColor = shouldHighlight ? self?.selectedBackgroundColor : self?.nonSelectedBackgroundColor
                self?.layer.borderColor = shouldHighlight ? self?.selectedBorderColor.cgColor : self?.nonSelectedBorderColor.cgColor
                let titleColor = shouldHighlight ? self?.selectedTitleColor : self?.noSelectedTitleColor
                self?.setTitleColor(titleColor, for: .normal)
            }
        }
    }
    var selectedBackgroundColor: UIColor = .darkTorquoise
    var nonSelectedBackgroundColor: UIColor = UIColor.white
    var selectedBorderColor: UIColor = .darkTorquoise
    var nonSelectedBorderColor: UIColor = UIColor.mediumSkyGray
    var selectedTitleColor: UIColor = UIColor.white
    var noSelectedTitleColor: UIColor = .lisboaGray
}
