//
//  ReactiveOperativeOTPViewController.swift
//  Operative
//
//  Created by David Gálvez Alonso on 17/3/22.
//

import UIKit
import UIOneComponents
import CoreFoundationLib
import UI
import OpenCombine

public final class ReactiveOperativeOTPViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var titleOTPLabel: UILabel!
    @IBOutlet private weak var subtitleOTPLabel: UILabel!
    @IBOutlet private weak var otpTextField: OneInputRegularView!
    @IBOutlet private weak var sendAgainButton: OneAppLink!
    @IBOutlet public weak var floatingButton: OneFloatingButton!
    @IBOutlet public weak var floatingButtonConstraint: NSLayoutConstraint!
    @IBOutlet public weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var loadingViewContainer: UIView!
    @IBOutlet private weak var loadingView: UIImageView!

    // MARK: - Variables
    private let viewModel: OTPViewModelProtocol
    private let dependenciesResolver: DependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    private let errorView = OneOperativeAlertErrorView()
    
    // MARK: - Initializers
    public init(dependencies: ReactiveOperativeOTPExternalDependenciesResolver) {
        self.viewModel = dependencies.resolve()
        self.dependenciesResolver = dependencies.resolve()
        super.init(nibName: "ReactiveOperativeOTPViewController", bundle: .module)
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
        hideKeyboard()
    }
}

// MARK: - Reactive functions
private extension ReactiveOperativeOTPViewController {
    
    func bind() {
        bindViewModelLoad()
        bindViewModelChangeAvailability()
        bindOTPTextField()
        bindFloatingButtonView()
        bindAlertView()
        bindShowAlertView()
    }
    
    func bindViewModelLoad() {
        viewModel.state
            .case(ReactiveOperativeOTPState.loaded)
            .sink { [unowned self] loadedInfo in
                otpTextField.maxCounter = loadedInfo.maxLength
                let phone = loadedInfo.phoneNumber
                let localizedOTPString = localized(Constants.subtitleKey, [StringPlaceholder(.value, phone.substring(phone.count - 3, phone.count) ?? phone)])
                subtitleOTPLabel.configureText(withLocalizedString: localizedOTPString)
            }.store(in: &subscriptions)
    }
    
    func bindViewModelChangeAvailability() {
        viewModel.state
            .case(ReactiveOperativeOTPState.didChangeAvailabilityToContinue)
            .sink { [unowned self] available in
                enableContinue(available)
            }.store(in: &subscriptions)
    }
    
    func bindOTPTextField() {
        otpTextField.publisher
            .case(ReactiveOneInputRegularViewState.textDidChange)
            .sink { [unowned self] otp in
                viewModel.didSetOTP(otp)
            }.store(in: &subscriptions)
    }
    
    func bindFloatingButtonView() {
        floatingButton.onTouchSubject
            .sink { [unowned self] in
                floatingButtonDidPressed()
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
            .case(ReactiveOperativeOTPState.showError)
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
            .case { ReactiveOperativeOTPState.showLoading }
            .sink { [unowned self] show in
                show ? self.showLoading() : self.hideLoading()
            }.store(in: &subscriptions)
    }
}

private extension ReactiveOperativeOTPViewController {
    
    func setupView() {
        loadingViewContainer.isHidden = true
        setupKeyboardListener()
        setupLabels()
        setupTextField()
        setupButtons()
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
    
    func setupLabels() {
        titleOTPLabel.font = .typography(fontName: .oneH100Bold)
        titleOTPLabel.textColor = .oneLisboaGray
        titleOTPLabel.configureText(withKey: Constants.titleKey)
        subtitleOTPLabel.font = .typography(fontName: .oneH100Regular)
        subtitleOTPLabel.textColor = .oneLisboaGray
    }
    
    func setupTextField() {
        self.otpTextField.setupTextField(
            OneInputRegularViewModel(status: .inactive,
                                     resetText: true,
                                     alignment: .center,
                                     textSize: .large,
                                     textContentType: .otp)
        )
    }
    
    func setupButtons() {
        sendAgainButton.configureButton(
            type: .secondary,
            style: OneAppLink.ButtonContent(text: localized(Constants.codeNotReceived),
                                            icons: .none))
        sendAgainButton.isUserInteractionEnabled = true
        sendAgainButton.addTarget(self, action: #selector(didSelectSendAgain), for: .touchUpInside)
        floatingButton.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(
                    title: localized(Constants.floatingButtonKey),
                    icons: .right,
                    fullWidth: true)),
            status: .ready)
        enableContinue(false)
    }
    
    func setAccessibilityIdentifiers() {
        titleOTPLabel.accessibilityIdentifier = Constants.titleKey
        subtitleOTPLabel.accessibilityIdentifier = Constants.subtitleKey
    }
    
    func enableContinue(_ enable: Bool) {
        floatingButton.isEnabled = enable
    }
    
    func resetView() {
        otpTextField.setInputText("")
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
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func didSelectSendAgain() {
        viewModel.resendCode()
    }
    
    enum Constants {
        static let titleKey: String = "otp_text_sms"
        static let subtitleKey: String = "otp_text_insertCode"
        static let codeNotReceived: String = "otp_button_codeNotReceived"
        static let floatingButtonKey: String = "signing_button_singningContinue"
    }
}

// MARK: - Keyboard Helper for FloatingButton
extension ReactiveOperativeOTPViewController: FloatingButtonKeyboardHelper {
    @objc func keyboardWillShow(_ notification: Notification) {
        keyboardWillShowWithFloatingButton(notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardWillHideWithFloatingButton(notification)
    }
}

extension ReactiveOperativeOTPViewController: StepIdentifiable {}

extension ReactiveOperativeOTPViewController: GenericErrorDialogPresentationCapable {}
