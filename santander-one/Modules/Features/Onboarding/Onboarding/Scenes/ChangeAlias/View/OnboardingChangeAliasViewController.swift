//
//  OnboardingChangeAliasViewController.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UIKit
import UI
import OpenCombine
import IQKeyboardManagerSwift
import CoreFoundationLib

final class OnboardingChangeAliasViewController: UIViewController, StepIdentifiable {
    private let viewModel: OnboardingChangeAliasViewModel
    let dependencies: OnboardingChangeAliasDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let titleLabel = UILabel()
    private let textField = LisboaTextfield()
    private let markLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let shadowView = UIView()
    private let buttonsView = BottomActionsOnboardingView()
    private lazy var bottomConstraint = buttonsView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
    private var keyboardDistanceFromTextField: CGFloat = 0.0
    private let separatorLabelConstraint: CGFloat = 10.0
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: OnboardingChangeAliasDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        bind()
        registerObservers()
        setupTapGestureRecognizer()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.keyboardDistanceFromTextField = IQKeyboardManager.shared.keyboardDistanceFromTextField
        IQKeyboardManager.shared.keyboardDistanceFromTextField += self.buttonsView.frame.size.height + self.descriptionLabel.frame.size.height + self.separatorLabelConstraint
        self.viewModel.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = keyboardDistanceFromTextField
    }
}

private extension OnboardingChangeAliasViewController {
    func configView() {
        view.backgroundColor = .white
        addViews()
        configButtonsView()
        configScrollView()
        configScrollContentView()
        configTitleLabel()
        configTextField()
        configMarkLabel()
        configShadowView()
        configDescriptionLabel()
        configLabels()
    }
    
    func addViews() {
        view.addSubview(buttonsView)
        view.addSubview(scrollView)
        view.addSubview(shadowView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(titleLabel)
        scrollContentView.addSubview(textField)
        scrollContentView.addSubview(markLabel)
        scrollContentView.addSubview(descriptionLabel)
    }
    
    func configButtonsView() {
        buttonsView.setupViews()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            buttonsView.heightAnchor.constraint(equalToConstant: 72),
            bottomConstraint
        ])
    }
    
    func configScrollView() {
        scrollView.applyGradientBackground(colors: [UIColor.white, UIColor.skyGray])
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor)
        ])
    }
    
    func configScrollContentView() {
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func configTitleLabel() {
        titleLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                           font: .santander(size: 38),
                                           textAlignment: .left))
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 56),
            titleLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor)
        ])
    }
    
    func configTextField() {
        textField.field.autocapitalizationType = .none
        textField.field.returnKeyType = .done
        textField.setAllowOnlyCharacters(.alias)
        textField.setMaxCharacters(20)
        textField.accessibilityIdentifier = AccessibilityOnboarding.aliasInput
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    func configMarkLabel() {
        markLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                          font: .santander(family: .text, type: .light, size: 14),
                                          textAlignment: .left))
        markLabel.text = "*"
        markLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            markLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            markLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            markLabel.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configDescriptionLabel() {
        descriptionLabel.configureText(withKey: "onboarding_asteriskText_alias")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: markLabel.trailingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor)
        ])
    }
    
    func configShadowView() {
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.0
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            shadowView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: -1),
            shadowView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    var texfieldStyle: LisboaTextFieldStyle {
        var style = LisboaTextFieldStyle.default
        style.titleLabelFont = .santander(family: .text, type: .regular, size: 14)
        style.titleLabelTextColor = .brownishGray
        style.fieldFont = .santander(family: .text, type: .regular, size: 20)
        style.fieldTextColor = .lisboaGray
        return style
    }
    
    var textfieldTitle: String { localized("onboarding_label_alias").text }
    
    func configLabels() {
        buttonsView.continueText = localized("generic_button_continue")
        buttonsView.backText = localized("generic_button_previous")
        descriptionLabel.configureText(withKey: "onboarding_asteriskText_alias")
        titleLabel.configureText(withKey: "onboarding_title_yourName",
                                 andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        textField.configure(with: nil,
                            title: textfieldTitle,
                            style: texfieldStyle,
                            extraInfo: nil)
        descriptionLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                                 font: .santander(family: .text, type: .light, size: 14),
                                                 textAlignment: .left))
    }
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSizeHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height,
              let animationTime = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }
        editorWillShow(height: keyboardSizeHeight, time: animationTime)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationTime = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }
        editorWillHide(time: animationTime)
    }
    
    func editorWillShow(height: CGFloat, time: Double) {
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            bottomSafeArea = self.view.safeAreaInsets.bottom
        } else {
            bottomSafeArea = self.bottomLayoutGuide.length
        }
        if self.bottomConstraint.constant == 0 {
            self.bottomConstraint.constant -= height - bottomSafeArea
            UIView.animate(withDuration: time) {
                self.view.layoutSubviews()
            }
        }
    }
    
    func editorWillHide(time: Double) {
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: time) {
            self.view.layoutSubviews()
        }
        scrollView.scrollRectToVisible(scrollContentView.frame, animated: true)
    }
    
    func setupTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateTextfield(alias: String) {
        textField.updateData(text: alias)
    }
}

// MARK: - Binding
private extension OnboardingChangeAliasViewController {
    func bind() {
        bindNavigationItems()
        bindUserInfoLoaded()
        bindButtonsView()
    }
    
    func bindNavigationItems() {
        viewModel.state
            .case(OnboardingChangeAliasState.navigationItems)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.showOnboardingAbortButton(items.allowAbort, target: self, action: #selector(self.abortPressed))
                if let currentPosition = items.currentPosition, let total = items.total {
                    self.navigationController?.addOnboardingStepIndicatorBar(currentPosition: currentPosition, total: total)
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindUserInfoLoaded() {
        viewModel.state
            .case(OnboardingChangeAliasState.aliasLoaded)
            .sink { [weak self] alias in
                self?.configLabels()
                self?.updateTextfield(alias: alias)
            }
            .store(in: &subscriptions)
    }
    
    func bindButtonsView() {
        buttonsView.action
            .sink { [unowned self] value in
                switch value {
                case .back:
                    self.viewModel.didSelectBack()
                case .next:
                    self.goNext()
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc func abortPressed() {
        view.endEditing(true)
        onboardingAbortAction(response: viewModel.didAbortOnboarding)
    }
    
    func goNext() {
        guard let text = textField.text else { return }
        view.endEditing(true)
        let newAlias: String? = text.isEmpty || text.isBlank ? nil : text
        viewModel.didSelectNext(newAlias: newAlias)
    }
}

// MARK: - LoadingViewPresentationCapable
extension OnboardingChangeAliasViewController: LoadingViewPresentationCapable {}

// MARK: - GenericErrorDialogPresentationCapable
extension OnboardingChangeAliasViewController: GenericErrorDialogPresentationCapable {}

// MARK: - UIGestureRecognizerDelegate
extension OnboardingChangeAliasViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingChangeAliasViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.layer.shadowOpacity = scrollView.contentOffset.y > 0 ? 0.4 : 0
        shadowView.alpha = scrollView.contentOffset.y > 0.0 ? 0.4 : 0.0
    }
}
