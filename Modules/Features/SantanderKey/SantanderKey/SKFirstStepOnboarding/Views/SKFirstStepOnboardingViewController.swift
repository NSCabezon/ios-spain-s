//
//  OnboardingViewController.swift
//  Transfer
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import ESUI
import UIOneComponents
import Operative

final class SKFirstStepOnboardingViewController: UIViewController, GenericErrorDialogPresentationCapable {
    
    @IBOutlet private weak var headerView: SKHeaderView!
    @IBOutlet private weak var videoView: SKVideoView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionStack: UIStackView!
    @IBOutlet private weak var continueButton: OneFloatingButton!
    
    private let viewModel: SKFirstStepOnboardingViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKFirstStepOnboardingDependenciesResolver
    private let errorView = OneOperativeAlertErrorView()
    
    init(dependencies: SKFirstStepOnboardingDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKFirstStepOnboardingViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setupView()
        setAccessibilityIds()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setPopGestureEnabled(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.continueButton.setLoadingStatus(.ready)
        setPopGestureEnabled(true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.viewModel.didTapContinueButton()
    }

    func resetView() {
        self.continueButton.setLoadingStatus(.ready)
    }
}

private extension SKFirstStepOnboardingViewController {
    func setAppearance() {
    }
    
    func setupView() {
        self.videoView.setImageView(name: "imgVideoTutorialSanKey", accesibilityId: AccessibilitySkFirstStepOnboarding.SkVideoView.imageView)
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14))
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "sanKey_text_authoriseAllTransactions",
                                            andConfiguration: configuration)
        self.descriptionLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.descriptionLabel
        let descriptionItem1: SKItemDescriptionView = SKItemDescriptionView()
        descriptionItem1.configView(image: ESAssets.image(named: "IcnFingerprint"),
                                    text: "sanKey_text_confirmationUsingBiometrics",
                                    accesibilityModel:
                                        SkItemAccesibilityModel(label: AccessibilitySkFirstStepOnboarding.ItemDescriptionView.firstItemLabel,
                                        image: AccessibilitySkFirstStepOnboarding.ItemDescriptionView.firstItemImage))
        let descriptionItem2: SKItemDescriptionView = SKItemDescriptionView()
            descriptionItem2.configView(image: ESAssets.image(named: "IcnMobile"),
                                        text: "sanKey_text_notificationMobile",
                                        accesibilityModel:
                                            SkItemAccesibilityModel(label: AccessibilitySkFirstStepOnboarding.ItemDescriptionView.secondItemLabel,
                                            image: AccessibilitySkFirstStepOnboarding.ItemDescriptionView.secondItemImage))
        let descriptionItem3: SKItemDescriptionView = SKItemDescriptionView()
        descriptionItem3.configView(image: ESAssets.image(named: "IcnSanKeyLock"),
                                    text: "sanKey_text_checkPendingTransactions",
                                    accesibilityModel:
                                        SkItemAccesibilityModel(label: AccessibilitySkFirstStepOnboarding.ItemDescriptionView.thirdItemLabel,
                                                                image: AccessibilitySkFirstStepOnboarding.ItemDescriptionView.thirdItemImage))
        let descriptionItems: [SKItemDescriptionView] = [descriptionItem1, descriptionItem2, descriptionItem3]
        self.addStackViewItems(in: self.descriptionStack, items: descriptionItems)
        self.continueButton.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: "generic_button_continue", icons: .none, fullWidth: true)),
            status: .ready)
    }
    
    func bind() {
        bindButtons()
        bindLoading()
        bindError()
        bindAlertView()
    }
    
    func bindButtons() {
        headerView
            .didTapInMoreInfo
            .sink {[unowned self] _ in
                self.showBottomSheet()
            }.store(in: &subscriptions)
        
        videoView
            .didTapVideo
            .sink {[unowned self] _ in
                self.viewModel.didTapVideo()
            }.store(in: &subscriptions)
    }
    
    func bindLoading() {
        viewModel.state
            .case { OnboardingState.showLoading }
            .sink {[unowned self] show in
                show ? self.continueButton.setLoadingStatus(.loading) : self.continueButton.setLoadingStatus(.ready)
            }.store(in: &subscriptions)
    }

    func bindError() {
        viewModel.state
            .case(OnboardingState.showError)
            .sink { [unowned self] errorViewModel in
                guard var errorViewModel = errorViewModel else {
                    self.showGenericErrorDialog(withDependenciesResolver: dependencies.external.resolve())
                    return
                }
                if errorViewModel.floatingButtonAction == nil {
                    errorViewModel.floatingButtonAction = resetView
                }
                errorView.setData(errorViewModel)
                BottomSheet().show(in: self,
                                   type: .custom(height: nil, isPan: true, bottomVisible: true),
                                   component: errorViewModel.typeBottomSheet,
                                   view: errorView)
            }.store(in: &subscriptions)
    }
    
    func bindAlertView() {
        errorView.publisher
            .case(ReactiveOneOperativeAlertErrorViewState.didTapAcceptButton)
            .sink { [unowned self] action in
                dismiss(animated: true) {
                    action?()
                }
            }.store(in: &subscriptions)
    }
    
    func addStackViewItems(in stackview: UIStackView, items: [SKItemDescriptionView]) {
        for index in 0..<items.count {
            let item = items[index]
            stackview.addArrangedSubview(item)
            if #available(iOS 11.0, *), index != items.count - 1 {
                stackview.setCustomSpacing(12.0, after: item)
            } else {
                self.addSeparator(in: stackview, space: 12.0)
            }
        }
        stackview.layoutIfNeeded()
    }
    
    func add(in stackview: UIStackView, element: UIView) {
        stackview.addArrangedSubview(element)
    }
    
    func addSeparator(in stackview: UIStackView, space: CGFloat) {
        let separatorView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: stackview.frame.size.width, height: space))
        separatorView.backgroundColor = UIColor.white
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: space).isActive = true
        self.add(in: stackview, element: separatorView)
    }
    
    func showBottomSheet() {
        guard let navigation = self.navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation, type: .custom(isPan: true), component: .all, view: SKFirstScreenKnowMore())
    }
    
    func setAccessibilityIds() {
        self.descriptionLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.descriptionLabel
    }    
}
