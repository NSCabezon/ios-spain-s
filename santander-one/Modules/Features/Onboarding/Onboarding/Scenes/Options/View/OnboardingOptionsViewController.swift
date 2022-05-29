//
//  OnboardingOptionsViewController.swift
//  Onboarding
//
//  Created by Jose Hidalgo on 07/01/22.
//

import UI
import UIKit
import CoreDomain
import CoreFoundationLib
import Foundation
import Localization
import OpenCombine

final class OnboardingOptionsViewController: UIViewController, StepIdentifiable, SystemSettingsNavigatable {
    private let viewModel: OnboardingOptionsViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingOptionsDependenciesResolver
    private let titleLabel = UILabel()
    private let optionsStackView = OptionsOnboardingStackView()
    private var buttonsView = BottomActionsOnboardingView()
    private let scrollContentView = UIView()
    private let scrollView = UIScrollView()
    private let shadowView = UIView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: OnboardingOptionsDependenciesResolver) {
        self.dependencies = dependencies
        viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        bind()
        addAppBecomeActiveObserver()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewAppearance()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - Binding
private extension OnboardingOptionsViewController {
    func bind() {
        bindState()
        bindButtonsView()
    }
    
    func bindState() {
        viewModel.state
            .sink { [weak self] state in
                guard case .hideLoading = state else { return }
                self?.dismissLoading()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingOptionsState.showLoading)
            .sink { [weak self] loading in
                self?.showLoading(title: localized(loading.titleKey), subTitle: localized(loading.subtitleKey), completion: {})
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingOptionsState.navigationItems)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.showOnboardingAbortButton(items.allowAbort, target: self, action: #selector(self.abortPressed))
                if let currentPosition = items.currentPosition, let total = items.total {
                    self.navigationController?.addOnboardingStepIndicatorBar(currentPosition: currentPosition, total: total)
                }
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingOptionsState.showAlert)
            .sink { [weak self] alert in
                self?.showAlert(alert)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingOptionsState.settings)
            .sink { [weak self] _ in
                self?.navigateToSettings()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingOptionsState.loadSections)
            .sink { [weak self] sections in
                self?.loadSections(sections: sections)
            }.store(in: &subscriptions)
    }
    
    func bindButtonsView() {
        buttonsView.action
            .sink { [unowned self] value in
                switch value {
                case .back:
                    self.viewModel.didSelectBack()
                case .next:
                    self.viewModel.didSelectNext()
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Configuration
private extension OnboardingOptionsViewController {
    func configView() {
        view.backgroundColor = UIColor.white
        configScrollView()
        configTitleLabel()
        configButtonsView()
        configOptionsStackView()
        configShadowView()
        configViewTexts()
        addViews()
        configConstraints()
    }
    
    func configScrollView() {
        scrollView.applyGradientBackground(colors: [UIColor.white, UIColor.skyGray])
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
    }
    
    func configTitleLabel() {
        let font = UIFont.santander(family: .headline, type: .regular, size: 38)
        titleLabel.applyStyle(LabelStylist(textColor: .black, font: font))
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configOptionsStackView() {
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configButtonsView() {
        buttonsView.setupViews()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configShadowView() {
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.0
        shadowView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configViewTexts() {
        let configuration = LocalizedStylableTextConfiguration(alignment: .left, lineHeightMultiple: 0.85)
        titleLabel.configureText(withLocalizedString: localized("onboarding_text_nowOptions"), andConfiguration: configuration)
        buttonsView.continueText = localized("generic_button_continue")
        buttonsView.backText = localized("generic_button_previous")
    }
    
    func addViews() {
        scrollContentView.addSubview(titleLabel)
        scrollContentView.addSubview(optionsStackView)
        scrollView.addSubview(scrollContentView)
        view.addSubview(scrollView)
        view.addSubview(buttonsView)
        view.addSubview(shadowView)
    }
    
    func configConstraints() {
        configScrollViewConstraints()
        configTitleLabelConstraints()
        configOptionsStackViewConstraints()
        configButtonsViewConstraints()
        configShadowViewConstraints()
    }
    
    func configScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsView.topAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func configTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -24)
        ])
    }
    
    func configOptionsStackViewConstraints() {
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -24),
            optionsStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20)
        ])
    }
    
    func configButtonsViewConstraints() {
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            buttonsView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    func configShadowViewConstraints() {
        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            shadowView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: -1),
            shadowView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

private extension OnboardingOptionsViewController {
    func loadSections(sections: [OnboardingStackSection]) {
        optionsStackView.reloadSections(sections: sections)
    }
    
    func showAlert(_ alert: OnboardingOptionsStateAlert) {
        switch alert {
        case let .common(common):
            self.showAlertCommon(common)
        case let .prompt(prompt):
            self.showAlertPrompt(prompt)
        case let .top(top):
            self.showAlertTop(top)
        }
    }
    
    func showAlertCommon(_ alert: OnboardingOptionsStateAlertCommon) {
        let title: LocalizedStylableText?
        if let titleKey = alert.titleKey {
            title = localized(titleKey)
        } else {
            title = nil
        }
        let body: LocalizedStylableText = localized(alert.bodyKey)
        let acceptComponent = DialogButtonComponents(titled: localized(alert.acceptKey), does: alert.acceptAction)
        let cancelComponent: DialogButtonComponents?
        if let cancelKey = alert.cancelKey {
            cancelComponent = DialogButtonComponents(titled: localized(cancelKey), does: alert.cancelAction)
        } else {
            cancelComponent = nil
        }
        OldDialog.alert(title: title,
                        body: body,
                        withAcceptComponent: acceptComponent,
                        withCancelComponent: cancelComponent,
                        source: self)
    }
    
    func showAlertPrompt(_ alert: OnboardingOptionsStateAlertPrompt) {
        let builder = PromptDialogBuilder(info: alert.info, identifiers: alert.identifiers)
        LisboaDialog(items: builder.build(), closeButtonAvailable: alert.closeButtonAvailable).showIn(self)
    }
    
    func showAlertTop(_ alert: OnboardingOptionsStateAlertTop) {
        let controller = TopAlertController.setup(TopAlertView.self)
        let message: LocalizedStylableText = localized(alert.messageKey)
        controller.showAlert(message, alertType: alert.type.toTopAlertType, duration: alert.duration)
    }
    
    @objc func abortPressed() {
        onboardingAbortAction(response: viewModel.didAbortOnboarding)
    }
    
    func addAppBecomeActiveObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(configureViewAppearance),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc func configureViewAppearance() {
        viewModel.viewWillAppear()
    }
}

// MARK: - LoadingViewPresentationCapable
extension OnboardingOptionsViewController: LoadingViewPresentationCapable {}

// MARK: - GenericErrorDialogPresentationCapable
extension OnboardingOptionsViewController: GenericErrorDialogPresentationCapable {}

// MARK: - ToolTip
extension OnboardingOptionsViewController: ToolTipBackView {
}

// MARK: - UIScrollViewDelegate
extension OnboardingOptionsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.layer.shadowOpacity = scrollView.contentOffset.y > 0 ? 0.4 : 0
        shadowView.alpha = scrollView.contentOffset.y > 0.0 ? 0.4 : 0.0
    }
}
