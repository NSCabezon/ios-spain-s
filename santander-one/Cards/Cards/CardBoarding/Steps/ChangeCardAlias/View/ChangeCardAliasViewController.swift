//
//  ChangeCardAliasViewController.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/5/20.
//

import CoreFoundationLib
import UI

protocol ChangeCardAliasViewProtocol: CardBoardingStepView, LoadingViewPresentationCapable, OldDialogViewPresentationCapable {
    func updateCardInformationWithViewModel(_ viewModel: PlasticCardViewModel)
}

final class ChangeCardAliasViewController: UIViewController {
    let presenter: ChangeCardAliasPresenterProtocol
    let bottomButtons = CardBoardingTabBar(frame: .zero)
    let keyboardManager = KeyboardManager()
    var isFirstStep: Bool = false
    @IBOutlet weak private var headingTitleLabel: UILabel!
    @IBOutlet weak private var aliasExplanationLabel: UILabel!
    @IBOutlet weak private var cardImageView: PlasticCardView!
    @IBOutlet weak private var aliasTextBox: LisboaTextField!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var topShadow: UIView!
    
    init(nibName: String?, bundle: Bundle?, presenter: ChangeCardAliasPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.aliasTextBox.setText(self.presenter.currentAlias)
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardManager.update()
        self.keyboardManager.setKeyboardButtonEnabled(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectNext() {
        self.presenter.changeCardAlias(self.aliasTextBox.text)
    }
    
    private func didSelectNextTextfield(_ textfield: EditText) {
        self.didSelectNext()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let textFieldText = self.aliasTextBox.fieldValue else { return }
        if textFieldText.isEmpty {
            self.aliasTextBox.setText(self.presenter.currentAlias)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.applyGradientBackground(colors: [.white, .skyGray, .white], locations: [0.0, 0.9, 0.2])
    }
}

extension ChangeCardAliasViewController: ChangeCardAliasViewProtocol {
    func updateCardInformationWithViewModel(_ viewModel: PlasticCardViewModel) {
        self.cardImageView.setViewModel(viewModel)
    }
}

private extension ChangeCardAliasViewController {
    var texfieldStyle: LisboaTextFieldStyle {
        var style = LisboaTextFieldStyle.default
        style.titleLabelFont = .santander(family: .text, type: .regular, size: 14)
        style.titleLabelTextColor = .brownishGray
        style.fieldFont = .santander(family: .text, type: .regular, size: 24)
        style.fieldTextColor = .lisboaGray
        style.containerViewBackgroundColor = .white
        return style
    }
    
    func setupUI() {
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false 
        self.keyboardManager.setDelegate(self)
        self.view.addSubview(bottomButtons)
        self.setupBottomButtons()
        self.setupTextField()
        self.setupLabels()
        self.registerObservers()
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }

    func setupTextField() {
        let textFieldFormmater = UIFormattedCustomTextField()
        textFieldFormmater.setAllowOnlyCharacters(.alias)
        textFieldFormmater.setMaxLength(maxLength: CardBoardingConstants.maxAliasChars)
        let configuration = LisboaTextField.WritableTextField(type: .floatingTitle,
                                                              formatter: textFieldFormmater,
                                                              disabledActions: [.paste],
                                                              keyboardReturnAction: nil, textfieldCustomizationBlock: self.customizationBlock(_:))
        let editingStyle = LisboaTextField.EditingStyle.writable(configuration: configuration)
        self.aliasTextBox.setEditingStyle(editingStyle)
        self.aliasTextBox.setPlaceholder(localized("cardBoarding_label_nameCard"))
        self.aliasTextBox.setStyle(texfieldStyle)
    }

    func customizationBlock(_ components: LisboaTextField.CustomizableComponents) {
        components.floatingLabel?.setSantanderTextFont(type: .regular, size: 14.0, color: .brownishGray)
        components.floatingLabel?.accessibilityIdentifier = AccessibilityCardBoarding.Alias.placeholder
        components.textField.accessibilityIdentifier = AccessibilityCardBoarding.Alias.textFieldAlias
    }
    
    func setupLabels() {
        let headingTitleFont: UIFont = .santander(family: .headline, type: .regular, size: 38.0)
        let aliasExplanationFont: UIFont = .santander(family: .text, type: .regular, size: 18.0)
        let headingTitleConfiguration = LocalizedStylableTextConfiguration(font: headingTitleFont,
                                                                           alignment: .natural,
                                                                           lineHeightMultiple: 0.75,
                                                                           lineBreakMode: .byWordWrapping)
        let aliasExplanationConfiguration = LocalizedStylableTextConfiguration(font: aliasExplanationFont,
                                                                               alignment: .left,
                                                                               lineHeightMultiple: 0.80,
                                                                               lineBreakMode: .byWordWrapping)
        self.headingTitleLabel.configureText(withKey: "cardBoarding_title_nameCard",
                                             andConfiguration: headingTitleConfiguration)
        self.headingTitleLabel.textColor = .black
        self.aliasExplanationLabel.configureText(withKey: "cardBoarding_text_nameCard",
                                                 andConfiguration: aliasExplanationConfiguration)
        self.aliasExplanationLabel.textColor = .lisboaGray
        self.headingTitleLabel.accessibilityIdentifier = AccessibilityCardBoarding.Alias.titleHeading
        self.aliasExplanationLabel.accessibilityIdentifier = AccessibilityCardBoarding.Alias.titleExplanationLabel
    }
    
    func setupBottomButtons() {
        self.bottomButtons.fitOnBottomWithHeight(72, andBottomSpace: 0)
        self.bottomButtons.addNextAction(target: self, selector: #selector(didSelectNext))
        self.bottomButtons.backButton.isHidden = self.isFirstStep
    }
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .none
        )
        
        builder.build(on: self, with: nil)
    }
}

extension ChangeCardAliasViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("cardBoarding_button_next"), accessibilityIdentifier: AccessibilityCardBoarding.Alias.keyboardInputButton, action: self.didSelectNextTextfield)
    }
    
    var associatedScrollView: UIScrollView? {
        return self.scrollView
    }
}

extension ChangeCardAliasViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
