//
//  OneElectronicSignatureViewController.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 17/12/21.
//

import UIKit
import UIOneComponents
import UI
import Operative
import CoreFoundationLib
import IQKeyboardManagerSwift

final class OneElectronicSignatureViewController: UIViewController, FloatingButtonLoaderCapable {
    private enum Constants {
        enum NavigationBar {
            static let titleKey: String = "toolbar_title_signing"
        }
        static let iconName: String = "icnLock"
        static let titleKey: String = "signing_text_key"
        static let descriptionKey: String = "signing_text_insertNumbers"
        static let forgotSignatureButtonKey: String = "signing_text_remember"
        static let floatingButtonKey: String = "signing_button_singningContinue"
        enum InputBox {
            enum Selected {
                static let backgroundColor: UIColor = UIColor.oneTurquoise.withAlphaComponent(0.07)
                static let borderColor: UIColor = .oneDarkTurquoise
                static let borderWidth: CGFloat = 2.0
            }
            enum Deselected {
                static let backgroundColor: UIColor = .clear
                static let borderColor: UIColor = .oneBrownGray
                static let borderWidth: CGFloat = 1.0
            }
        }
        enum Constraints {
            static let acceptButtonBottomMargin: CGFloat = 20.0
            static let inputBoxSize: CGSize = CGSize(width: 43.0, height: 48.0)
        }
    }
    
    @IBOutlet private weak var signatureImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var pinContainerView: UIView!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    @IBOutlet private weak var forgotSignatureButton: OneAppLink!
    @IBOutlet private weak var floatingButtonBottomMargin: NSLayoutConstraint!
    
    private let dependenciesResolver: DependenciesResolver
    private let presenter: SignaturePresenterProtocol
    private var internalPresenter: OperativeStepPresenterProtocol? {
        self.presenter as? OperativeStepPresenterProtocol
    }
    private let facade = InputCodePinFacade()
    private lazy var inputCodeView: InputCodeView = {
        return InputCodeView(keyboardType: .numberPad,
                             delegate: self,
                             facade: self.facade,
                             elementSize: Constants.Constraints.inputBoxSize,
                             requestedPositions: .positions(self.presenter.signature.positions ?? []),
                             charactersSet: .numbers)
    }()
    
    public convenience init(presenter: SignaturePresenterProtocol,
                            dependenciesResolver: DependenciesResolver) {
        self.init(nibName: String(describing: OneElectronicSignatureViewController.self),
                  bundle: .module,
                  presenter: presenter,
                  dependenciesResolver: dependenciesResolver)
    }
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: SignaturePresenterProtocol,
         dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupKeyboardConfiguration()
        self.presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isEditing = true
        if !UIAccessibility.isVoiceOverRunning {
            self.inputCodeView.becomeFirstResponder()
        }
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideKeyboard()
    }
    
    var loadingView: UIView?
}

extension OneElectronicSignatureViewController: InternalSignatureViewProtocol {
    
    func enableAccept() {
        self.floatingButton.isEnabled = true
    }
    
    func disableAccept() {
        self.floatingButton.isEnabled = false
    }
    
    func reset() {
        self.inputCodeView.reset()
        self.inputCodeView.becomeFirstResponder()
        self.disableAccept()
    }
    
    func setPurpose(_ purpose: SignaturePurpose) { }
    
    func setNavigationBuilderTitle(_ title: String?) {
        self.setupNavigationBar()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func showDialogForType(_ type: SignatureDialogType) {
        guard let errorViewModel = self.getSignatureErrorViewModel(for: type) else {
            self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
            return
        }
        self.showSignatureError(viewModel: errorViewModel)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        guard let internalPresenter = self.internalPresenter else { fatalError() }
        return internalPresenter
    }
}

private extension OneElectronicSignatureViewController {
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: Constants.NavigationBar.titleKey)
            .setLeftAction(.back) {
                self.presenter.didTapBack()
            }
            .setRightAction(.help) {
                self.presenter.didSelectHelp()
            }
            .setRightAction(.close) {
                self.presenter.didTapClose()
            }
            .build(on: self)
    }
    
    func setupKeyboardConfiguration() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
              let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        self.isEditing = true
        var bottomPadding: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        }
        self.floatingButtonBottomMargin.constant = keyboardFrame.height + Constants.Constraints.acceptButtonBottomMargin - bottomPadding
        self.view.updateConstraints()
        UIView.animate(withDuration: TimeInterval(truncating: duration),
                       delay: 0,
                       options: [UIView.AnimationOptions(rawValue: UInt(truncating: curve))],
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                       },
                       completion: nil)
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        self.floatingButtonBottomMargin.constant = Constants.Constraints.acceptButtonBottomMargin
        self.view.setNeedsLayout()
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? 0.25
        UIView.animate(withDuration: TimeInterval(truncating: duration)) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func hideKeyboard() {
        self.isEditing = false
        self.view.endEditing(true)
    }
    
    func setupView() {
        self.setupIcon()
        self.setupLabels()
        self.setupInputCodeView()
        self.setupForgotSignatureButton()
        self.setupFloatingButton()
        self.setAccessibilityIdentifiers()
    }
    
    func setupIcon() {
        self.signatureImage.image = Assets.image(named: Constants.iconName)
    }
    
    func setupLabels() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.titleLabel.configureText(withKey: Constants.titleKey)
        self.descriptionLabel.font = .typography(fontName: .oneH100Regular)
        self.descriptionLabel.textColor = .oneLisboaGray
        let positions = self.presenter.signature.positions?.map { StringPlaceholder(.number, String($0)) }
        self.descriptionLabel.configureText(withLocalizedString: localized(Constants.descriptionKey, positions ?? []))
    }
    
    func setupInputCodeView() {
        self.facade.setConstants(elementsNumber: self.presenter.signature.length ?? 0)
        self.pinContainerView.addSubview(self.inputCodeView)
        NSLayoutConstraint.activate([
            self.inputCodeView.leadingAnchor.constraint(equalTo: self.pinContainerView.leadingAnchor),
            self.inputCodeView.trailingAnchor.constraint(equalTo: self.pinContainerView.trailingAnchor),
            self.inputCodeView.topAnchor.constraint(equalTo: self.pinContainerView.topAnchor),
            self.inputCodeView.bottomAnchor.constraint(equalTo: self.pinContainerView.bottomAnchor)
        ])
    }
    
    func setupForgotSignatureButton() {
        self.forgotSignatureButton.configureButton(type: .secondary,
                                                   style: OneAppLink.ButtonContent(text: localized(Constants.forgotSignatureButtonKey),
                                                                                   icons: .none))
        self.forgotSignatureButton.addTarget(self, action: #selector(forgotSignatureButtonSelected), for: .touchUpInside)
    }
    
    func setupFloatingButton() {
        self.floatingButton.configureWith(
            type: OneFloatingButton.ButtonType.primary,
            size: OneFloatingButton.ButtonSize.medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized(Constants.floatingButtonKey),
                                                                icons: .right,
                                                                fullWidth: true)),
            status: OneFloatingButton.ButtonStatus.ready)
        self.floatingButton.addTarget(self, action: #selector(acceptButtonSelected), for: .touchUpInside)
        self.disableAccept()
    }
    
    func setAccessibilityIdentifiers() {
        self.signatureImage.accessibilityIdentifier = AccessibilitySendMoneySignature.signatureIcon
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneySignature.signatureTitle
        self.descriptionLabel.accessibilityIdentifier = AccessibilitySendMoneySignature.signatureSubtitle
        self.forgotSignatureButton.accessibilityIdentifier = AccessibilitySendMoneySignature.signatureRemember
    }
    
    @objc func forgotSignatureButtonSelected() {
        let forgotView = OneElectronicSignatureForgotView()
        forgotView.delegate = self
        BottomSheet().show(in: self,
                           type: .custom(height: nil, isPan: true, bottomVisible: true),
                           component: .all,
                           view: forgotView)
    }
    
    func getSignatureErrorViewModel(for type: SignatureDialogType) -> OneElectronicSignatureErrorViewModel? {
        switch type {
        case .invalid:
            return OneElectronicSignatureErrorViewModel(iconName: "oneIcnAlert",
                                                        titleKey: "signing_title_popup_error",
                                                        subtitleKey: "operative_error_SIGBRO_00003",
                                                        floatingButtonText: localized("otp_button_accept"),
                                                        floatingButtonAction: { [weak self] in
                                                            self?.reset()
                                                        },
                                                        viewAccessibilityIdentifier: AccessibilitySendMoneySignature.IncorrectPasswordView.incorrectPasswordView)
        case .revoked(let phoneNumber, let action, let gpAction):
            return OneElectronicSignatureErrorViewModel(iconName: "oneIcnInputClose",
                                                        titleKey: "signing_title_popup_blocked",
                                                        subtitleKey: "signing_text_popup_blocked_withoutNumber",
                                                        floatingButtonText: localized("signing_button_call", [StringPlaceholder(.phone, phoneNumber ?? "")]),
                                                        floatingButtonAction: action,
                                                        gpButtonText: localized("generic_button_globalPosition"),
                                                        gpButtonAction: gpAction,
                                                        viewAccessibilityIdentifier: AccessibilitySendMoneySignature.BlockedView.blockedView)
        default:
            return nil
        }
    }
    
    func showSignatureError(viewModel: OneElectronicSignatureErrorViewModel) {
        let errorView = OneElectronicSignatureErrorView()
        errorView.delegate = self
        errorView.setViewModel(viewModel)
        BottomSheet().show(in: self,
                           type: .custom(height: nil, isPan: true, bottomVisible: true),
                           component: .all,
                           view: errorView)
    }
    
    @objc func acceptButtonSelected() {
        self.presenter.didSelectAccept(withValues: self.inputCodeView.fulfilledText()?.compactMap { String($0) } ?? [])
    }
}

extension OneElectronicSignatureViewController: InputCodeViewDelegate {
    func codeView(_ view: InputCodeView, didChange string: String, for position: Int) {
        if view.isFulfilled() {
            self.enableAccept()
        } else {
            self.disableAccept()
        }
    }
    
    func codeView(_ view: InputCodeView, willChange string: String, for position: Int) -> Bool {
        if string.count == .zero { return true }
        guard string.count > .zero,
              let character = UnicodeScalar(string),
              view.charactersSet.contains(character) else {
            return false
        }
        return true
    }
    
    func codeView(_ view: InputCodeView, didBeginEditing position: Int) {
        view.setBoxView(position: position,
                        backgroundColor: Constants.InputBox.Selected.backgroundColor,
                        borderWidth: Constants.InputBox.Selected.borderWidth,
                        borderColor: Constants.InputBox.Selected.borderColor)
    }
    
    func codeView(_ view: InputCodeView, didEndEditing position: Int) {
        view.setBoxView(position: position,
                        backgroundColor: Constants.InputBox.Deselected.backgroundColor,
                        borderWidth: Constants.InputBox.Deselected.borderWidth,
                        borderColor: Constants.InputBox.Deselected.borderColor)
    }
}

extension OneElectronicSignatureViewController: OneElectronicSignatureForgotViewDelegate {
    func didTapAcceptButton() {
        self.dismiss(animated: true)
    }
}

extension OneElectronicSignatureViewController: OneElectronicSignatureErrorViewDelegate {
    func didTapFloatingButton(action: (() -> Void)?) {
        self.dismiss(animated: true) {
            action?()
        }
    }
    
    func didTapGpButton(action: (() -> Void)?) {
        self.dismiss(animated: true) {
            action?()
        }
    }
}

//MARK: - FloatingButtonLoaderCapable

extension OneElectronicSignatureViewController {
    
    var oneFloatingButton: OneFloatingButton {
        return self.floatingButton
    }
    
    func dismissLoading(completion: (() -> Void)?) {
        self.hideLoading()
        completion?()
    }
}
