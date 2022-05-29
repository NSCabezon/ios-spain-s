//
//  OnboardingPhotoThemeViewController.swift
//  Onboarding
//
//  Created by Jose Camallonga on 15/12/21.
//

import UIKit
import OpenCombine
import UI
import CoreFoundationLib

final class OnboardingPhotoThemeViewController: UIViewController, StepIdentifiable {
    private let viewModel: OnboardingPhotoThemeViewModel
    private let dependencies: OnboardingPhotoThemeDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private let pagerView = PagerView()
    private let bottomActionsView = BottomActionsOnboardingView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: OnboardingPhotoThemeDependenciesResolver) {
        self.dependencies = dependencies
        viewModel = dependencies.resolve()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pagerView.setNeedsLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pagerView.scrollView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pagerView.scrollView?.isHidden = false
        viewModel.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        bind()
        viewModel.viewDidLoad()
    }
}

// MARK: - Binding
private extension OnboardingPhotoThemeViewController {
    
    func bind() {
        bindState()
        bindBottomActionsView()
    }
    
    func bindState() {
        viewModel.state
            .case(OnboardingPhotoThemeState.hideLoading)
            .sink { [weak self] _ in
                self?.dismissLoading { [weak self] in
                    self?.viewModel.didHideLoading()
                }
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(OnboardingPhotoThemeState.navigationItems)
            .sink { [weak self] items in
                self?.setNavigationItems(items)
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(OnboardingPhotoThemeState.showLoading)
            .sink { [weak self] loading in
                self?.showLoading(title: localized(loading.titleKey),
                                  subTitle: localized(loading.subtitleKey),
                                  completion: { [weak self] in
                    self?.viewModel.didShowLoading()
                })
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(OnboardingPhotoThemeState.showErrorAlert)
            .sink { [weak self] alert in
                self?.showErrorAlert(alert)
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(OnboardingPhotoThemeState.info)
            .sink { [weak self] info in
                self?.setPager(info: info.info,
                               titleKey: info.titleKey,
                               currentIndex: info.currentIndex,
                               bannedIndexes: info.bannedIndexes)
            }.store(in: &anySubscriptions)
    }
    
    func bindBottomActionsView() {
        bottomActionsView.action
            .sink { [unowned self] value in
                switch value {
                case .back:
                    self.viewModel.didSelectBack()
                case .next:
                    self.viewModel.didSelectNext(optionSelected: pagerView.selectedSlide().id)
                }
            }
            .store(in: &anySubscriptions)
    }
    
    func showErrorAlert(_ alert: OnboardingPhotoThemeAlert) {
        let accept = DialogButtonComponents(titled: localized(alert.acceptKey),
                                            does: { [weak self] in self?.viewModel.didCloseError() })
        OldDialog.alert(title: localized(alert.titleKey),
                        body: localized(alert.bodyKey),
                        withAcceptComponent: accept,
                        withCancelComponent: nil,
                        source: self)
    }
    
    func setPager(info: [PageInfo], titleKey: String, currentIndex: Int, bannedIndexes: [Int]) {
        pagerView.setTitle(localized(titleKey))
        pagerView.setInfo(info)
        pagerView.setCurrentSlide(currentIndex)
        pagerView.setBannedIndexes(bannedIndexes)
    }
    
    func setNavigationItems(_ items: OnboardingPhotoThemeStateNavigationItems) {
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
private extension OnboardingPhotoThemeViewController {
    func configView() {
        view.backgroundColor = UIColor.white
        configPagerView()
        configBottomActionsView()
        addViews()
        configConstraints()
    }
    
    func configBottomActionsView() {
        bottomActionsView.translatesAutoresizingMaskIntoConstraints = false
        bottomActionsView.setupViews()
        bottomActionsView.continueText = localized("generic_button_continue")
        bottomActionsView.backText = localized("generic_button_previous")
    }
    
    func configPagerView() {
        pagerView.delegate = self
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.backgroundColor = .clear
    }
    
    func addViews() {
        view.addSubview(pagerView)
        view.addSubview(bottomActionsView)
    }
    
    func configConstraints() {
        configPagerViewConstraints()
        configButtonsViewConstraints()
    }
    
    func configPagerViewConstraints() {
        NSLayoutConstraint.activate([
            pagerView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            pagerView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            pagerView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            pagerView.bottomAnchor.constraint(equalTo: bottomActionsView.topAnchor)
        ])
    }
    
    func configButtonsViewConstraints() {
        NSLayoutConstraint.activate([
            bottomActionsView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            bottomActionsView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            bottomActionsView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            bottomActionsView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
}

// MARK: - GenericErrorDialogPresentationCapable
extension OnboardingPhotoThemeViewController: GenericErrorDialogPresentationCapable {}

// MARK: - LoadingViewPresentationCapable
extension OnboardingPhotoThemeViewController: LoadingViewPresentationCapable {}

// MARK: - PagerViewDelegate
extension OnboardingPhotoThemeViewController: PagerViewDelegate {
    func scrolledToNewOption() {
        viewModel.didScrollToNewOption()
    }
}
