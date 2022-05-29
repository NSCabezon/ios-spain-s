//
//  SKPinStepViewController.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 23/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import ESUI
import UIOneComponents
import CoreFoundationLib
import Operative

private enum SKPinStepConstants {
    enum Button {
        static let normalColor: UIColor = .oneDarkTurquoise
        static let highLightedColor: UIColor = .oneTurquoise
        static let font: UIFont = UIFont.santander(family: .micro, type: .regular, size: 12)
        static let boldFont: UIFont = UIFont.santander(family: .micro, type: .bold, size: 12)
    }
}

final class SKPinStepViewController: UIViewController, GenericErrorDialogPresentationCapable {
    
    @IBOutlet private weak var descriptionTitleLabel: UILabel!
    @IBOutlet private weak var descriptionTextLabel: UILabel!
    @IBOutlet private weak var pinContainerView: OneGradientView!
    @IBOutlet private weak var continueButton: OneFloatingButton!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var inputTitleLabel: UILabel!
    @IBOutlet private weak var inputCodeView: UIStackView!
    @IBOutlet private weak var rememberPinButton: UIButton!
    @IBOutlet private weak var selectCardButton: UIButton!
    private var oneInputCodeView: OneInputCodeView?
    
    private let viewModel: SKPinStepViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKPinStepDependenciesResolver
    private let errorView = OneOperativeAlertErrorView()
    
    init(dependencies: SKPinStepDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKPinStepViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupView()
        setAccessibilityIds()
        setAppearance()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func selectOtherCardButtonTal(_ sender: Any) {
        self.viewModel.didTapSelecOtherCard()
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        guard let pin = oneInputCodeView?.fulfilledText() else { return }
        self.viewModel.didTapContinueButton(pin: pin)
    }

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension SKPinStepViewController {
    func setAppearance() {
        pinContainerView.setupType(.oneGrayGradient(direction: .topToBottom))
        self.cardImageView.image = Assets.image(named: "imgSantanderRedCard")
        setupLabels()
        setupButtons()
        setupInput()
    }
    
    func setupView() {
    }
    
    func setupLabels() {
        self.descriptionTitleLabel.configureText(withKey: "sanKey_title_addPin", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 24)))
        self.descriptionTitleLabel.textColor = .lisboaGray
        self.descriptionTextLabel.configureText(withKey: "sanKey_text_enterPin", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14)))
        self.descriptionTextLabel.textColor = .lisboaGray
        self.inputTitleLabel.configureText(withKey: "sanKey_label_pin", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14)))
        self.inputTitleLabel.textColor = .lisboaGray
    }
    
    func setupButtons() {
        let steps = viewModel.stepsCoordinator
        let current = (steps?.progress.current ?? -1) + 1
        continueButton.configureWith(
            type: OneFloatingButton.ButtonType.primary,
            size: OneFloatingButton.ButtonSize.large(OneFloatingButton.ButtonSize.LargeButtonConfig(
                        title: localized("generic_button_continue"),
                        subtitle: localized("sanKey_button_securityPassword", [StringPlaceholder(.number, "\(current)"), StringPlaceholder(.number, "\(steps?.progress.total ?? 0)")]).text,
                        icons: OneFloatingButton.ButtonSize.LargeButtonConfig.LargeIcons.right,
                        fullWidth: false)),
                    status: .ready)
        continueButton.isEnabled = false
        rememberPinButton.setTitle(localized("sanKey_link_rememberPin"), for: .normal)
        rememberPinButton.setTitleColor(SKPinStepConstants.Button.normalColor, for: .normal)
        rememberPinButton.setTitleColor(SKPinStepConstants.Button.highLightedColor, for: .highlighted)
        rememberPinButton.titleLabel?.font = SKPinStepConstants.Button.boldFont
        selectCardButton.setTitle(localized("sanKey_link_selectOtherCard"), for: .normal)
        selectCardButton.setTitleColor(SKPinStepConstants.Button.normalColor, for: .normal)
        selectCardButton.setTitleColor(SKPinStepConstants.Button.highLightedColor, for: .highlighted)
        selectCardButton.titleLabel?.font = SKPinStepConstants.Button.font
        selectCardButton.titleLabel?.numberOfLines = 0
    }
    
    func setupInput() {
        let inputViewModel = OneInputCodeViewModel(
            hiddenCharacters: false,
            enabledChangeVisibility: true,
            itemsCount: 4,
            requestedPositions: OneInputCodeViewModel.RequestedPositions.all)
        self.oneInputCodeView = OneInputCodeView(with: inputViewModel, delegate: nil)
        self.inputCodeView.addArrangedSubview(self.oneInputCodeView!)
    }
    
    func setAccessibilityIds() {
        self.descriptionTitleLabel.accessibilityIdentifier = AccessibilitySKPinStep.labelTitle
        self.descriptionTextLabel.accessibilityIdentifier = AccessibilitySKPinStep.labelSubtitle
        self.inputTitleLabel.accessibilityIdentifier = AccessibilitySKPinStep.labelPinTitle
        self.selectCardButton.accessibilityIdentifier = AccessibilitySKPinStep.buttonSelectOtherCard
        self.rememberPinButton.accessibilityIdentifier = AccessibilitySKPinStep.buttonRememberPin
    }

    func resetView() {
        oneInputCodeView?.reset()
        viewModel.setInputCodeFilled(false)
        guard let skOperativeData: SKOnboardingOperativeData = dataBinding.get() else { return }
        skOperativeData.selectedCardPIN = ""
        dataBinding.set(skOperativeData)
    }
}

// Reactive functions extension
private extension SKPinStepViewController {
    func bind() {
        bindInputCode()
        bindViewModelState()
        bindAlertView()
    }
    
    func bindInputCode() {
        self.oneInputCodeView?
            .publisher
            .case(ReactiveOneInputCodeViewState.didChange)
            .sink { [unowned self] (_, string, position, allValues) in
                if position == 3 {
                    viewModel.setInputCodeFilled(!string.isEmpty)
                }
            }.store(in: &subscriptions)
        
        self.oneInputCodeView?
            .publisher
            .case(ReactiveOneInputCodeViewState.didBeginEditing)
            .sink { [unowned self] _, _ in
                
            }.store(in: &subscriptions)
    
        self.oneInputCodeView?
            .publisher
            .case(ReactiveOneInputCodeViewState.didEndEditing)
            .sink { [unowned self] _, _ in
                
            }.store(in: &subscriptions)
    }
    
    func bindViewModelState() {
        viewModel.state
            .case {PinStepState.pinFilled}
            .sink { [unowned self] state in
                continueButton.isEnabled = state
            }.store(in: &subscriptions)
        
        viewModel.state
            .case {PinStepState.pinEditing}
            .sink {[unowned self] _ in
            
            }
            .store(in: &subscriptions)

        viewModel.state
            .case { PinStepState.showLoading }
            .sink {[unowned self] show in
                show ? self.continueButton.setLoadingStatus(.loading) : self.continueButton.setLoadingStatus(.ready)
            }.store(in: &subscriptions)

        viewModel.state
            .case(PinStepState.showError)
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
}

extension SKPinStepViewController: StepIdentifiable {}
