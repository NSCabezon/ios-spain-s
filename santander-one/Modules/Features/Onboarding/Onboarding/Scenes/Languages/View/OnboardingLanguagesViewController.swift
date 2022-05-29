//
//  OnboardingLanguagesViewController.swift
//  Onboarding
//
//  Created by Jose Camallonga on 9/12/21.
//

import UI
import UIKit
import Foundation
import Localization
import CoreFoundationLib
import OpenCombine

final class OnboardingLanguagesViewController: UIViewController, StepIdentifiable {
    private let viewModel: OnboardingLanguagesViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingLanguagesDependenciesResolver
    private let titleLabel = UILabel()
    private let languagesStackView = LanguageOnboardingStackView()
    private let buttonsView = BottomActionsOnboardingView()
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
    
    init(dependencies: OnboardingLanguagesDependenciesResolver) {
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
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

// MARK: - Binding
private extension OnboardingLanguagesViewController {
    func bind() {
        bindState()
        bindButtonsView()
    }
    
    func bindState() {
        viewModel.state
            .case(OnboardingLanguagesState.hideLoading)
            .sink { [weak self] _ in
                self?.dismissLoading { [weak self] in
                    self?.viewModel.didHideLoading()
                }
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingLanguagesState.navigationItems)
            .sink { [weak self] items in
                self?.setNavigationItems(items)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingLanguagesState.showLoading)
            .sink { [weak self] loading in
                self?.showLoading(title: localized(loading.titleKey),
                                  subTitle: localized(loading.subtitleKey),
                                  completion: { [weak self] in
                    self?.viewModel.didShowLoading()
                })
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingLanguagesState.showErrorAlert)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.showGenericErrorDialog(withDependenciesResolver: self.dependencies.external.resolve())
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingLanguagesState.reloadContent)
            .sink { [weak self] _ in
                self?.configViewTexts()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingLanguagesState.values)
            .sink { [weak self] values in
                self?.setLanguagesStackView(values: values)
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

// MARK: - Private
private extension OnboardingLanguagesViewController {
    func showErrorAlert(_ alert: OnboardingLanguagesStateAlert) {
        switch alert {
        case let .common(error):
            let accept = DialogButtonComponents(titled: localized(error.acceptKey), does: nil)
            OldDialog.alert(title: nil,
                            body: localized(error.bodyKey),
                            withAcceptComponent: accept,
                            withCancelComponent: nil,
                            source: self)
        case .generic:
            self.showGenericErrorDialog(withDependenciesResolver: self.dependencies.external.resolve())
        }
    }
}

// MARK: - Configuration
private extension OnboardingLanguagesViewController {
    func configView() {
        view.backgroundColor = UIColor.white
        configScrollView()
        configTitleLabel()
        configButtonsView()
        configLanguagesStackView()
        configShadowView()
        configViewTexts()
        addViews()
        configConstraints()
    }
    
    func configScrollView() {
        scrollView.applyGradientBackground(colors: [UIColor.white, UIColor.skyGray])
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func configTitleLabel() {
        let font = UIFont.santander(family: .headline, type: .regular, size: 38)
        titleLabel.applyStyle(LabelStylist(textColor: .black, font: font))
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configLanguagesStackView() {
        languagesStackView.translatesAutoresizingMaskIntoConstraints = false
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
        titleLabel.configureText(withLocalizedString: localized("onboarding_title_selectLanguage"), andConfiguration: configuration)
        buttonsView.continueText = localized("generic_button_continue")
        buttonsView.backText = localized("generic_button_previous")
    }
    
    func addViews() {
        scrollContentView.addSubview(titleLabel)
        scrollContentView.addSubview(languagesStackView)
        scrollView.addSubview(scrollContentView)
        view.addSubview(scrollView)
        view.addSubview(buttonsView)
        view.addSubview(shadowView)
    }
    
    func configConstraints() {
        configScrollViewConstraints()
        configTitleLabelConstraints()
        configLanguagesStackViewConstraints()
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
    
    func configLanguagesStackViewConstraints() {
        NSLayoutConstraint.activate([
            languagesStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            languagesStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 24),
            languagesStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -24),
            languagesStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -20)
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
    
    func setLanguagesStackView(values: OnboardingLanguagesStateValues) {
        if let languageName = values.languageSelected?.languageName {
            self.languagesStackView.reloadValues(values.items, languageName)
        } else {
            self.languagesStackView.addValues(values.items)
        }
    }
    
    func setNavigationItems(_ items: OnboardingLanguagesStateNavigationItems) {
        showOnboardingAbortButton(items.allowAbort, target: self, action: #selector(abortPressed))
        if let currentPosition = items.currentPosition, let total = items.total {
            navigationController?.addOnboardingStepIndicatorBar(currentPosition: currentPosition, total: total)
        }
    }
    
    @objc func abortPressed() {
        onboardingAbortAction(response: viewModel.didAbortOnboarding)
    }
}

// MARK: - LoadingViewPresentationCapable
extension OnboardingLanguagesViewController: LoadingViewPresentationCapable {}

// MARK: - GenericErrorDialogPresentationCapable
extension OnboardingLanguagesViewController: GenericErrorDialogPresentationCapable {}

// MARK: - UIScrollViewDelegate
extension OnboardingLanguagesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.layer.shadowOpacity = scrollView.contentOffset.y > 0 ? 0.4 : 0
        shadowView.alpha = scrollView.contentOffset.y > 0.0 ? 0.4 : 0.0
    }
}
