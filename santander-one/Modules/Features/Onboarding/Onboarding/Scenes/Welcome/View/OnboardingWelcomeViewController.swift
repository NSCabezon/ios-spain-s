//
//  OnboardingWelcomeViewController.swift
//  Onboarding
//
//  Created by Jose Camallonga on 2/12/21.
//

import UI
import UIKit
import Foundation
import Localization
import OpenCombine
import CoreFoundationLib

final class OnboardingWelcomeViewController: UIViewController, StepIdentifiable, LoadingViewPresentationCapable {
    private let viewModel: OnboardingWelcomeViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingWelcomeDependenciesResolver
    private let santanderLogo = UIImageView()
    private let welcomeUserLabel = UILabel()
    private let welcomeTextLabel = UILabel()
    private let areYouReadyLabel = UILabel()
    private let changeAliasLabel = UILabel()
    private let continueButtonView = UIView()
    private let continueButton = RedLisboaButton()
    private lazy var welcomeTextAliasTopConstraint = welcomeTextLabel.topAnchor.constraint(equalTo: changeAliasLabel.bottomAnchor, constant: 38)
    private lazy var welcomeTextUserTopConstraint = welcomeTextLabel.topAnchor.constraint(equalTo: welcomeUserLabel.bottomAnchor, constant: 19)
    private lazy var logoBottomConstraint = welcomeUserLabel.topAnchor.constraint(equalTo: santanderLogo.bottomAnchor, constant: 30)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: OnboardingWelcomeDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
        self.bind()
        self.viewModel.viewDidLoad()
        self.hidePreviousLoading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setPopGestureEnabled(false)
        self.viewModel.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setPopGestureEnabled(true)
    }
}

// MARK: - Binding
private extension OnboardingWelcomeViewController {
    func bind() {
        bindUserInfoLoaded()
        bindUserInfoNotLoaded()
        bindNavigationItems()
    }
    
    func bindUserInfoLoaded() {
        viewModel.state
            .case(OnboardingWelcomeState.userInfoLoaded)
            .sink { [weak self] userName in
                self?.showUserName(userName)
            }
            .store(in: &subscriptions)
    }
    
    func bindUserInfoNotLoaded() {
        viewModel.state
            .case(OnboardingWelcomeState.userInfoNotLoaded)
            .sink { [weak self] _ in
                self?.showEmpty()
                self?.changeWelcomeLabelConstraints()
            }
            .store(in: &subscriptions)
    }
    
    func bindNavigationItems() {
        viewModel.state
            .case(OnboardingWelcomeState.navigationItems)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.showOnboardingAbortButton(items.allowAbort, target: self, action: #selector(self.abortPressed))
                if let currentPosition = items.currentPosition, let total = items.total {
                    self.navigationController?.addOnboardingStepIndicatorBar(currentPosition: currentPosition, total: total)
                }
            }
            .store(in: &subscriptions)
    }
    
    func showUserName(_ userName: String) {
        let title = localized("onboarding_title_hello", [StringPlaceholder(StringPlaceholder.Placeholder.name, userName)])
        let configuration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75, lineBreakMode: .byTruncatingTail)
        self.welcomeUserLabel.configureText(withLocalizedString: title, andConfiguration: configuration)
        self.welcomeTextLabel.configureText(withLocalizedString: localized("onboarding_text_welcome"))
        self.changeAliasLabel.configureText(withLocalizedString: localized("onboarding_text_callMeAnotherWay"))
        self.areYouReadyLabel.configureText(withLocalizedString: localized("onboarding_text_ready"))
        self.continueButton.set(localizedStylableText: localized("onboarding_button_customize"), state: .normal)
        self.logoBottomConstraint.constant = 30
        self.welcomeTextUserTopConstraint.isActive = false
        self.welcomeTextAliasTopConstraint.isActive = true
        self.changeAliasLabel.isHidden = false
        self.welcomeUserLabel.accessibilityIdentifier = "onboarding_text_welcome"
        self.view.layoutIfNeeded()
    }
    
    func showEmpty() {
        let title: LocalizedStylableText = localized("onboarding_title_welcome")
        let configuration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75, lineBreakMode: .byTruncatingTail)
        self.welcomeUserLabel.configureText(withLocalizedString: title, andConfiguration: configuration)
        self.welcomeTextLabel.configureText(withLocalizedString: localized("onboarding_text_welcome"))
        self.changeAliasLabel.configureText(withLocalizedString: localized("onboarding_text_callMeAnotherWay"))
        self.areYouReadyLabel.configureText(withLocalizedString: localized("onboarding_text_ready"))
        self.continueButton.set(localizedStylableText: localized("onboarding_button_customize"), state: .normal)
        self.logoBottomConstraint.constant = 39
        self.welcomeTextUserTopConstraint.isActive = true
        self.welcomeTextAliasTopConstraint.isActive = false
        self.changeAliasLabel.isHidden = true
        self.welcomeUserLabel.accessibilityIdentifier = "onboarding_title_hello"
        self.view.layoutIfNeeded()
    }
    
    func hidePreviousLoading() {
        guard LoadingCreator.isCurrentlyLoadingShowing() else { return }
        dismissLoading()
    }
}

// MARK: - Actions
private extension OnboardingWelcomeViewController {
    @objc func buttonTouched() {
        viewModel.didSelectNext()
    }
    
    @objc func changeAliasAction() {
        viewModel.didSelectChangeAlias()
    }
    
    @objc func abortPressed() {
        onboardingAbortAction(response: viewModel.didAbortOnboarding)
    }
}

// MARK: - Configuration
private extension OnboardingWelcomeViewController {
    func configView() {
        self.view.backgroundColor = UIColor.white
        self.configSantanderLogo()
        self.configWelcomeTextLabel()
        self.configWelcomeUserLabel()
        self.configChangeAliasLabel()
        self.configAreYouReadyLabel()
        self.configContinueButton()
        self.addViews()
        self.configConstraints()
    }
    
    func configSantanderLogo() {
        self.santanderLogo.image = Assets.image(named: "icnSanRedComplete")
        self.santanderLogo.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configWelcomeTextLabel() {
        let text: LocalizedStylableText = localized("onboarding_text_welcome")
        let configuration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85, lineBreakMode: .byTruncatingTail)
        let font = UIFont.santander(family: .text, type: .light, size: 24)
        self.welcomeTextLabel.configureText(withLocalizedString: text, andConfiguration: configuration)
        self.welcomeTextLabel.applyStyle(LabelStylist(textColor: UIColor.lisboaGray, font: font, textAlignment: .left))
        self.welcomeTextLabel.numberOfLines = 0
        self.welcomeTextLabel.minimumScaleFactor = 0.5
        self.welcomeTextLabel.adjustsFontSizeToFitWidth = true
        self.welcomeTextLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configWelcomeUserLabel() {
        let font = UIFont.santander(family: .headline, type: .regular, size: 48)
        self.welcomeUserLabel.applyStyle(LabelStylist(textColor: UIColor.black, font: font, textAlignment: .left))
        self.welcomeUserLabel.numberOfLines = 0
        self.welcomeUserLabel.numberOfLines = 2
        self.welcomeUserLabel.adjustsFontSizeToFitWidth = true
        self.welcomeUserLabel.minimumScaleFactor = 0.1
        self.welcomeUserLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configChangeAliasLabel() {
        let font = UIFont.santander(family: .text, type: .regular, size: 15)
        self.changeAliasLabel.applyStyle(LabelStylist(textColor: UIColor.santanderRed, font: font, textAlignment: .left))
        self.changeAliasLabel.configureText(withLocalizedString: localized("onboarding_text_callMeAnotherWay"))
        self.changeAliasLabel.isUserInteractionEnabled = true
        self.changeAliasLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAliasAction)))
        self.changeAliasLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configAreYouReadyLabel() {
        self.areYouReadyLabel.configureText(withLocalizedString: localized("onboarding_text_ready"))
        let font = UIFont.santander(family: .text, type: .bold, size: 24)
        self.areYouReadyLabel.applyStyle(LabelStylist(textColor: UIColor.lisboaGray, font: font, textAlignment: .left))
        self.areYouReadyLabel.minimumScaleFactor = 0.5
        self.areYouReadyLabel.adjustsFontSizeToFitWidth = true
        self.areYouReadyLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configContinueButton() {
        self.continueButton.set(localizedStylableText: localized("onboarding_button_customize"), state: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(buttonTouched))
        self.continueButton.translatesAutoresizingMaskIntoConstraints = false
        self.continueButtonView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addViews() {
        self.view.addSubview(santanderLogo)
        self.view.addSubview(welcomeUserLabel)
        self.view.addSubview(welcomeTextLabel)
        self.view.addSubview(areYouReadyLabel)
        self.view.addSubview(changeAliasLabel)
        self.view.addSubview(continueButtonView)
        self.continueButtonView.addSubview(continueButton)
    }
    
    func configConstraints() {
        configLogoConstraints()
        configWelcomeUserLabelConstraints()
        configWelcomeTextConstraints()
        configChangeAliasLabelConstraints()
        configContinueButtonConstraints()
        configAreYouReadyLabelConstraints()
        self.welcomeTextUserTopConstraint.isActive = true
        self.welcomeTextAliasTopConstraint.isActive = false
        self.changeAliasLabel.isHidden = true
    }
    
    func configLogoConstraints() {
        NSLayoutConstraint.activate([
            self.santanderLogo.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: 24),
            self.santanderLogo.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 26),
            self.santanderLogo.trailingAnchor.constraint(lessThanOrEqualTo: self.view.safeTrailingAnchor, constant: -26),
            self.logoBottomConstraint
        ])
    }
    
    func configWelcomeUserLabelConstraints() {
        NSLayoutConstraint.activate([
            self.welcomeUserLabel.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 26),
            self.welcomeUserLabel.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -26)
        ])
    }
    
    func configWelcomeTextConstraints() {
        NSLayoutConstraint.activate([
            self.welcomeTextLabel.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 26),
            self.welcomeTextLabel.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -26)
        ])
    }
    
    func configChangeAliasLabelConstraints() {
        NSLayoutConstraint.activate([
            self.changeAliasLabel.topAnchor.constraint(equalTo: welcomeUserLabel.bottomAnchor, constant: -5),
            self.changeAliasLabel.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 26),
            self.changeAliasLabel.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -26)
        ])
    }
    
    func configAreYouReadyLabelConstraints() {
        NSLayoutConstraint.activate([
            self.areYouReadyLabel.topAnchor.constraint(equalTo: welcomeTextLabel.bottomAnchor, constant: 6),
            self.areYouReadyLabel.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 26),
            self.areYouReadyLabel.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -26)
        ])
    }
    
    func configContinueButtonConstraints() {
        NSLayoutConstraint.activate([
            self.continueButtonView.topAnchor.constraint(greaterThanOrEqualTo: areYouReadyLabel.bottomAnchor, constant: 0),
            self.continueButtonView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor),
            self.continueButtonView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor),
            self.continueButtonView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor),
            self.continueButtonView.heightAnchor.constraint(equalToConstant: 80),
            self.continueButton.leadingAnchor.constraint(equalTo: continueButtonView.leadingAnchor, constant: 20),
            self.continueButton.trailingAnchor.constraint(equalTo: continueButtonView.trailingAnchor, constant: -20),
            self.continueButton.heightAnchor.constraint(equalToConstant: 40),
            self.continueButton.bottomAnchor.constraint(equalTo: continueButtonView.bottomAnchor, constant: -20)
        ])
    }
    
    func changeWelcomeLabelConstraints() {
        let welcomeTitle: LocalizedStylableText = localized("onboarding_title_welcome")
        let configuration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85, lineBreakMode: .byTruncatingTail)
        self.welcomeUserLabel.configureText(withLocalizedString: welcomeTitle, andConfiguration: configuration)
        self.changeAliasLabel.constraints.forEach(self.changeAliasLabel.removeConstraint)
        self.welcomeTextLabel.topAnchor.constraint(equalTo: self.welcomeUserLabel.bottomAnchor, constant: 19.0).isActive = true
        self.changeAliasLabel.isHidden = true
        self.logoBottomConstraint.constant = 39
    }
}
