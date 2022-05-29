//
//  OnboardingGPSelectionViewController.swift
//
//  Created by José Norberto Hidalgo Romero on 13/12/21.
//

import UI
import UIKit
import OpenCombine
import CoreFoundationLib

final class OnboardingGPSelectionViewController: UIViewController, StepIdentifiable {
    private let viewModel: OnboardingGPSelectionViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingGPSelectionDependenciesResolver
    private let pagerView = PagerView()
    private let bottomActionsView = BottomActionsOnboardingView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(dependencies: OnboardingGPSelectionDependenciesResolver) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        bind()
        viewModel.viewDidLoad()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        pagerView.scrollView?.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pagerView.scrollView?.isHidden = true
    }
}

// MARK: - Binding
private extension OnboardingGPSelectionViewController {
    
    func bind() {
        bindState()
        bindBottomActionsView()
    }
    
    func bindState() {
        viewModel.state
            .case(OnboardingGPSelectionState.hideLoading)
            .sink { [weak self] _ in
                self?.dismissLoading()
            }.store(in: &subscriptions)

        viewModel.state
            .case(OnboardingGPSelectionState.navigationItems)
            .sink { [weak self] items in
                self?.setNavigationItems(items)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingGPSelectionState.showLoading)
            .sink { [weak self] loading in
                self?.showLoading(title: localized(loading.titleKey), subTitle: localized(loading.subtitleKey), completion: {})
            }.store(in: &subscriptions)

        viewModel.state
            .case(OnboardingGPSelectionState.showErrorAlert)
            .sink { [weak self] alert in
                self?.showErrorAlert(alert)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(OnboardingGPSelectionState.showInfo)
            .sink { [weak self] info in
                self?.setPager(info: info.info,
                              titleKey: info.titleKey,
                              currentIndex: info.currentIndex,
                              bannedIndexes: info.bannedIndexes)
                self?.setupLabelsText()
            }.store(in: &subscriptions)
    }
    
    func bindBottomActionsView() {
        bottomActionsView.action
            .sink { [unowned self] value in
                switch value {
                case .back:
                    self.viewModel.didSelectBack()
                case .next:
                    self.viewModel.didSelectNext(gpSelected: getOptionPagerSelected(),
                                            smartStyleSelected: getSmartSelectedColor())
                }
            }
            .store(in: &subscriptions)
    }
    
    func showErrorAlert(_ alert: OnboardingGPSelectionStateAlert) {
        switch alert {
        case let .common(error):
            let accept = DialogButtonComponents(titled: localized(error.acceptKey),
                                                does: { [weak self] in self?.viewModel.didCloseError() })
            OldDialog.alert(title: nil,
                            body: localized(error.bodyKey),
                            withAcceptComponent: accept,
                            withCancelComponent: nil,
                            source: self)
        case .generic:
            self.showGenericErrorDialog()
        }
    }
    
    func showGenericErrorDialog() {
        self.showGenericErrorDialog(withDependenciesResolver: self.dependencies.external.resolve(),
                                    action: { [weak self] in self?.viewModel.didCloseError() },
                                    closeAction: { [weak self] in self?.viewModel.didCloseError() })
    }
    
    func setPager(info: [PageInfo], titleKey: String, currentIndex: Int, bannedIndexes: [Int]) {
        pagerView.setTitle(localized(titleKey))
        pagerView.setInfo(info)
        pagerView.setCurrentSlide(currentIndex)
        pagerView.setBannedIndexes(bannedIndexes)
    }
    
    func getOptionPagerSelected() -> Int {
        return pagerView.selectedSlide().id
    }
    
    func getSmartSelectedColor() -> ButtonType? {
        return pagerView.themeColorSelectorView.getSelectedButtonType()
    }
    
    func setNavigationItems(_ items: OnboardingGPSelectionStateNavigationItems) {
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
private extension OnboardingGPSelectionViewController {
    func configView() {
        view.backgroundColor = UIColor.white
        configBottomActionsView()
        setupLabelsText()
        configPagerView()
        addViews()
        configConstraints()
    }
    
    func setupLabelsText() {
        bottomActionsView.continueText = localized("generic_button_continue")
        bottomActionsView.backText = localized("generic_button_previous")
    }
           
    func configBottomActionsView() {
        bottomActionsView.translatesAutoresizingMaskIntoConstraints = false
        bottomActionsView.setupViews()
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
extension OnboardingGPSelectionViewController: GenericErrorDialogPresentationCapable {}

// MARK: - LoadingViewPresentationCapable
extension OnboardingGPSelectionViewController: LoadingViewPresentationCapable {}

// MARK: - PagerViewDelegate
extension OnboardingGPSelectionViewController: PagerViewDelegate {
    func scrolledToNewOption() {
        viewModel.didScrollToNewOption()
    }
}
