//
//  ReactiveOperativeSignatureViewController.swift
//  Operative
//
//  Created by David Gálvez Alonso on 8/3/22.
//

import UIKit
import UIOneComponents
import OpenCombine
import UI
import CoreFoundationLib
import CoreDomain

public final class ReactiveOperativeSignatureViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet public weak var contentScrollView: UIScrollView!
    @IBOutlet public weak var floatingButton: OneFloatingButton!
    @IBOutlet public weak var floatingButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var signatureImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var oneInputCodeView: OneInputCodeView!
    @IBOutlet private weak var forgotSignatureButton: OneAppLink!
    @IBOutlet private weak var loadingViewContainer: UIView!
    @IBOutlet private weak var loadingView: UIImageView!

    // MARK: - Variables
    private let viewModel: SignatureViewModelProtocol
    private let dependenciesResolver: DependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    private let forgotView = OneElectronicSignatureForgotView()
    private let errorView = OneOperativeAlertErrorView()
    
    // MARK: - Initializers
    public init(dependencies: ReactiveOperativeSignatureExternalDependenciesResolver) {
        self.viewModel = dependencies.resolve()
        self.dependenciesResolver = dependencies.resolve()
        super.init(nibName: "ReactiveOperativeSignatureViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        viewModel.viewDidLoad()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideKeyboard()
    }
}

// MARK: - Reactive functions
private extension ReactiveOperativeSignatureViewController {
    
    func bind() {
        bindViewModelLoad()
        bindViewModelChangeAvailability()
        bindOneInputCodeView()
        bindForgotView()
        bindAlertView()
        bindShowAlertView()
        bindFloatingButtonView()
    }
    
    func bindViewModelLoad() {
        viewModel.state
            .case(ReactiveOperativeSignatureState.loaded)
            .sink { [unowned self] loadedInformation in
                updateInputCodeComponent(loadedInformation.signature)
                updateLabelCodeComponent(loadedInformation.signature)
            }.store(in: &subscriptions)
    }
    
    func bindViewModelChangeAvailability() {
        viewModel.state
            .case(ReactiveOperativeSignatureState.didChangeAvailabilityToContinue)
            .sink { [unowned self] available in
                enableContinue(available)
            }.store(in: &subscriptions)
    }

    func bindOneInputCodeView() {
        oneInputCodeView.publisher
            .case(ReactiveOneInputCodeViewState.didChange)
            .sink { [unowned self] (_, _, _, allValuesText) in
                viewModel.didSetSignaturePositions(allValuesText)
            }.store(in: &subscriptions)
    }
    
    func bindForgotView() {
        forgotView.publisher
            .sink { [unowned self] in
                dismiss(animated: true)
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
    
    func bindShowAlertView() {
        viewModel.state
            .case(ReactiveOperativeSignatureState.showError)
            .sink { [unowned self] errorViewModel in
                guard var errorViewModel = errorViewModel else {
                    showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
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

        viewModel.state
            .case { ReactiveOperativeSignatureState.showLoading }
            .filter { $0 == true }
            .sink { [unowned self] _ in
                self.showLoading()
            }.store(in: &subscriptions)
        
        viewModel.state
            .case { ReactiveOperativeSignatureState.showLoading }
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.hideLoading()
            }.store(in: &subscriptions)
    }
    
    func bindFloatingButtonView() {
        floatingButton.onTouchSubject
            .sink { [unowned self] in
                floatingButtonDidPressed()
            }.store(in: &subscriptions)
    }
}

// MARK: - View configuration
private extension ReactiveOperativeSignatureViewController {
    
    func setupView() {
        loadingViewContainer.isHidden = true
        setupKeyboardListener()
        setupIcon()
        setupLabels()
        setupForgotSignatureButton()
        setupFloatingButton()
        setAccessibilityIdentifiers()
    }
    
    func setupKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    func setupIcon() {
        signatureImage.image = Assets.image(named: Constants.iconName)
    }
    
    func setupLabels() {
        titleLabel.font = .typography(fontName: .oneH100Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: Constants.titleKey)
        descriptionLabel.font = .typography(fontName: .oneH100Regular)
        descriptionLabel.textColor = .oneLisboaGray
    }
    
    func setupForgotSignatureButton() {
        forgotSignatureButton.configureButton(type: .secondary,
                                                   style: OneAppLink.ButtonContent(text: localized(Constants.forgotSignatureButtonKey),
                                                                                   icons: .none))
        forgotSignatureButton.addTarget(self, action: #selector(forgotSignatureButtonSelected), for: .touchUpInside)
    }
    
    func setupFloatingButton() {
        floatingButton.configureWith(
            type: OneFloatingButton.ButtonType.primary,
            size: OneFloatingButton.ButtonSize.medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized(Constants.floatingButtonKey),
                                                                icons: .right,
                                                                fullWidth: true)),
            status: OneFloatingButton.ButtonStatus.ready)
        enableContinue(false)
    }
    
    func setAccessibilityIdentifiers() {
        signatureImage.accessibilityIdentifier = AccessibilityOperativeSignature.signatureIcon
        titleLabel.accessibilityIdentifier = AccessibilityOperativeSignature.signatureTitle
        descriptionLabel.accessibilityIdentifier = AccessibilityOperativeSignature.signatureSubtitle
        forgotSignatureButton.accessibilityIdentifier = AccessibilityOperativeSignature.signatureRemember
    }
    
    func updateInputCodeComponent(_ signature: SignatureRepresentable) {
        guard let length = signature.length,
              let positions = signature.positions else {
            return
        }
        let viewModel = OneInputCodeViewModel(hiddenCharacters: true,
                                              enabledChangeVisibility: false,
                                              itemsCount: length,
                                              requestedPositions: OneInputCodeViewModel.RequestedPositions.positions(positions))
        oneInputCodeView.setViewModel(viewModel)
    }
    
    func updateLabelCodeComponent(_ signature: SignatureRepresentable) {
        let positions = (signature.positions ?? []).map { StringPlaceholder(.number, String($0)) }
        let positionText = CoreFoundationLib.localized(Constants.descriptionKey, positions)
        descriptionLabel.configureText(withLocalizedString: positionText)
    }
    
    func enableContinue(_ enable: Bool) {
        floatingButton.isEnabled = enable
    }
    
    func resetView() {
        oneInputCodeView.reset()
        oneInputCodeView.becomeFirstResponder()
        enableContinue(false)
    }

    func showLoading() {
        loadingViewContainer.alpha = 0
        loadingViewContainer.isHidden = false
        loadingView?.setNewJumpingLoader()
        UIView.animate(withDuration: 0.3) {
            self.loadingViewContainer.alpha = 1
        } completion: { finished in
            if finished {
                self.loadingView?.setNewJumpingLoader()
            }
        }
    }

    func hideLoading() {
        UIView.animate(withDuration: 0.3) {
            self.loadingViewContainer.alpha = 0
        } completion: { finished in
            if finished {
                self.loadingView?.removeLoader()
                self.loadingViewContainer.isHidden = true
            }
        }
    }
    
    func floatingButtonDidPressed() {
        guard floatingButton.isEnabled else { return }
        viewModel.next()
    }
    
    @objc func forgotSignatureButtonSelected() {
        BottomSheet().show(in: self,
                           type: .custom(height: nil, isPan: true, bottomVisible: true),
                           component: .all,
                           view: forgotView)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    enum Constants {
        static let iconName: String = "icnLock"
        static let titleKey: String = "signing_text_key"
        static let descriptionKey: String = "signing_text_insertNumbers"
        static let forgotSignatureButtonKey: String = "signing_text_remember"
        static let floatingButtonKey: String = "signing_button_singningContinue"
    }
}

// MARK: - Keyboard Helper for FloatingButton
extension ReactiveOperativeSignatureViewController: FloatingButtonKeyboardHelper {
    @objc func keyboardWillShow(_ notification: Notification) {
        keyboardWillShowWithFloatingButton(notification)
}

    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardWillHideWithFloatingButton(notification)
    }
}

extension ReactiveOperativeSignatureViewController: StepIdentifiable {}

// MARK: - GenericErrorDialogPresentationCapable

extension ReactiveOperativeSignatureViewController: GenericErrorDialogPresentationCapable {}
