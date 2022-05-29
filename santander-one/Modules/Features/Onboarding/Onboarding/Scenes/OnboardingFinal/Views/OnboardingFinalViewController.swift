//
//  OnboardingFinalViewController.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 21/12/21.
//

import UI
import UIKit
import Foundation
import Localization
import OpenCombine
import CoreFoundationLib

final class OnboardingFinalViewController: UIViewController, StepIdentifiable {
    private let viewModel: OnboardingFinalViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingFinalDependenciesResolver
    private let logoImage = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileView = UIView()
    private let profileTitleLabel = UILabel()
    private let profileDescriptionLabel = UILabel()
    private let profileProgressView = UIView()
    private let profileProgressCurrentView = UIView()
    private let profileProgressLabel = UILabel()
    private let profileActionLabel = UILabel()
    private let bottomActionsView = BottomActionsOnboardingView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: OnboardingFinalDependenciesResolver) {
        self.dependencies = dependencies
        viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear()
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
private extension OnboardingFinalViewController {
    func bind() {
        bindState()
        bindBottomActionsView()
    }
    func bindState() {
        viewModel.state
            .case(OnboardingFinalState.hideLoading)
            .sink { [weak self] _ in
                self?.dismissLoading()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingFinalState.showLoading)
            .sink { [weak self] loading in
                self?.showLoading(title: localized(loading.titleKey), subTitle: localized(loading.subtitleKey), completion: {})
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingFinalState.digitalProfile)
            .sink { [weak self] percentageCompleted in
                self?.setDigitalProfile(percentage: percentageCompleted)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingFinalState.navigationItems)
            .sink { [weak self] items in
                self?.setNavigationItems(items)
            }.store(in: &subscriptions)
    }
    
    func bindBottomActionsView() {
        bottomActionsView.action
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
private extension OnboardingFinalViewController {
    func setNavigationItems(_ items: OnboardingFinalStateNavigationItems) {
        showOnboardingAbortButton(items.allowAbort, target: self, action: #selector(abortPressed))
        if let currentPosition = items.currentPosition, let total = items.total {
            navigationController?.addOnboardingStepIndicatorBar(currentPosition: currentPosition, total: total)
        }
    }
    
    @objc func abortPressed() {
        onboardingAbortAction(response: viewModel.didAbortOnboarding)
    }
}

// MARK: - Configuration
private extension OnboardingFinalViewController {
    func configView() {
        view.backgroundColor = UIColor.white
        configLogo()
        configTitleLabel()
        configSubtitleLabel()
        configDescriptionLabel()
        configDigitalProfileView()
        configBottomActionsView()
        addViews()
        configConstraints()
    }
    
    func configLogo() {
        logoImage.image = Assets.image(named: "icnSanRedInfo")
        logoImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = .black
        let font = UIFont.santander(family: .headline, type: .regular, size: 48)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left,
                                                               lineHeightMultiple: 0.8,
                                                               lineBreakMode: .byClipping)
        titleLabel.configureText(withKey: "onboarding_title_brilliant",
                                 andConfiguration: configuration)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configSubtitleLabel() {
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.lineBreakMode = .byClipping
        subtitleLabel.textColor = .black
        let font = UIFont.santander(family: .headline, type: .regular, size: 24)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left)
        subtitleLabel.configureText(withKey: "onboarding_subtitle_finishedApp",
                                    andConfiguration: configuration)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configDescriptionLabel() {
        descriptionLabel.numberOfLines = 0
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.5
        descriptionLabel.lineBreakMode = .byClipping
        descriptionLabel.textColor = .lisboaGray
        let font = UIFont.santander(family: .text, type: .light, size: 16)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left,
                                                               lineHeightMultiple: 0.85)
        descriptionLabel.configureText(withKey: "onboarding_text_selectHelp",
                                       andConfiguration: configuration)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configDigitalProfileView() {
        configProfileView()
        configProfileTitleLabel()
        configProfileDescriptionLabel()
        configProfileActionLabel()
        configProfileProgressView()
        configProfileProgressCurrentView()
        configProfileProgressLabel()
    }
    
    func configProfileView() {
        profileView.backgroundColor = .white
        profileView.drawShadow(offset: (0, 2), opacity: 0.7, color: .lightSanGray, radius: 3.0)
        profileView.drawBorder(cornerRadius: 6.0, color: .mediumSkyGray)
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedContinueDigitalProfile)))
        profileView.isUserInteractionEnabled = true
        profileView.isHidden = true
        profileView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configProfileTitleLabel() {
        profileTitleLabel.numberOfLines = 0
        profileTitleLabel.adjustsFontSizeToFitWidth = true
        profileTitleLabel.minimumScaleFactor = 0.5
        profileTitleLabel.lineBreakMode = .byClipping
        profileTitleLabel.textColor = .black
        let font = UIFont.santander(family: .headline, type: .regular, size: 19)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left)
        profileTitleLabel.configureText(withKey: "onboarding_text_configureApp",
                                        andConfiguration: configuration)
        profileTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configProfileDescriptionLabel() {
        profileDescriptionLabel.numberOfLines = 0
        profileDescriptionLabel.adjustsFontSizeToFitWidth = true
        profileDescriptionLabel.minimumScaleFactor = 0.5
        profileDescriptionLabel.lineBreakMode = .byClipping
        profileDescriptionLabel.textColor = .lisboaGray
        let font = UIFont.santander(family: .text, type: .light, size: 16)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left,
                                                               lineHeightMultiple: 0.85)
        profileDescriptionLabel.configureText(withKey: "onboarding_text_personaliseApp",
                                              andConfiguration: configuration)
        profileDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configProfileActionLabel() {
        profileTitleLabel.textColor = .santanderRed
        let font = UIFont.santander(family: .text, type: .regular, size: 14)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .right)
        profileActionLabel.configureText(withKey: "generic_button_continue",
                                         andConfiguration: configuration)
        profileActionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configProfileProgressView() {
        profileProgressView.layer.cornerRadius = (profileProgressView.frame.height) / 2.0
        profileProgressView.backgroundColor = .silverDark
        profileProgressView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configProfileProgressCurrentView() {
        profileProgressCurrentView.layer.cornerRadius = (profileProgressCurrentView.frame.height) / 2.0
        profileProgressCurrentView.backgroundColor = .darkTorquoise
        profileProgressCurrentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configProfileProgressLabel() {
        let font = UIFont.santander(family: .text, type: .light, size: 12)
        profileProgressLabel.applyStyle(LabelStylist(textColor: .lisboaGray,
                                                     font: font,
                                                     textAlignment: .left))
        profileProgressLabel.text = "0%"
        profileProgressLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configBottomActionsView() {
        bottomActionsView.setupViews(true)
        bottomActionsView.continueText = localized("onboarding_button_globalPosition")
        bottomActionsView.backText = localized("generic_button_previous")
        bottomActionsView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addViews() {
        view.addSubview(logoImage)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(descriptionLabel)
        profileView.addSubview(profileTitleLabel)
        profileView.addSubview(profileDescriptionLabel)
        profileView.addSubview(profileActionLabel)
        profileView.addSubview(profileProgressView)
        profileView.addSubview(profileProgressCurrentView)
        profileView.addSubview(profileProgressLabel)
        view.addSubview(profileView)
        view.addSubview(bottomActionsView)
    }
    
    func configConstraints() {
        configLogoConstraints()
        configTitleLabelConstraints()
        configSubtitleLabelConstraints()
        configDescriptionLabelConstraints()
        configDigitalProfileConstraints()
        configButtonsViewConstraints()
    }
    
    func configLogoConstraints() {
        let logoTopAlt = logoImage.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 54.0)
        logoTopAlt.priority = UILayoutPriority(rawValue: 750)
        NSLayoutConstraint.activate([
            logoTopAlt,
            logoImage.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 27.0),
            logoImage.widthAnchor.constraint(equalToConstant: 41.0),
            logoImage.heightAnchor.constraint(equalToConstant: 38.0),
            logoImage.topAnchor.constraint(greaterThanOrEqualTo: view.safeTopAnchor, constant: 27.0)
        ])
    }
    
    func configTitleLabelConstraints() {
        let logoBottomAlt = titleLabel.topAnchor.constraint(greaterThanOrEqualTo: logoImage.bottomAnchor, constant: 35.0)
        logoBottomAlt.priority = UILayoutPriority(rawValue: 900)
        NSLayoutConstraint.activate([
            logoBottomAlt,
            titleLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 20.0),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 24.0),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -24.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 56.0)
        ])
    }
    
    func configSubtitleLabelConstraints() {
        let subtitleTopAlt = subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0)
        subtitleTopAlt.priority = UILayoutPriority(rawValue: 900)
        NSLayoutConstraint.activate([
            subtitleTopAlt,
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 8.0),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 64.0)
        ])
    }
    
    func configDescriptionLabelConstraints() {
        let descriptionTopAlt = descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor)
        descriptionTopAlt.priority = UILayoutPriority(rawValue: 750)
        NSLayoutConstraint.activate([
            descriptionTopAlt,
            descriptionLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 6.0),
            descriptionLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 150.0)
        ])
    }
    
    func configDigitalProfileConstraints() {
        let digitalProfileHeightAlt = profileView.heightAnchor.constraint(equalToConstant: 128)
        digitalProfileHeightAlt.priority = UILayoutPriority(rawValue: 700)
        let digitalProfileLeadingAlt = profileView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor)
        digitalProfileLeadingAlt.priority = UILayoutPriority(rawValue: 990)
        let digitalProfileTopAlt = profileView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 44.0)
        digitalProfileTopAlt.priority = UILayoutPriority(rawValue: 750)
        NSLayoutConstraint.activate([
            digitalProfileHeightAlt,
            digitalProfileLeadingAlt,
            digitalProfileTopAlt,
            profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileView.topAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.bottomAnchor, constant: 5.0),
            profileView.widthAnchor.constraint(lessThanOrEqualToConstant: 400.0)
        ])

        configProfileTitleLabelConstraints()
        configProfileDescriptionLabelConstraints()
        configProfileActionLabelConstraints()
        configProfileProgressViewConstraints()
        configProfileProgressCurrentViewConstraints()
        configProfileProgressLabelViewConstraints()
    }
    
    func configProfileTitleLabelConstraints() {
        let profileTitleTopAlt = profileTitleLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 18.0)
        profileTitleTopAlt.priority = UILayoutPriority(rawValue: 900)
        NSLayoutConstraint.activate([
            profileTitleTopAlt,
            profileTitleLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 13.0),
            profileTitleLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -13.0),
            profileTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: profileView.topAnchor, constant: 9.0),
            profileTitleLabel.heightAnchor.constraint(equalToConstant: 32.0)
        ])
    }
    
    func configProfileDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileTitleLabel.bottomAnchor),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 16.0),
            profileDescriptionLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -16.0)
        ])
    }
    
    func configProfileActionLabelConstraints() {
        NSLayoutConstraint.activate([
            profileActionLabel.topAnchor.constraint(equalTo: profileDescriptionLabel.bottomAnchor, constant: 10.0),
            profileActionLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -20.0),
            profileActionLabel.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -20.0),
            profileActionLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
    
    func configProfileProgressViewConstraints() {
        NSLayoutConstraint.activate([
            profileProgressView.centerYAnchor.constraint(equalTo: profileActionLabel.centerYAnchor),
            profileProgressView.leadingAnchor.constraint(equalTo: profileDescriptionLabel.leadingAnchor),
            profileProgressView.heightAnchor.constraint(equalToConstant: 5.0)
        ])
    }
    
    func configProfileProgressCurrentViewConstraints() {
        NSLayoutConstraint.activate([
            profileProgressCurrentView.centerYAnchor.constraint(equalTo: profileActionLabel.centerYAnchor),
            profileProgressCurrentView.leadingAnchor.constraint(equalTo: profileProgressView.leadingAnchor),
            profileProgressCurrentView.heightAnchor.constraint(equalToConstant: 5.0)
        ])
    }
    
    func configProfileProgressLabelViewConstraints() {
        NSLayoutConstraint.activate([
            profileProgressLabel.centerXAnchor.constraint(equalTo: profileView.centerXAnchor),
            profileProgressLabel.centerYAnchor.constraint(equalTo: profileActionLabel.centerYAnchor),
            profileProgressLabel.leadingAnchor.constraint(equalTo: profileProgressView.trailingAnchor, constant: 5.0),
            profileProgressLabel.trailingAnchor.constraint(greaterThanOrEqualTo: profileActionLabel.leadingAnchor, constant: -10.0),
            profileProgressLabel.widthAnchor.constraint(equalToConstant: 30.0),
            profileProgressLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
    
    func configButtonsViewConstraints() {
        NSLayoutConstraint.activate([
            bottomActionsView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            bottomActionsView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            bottomActionsView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            bottomActionsView.heightAnchor.constraint(equalToConstant: 72.0),
            bottomActionsView.topAnchor.constraint(greaterThanOrEqualTo: profileView.bottomAnchor, constant: 20.0)
        ])
    }
}

// MARK: - LoadingViewPresentationCapable
extension OnboardingFinalViewController {
    func setDigitalProfile(percentage: Double) {
        profileView.isHidden = false
        let verifiedPercentage = max(.zero, min(100.0, percentage))
        profileProgressLabel.text = String(Int(verifiedPercentage)) + "%"
        animateProgress(CGFloat(verifiedPercentage/100) * (profileProgressView.frame.width))
    }
    
    func animateProgress(_ value: CGFloat) {
        NSLayoutConstraint.activate([profileProgressCurrentView.widthAnchor.constraint(equalToConstant: value)])
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.profileProgressCurrentView.setNeedsUpdateConstraints()
        }, completion: nil)
    }
    
    @objc func didPressedContinueDigitalProfile() {
        animateTap()
        viewModel.didPressedContinueDigitalProfile()
    }
    
    func animateTap() {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = 1.0
        animation.toValue = 2.0
        animation.duration = 0.1
        profileView.layer.add(animation, forKey: "Width")
        profileView.layer.borderWidth = 1.0
    }
}

// MARK: - LoadingViewPresentationCapable
extension OnboardingFinalViewController: LoadingViewPresentationCapable {}
