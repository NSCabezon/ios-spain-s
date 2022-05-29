//
//  OneOTPViewController.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 9/12/21.
//

import UIKit
import Operative
import CoreFoundationLib
import UI
import UIOneComponents

final class OneOTPViewController: UIViewController, FloatingButtonLoaderCapable {

    private var presenter: OTPPresenterProtocol
    @IBOutlet private weak var titleOtp: UILabel!
    @IBOutlet private weak var subtitleOtp: UILabel!
    @IBOutlet private weak var otpTextField: OneInputRegularView!
    @IBOutlet private weak var sendAgainButton: OneAppLink!
    @IBOutlet weak var floatingButton: OneFloatingButton!
    @IBOutlet weak var floatingButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    var loadingView: UIView?

    init(presenter: OTPPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "OneOTPViewController", bundle: .module)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loaded()
        self.setupViews()
        self.configureKeyboardListener()
        self.presenter.viewDidLoad()
        self.setupAccessibilityIdentifiers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(titleKey: "toolbar_title_otp")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction private func didSelectResend(_ sender: OneAppLink) {
        self.presenter.helpButtonTouched()
    }
    
    @IBAction private func didSelectAccept(_ sender: OneFloatingButton) {
        self.presenter.validateOtp()
    }
}

private extension OneOTPViewController {
    func setupNavigationBar(titleKey: String?) {
        let title = titleKey ?? "toolbar_title_otp"
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: title)
            .setLeftAction(.back) {
                self.presenter.didTapBack()
            }
            .setRightAction(.help, action: {
                self.presenter.didSelectHelp()
            })
            .setRightAction(.close, action: {
                self.presenter.didTapClose()
            })
            .build(on: self)
    }
    
    func setupViews() {
        self.titleOtp.font = .typography(fontName: .oneH100Bold)
        self.titleOtp.textColor = .oneLisboaGray
        self.titleOtp.configureText(withKey: "otp_text_sms")
        self.subtitleOtp.font = .typography(fontName: .oneH100Regular)
        self.subtitleOtp.textColor = .oneLisboaGray
        self.subtitleOtp.configureText(withKey: "otp_text_insertCode")
        self.otpTextField.setupTextField(
            OneInputRegularViewModel(status: .inactive,
                                     alignment: .center,
                                     textSize: .large,
                                     textContentType: .otp)
        )
        self.otpTextField.delegate = self
        self.otpTextField.maxCounter = self.presenter.maxLength
        self.sendAgainButton.configureButton(
            type: .secondary,
            style: OneAppLink.ButtonContent(text: localized("otp_button_codeNotReceived"),
                                            icons: .none))
        self.sendAgainButton.isUserInteractionEnabled = true
        self.floatingButton.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(
                    title: localized("signing_button_singningContinue"),
                    icons: .right,
                    fullWidth: true)),
            status: .ready)
        self.floatingButton.isEnabled = false
    }
    
    func configureKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func getErrorViewModelFor(_ type: OTPDialogType) -> OneOTPErrorViewModel {
        return OneOTPErrorFactory(dialogType: type,
                                  supportPhone: self.presenter.supportPhone).build()
    }
    
    func setupAccessibilityIdentifiers() {
        self.titleOtp.accessibilityIdentifier = AccessibilitySendMoneyOTP.otpTitle
        self.subtitleOtp.accessibilityIdentifier = AccessibilitySendMoneyOTP.otpSubtitle
    }
}

extension OneOTPViewController: OTPViewProtocol {
    func showDialogForType(_ type: OTPDialogType) {
        let errorView = OneOTPErrorView()
        let viewModel = self.getErrorViewModelFor(type)
        errorView.setupViewModel(viewModel)
        errorView.delegate = self
        BottomSheet()
            .show(in: self,
                  type: .custom(isPan: viewModel.isDissmissable, bottomVisible: viewModel.isDissmissable),
                  component: viewModel.isDissmissable ? .all : .unowned,
                  view: errorView)
    }
    
    var otpText: String {
        self.otpTextField.getInputText() ?? ""
    }
    
    func setSubtitle(text: LocalizedStylableText) {
        self.subtitleOtp.configureText(withLocalizedString: text)
    }
    
    func cleanTextField() {
        self.otpTextField.setInputText("")
    }
    
    func updateText(_ text: String) {
        self.otpTextField.setInputText(text)
    }
    
    func enableAcceptButton() {
        self.floatingButton.isEnabled = true
    }
    
    func setNavigationBuilderTitle(_ title: String?) {
        self.setupNavigationBar(titleKey: title)
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func showKeyboard() {
        _ = self.otpTextField.becomeFirstResponder()
    }
    
    var code: String {
        self.otpText
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
}

extension OneOTPViewController: FloatingButtonKeyboardHelper {
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardWillShowWithFloatingButton(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardWillHideWithFloatingButton(notification)
    }
}

extension OneOTPViewController: OneInputRegularViewDelegate {
    func textDidChange(_ text: String) {
        self.floatingButton.isEnabled = text.count == presenter.maxLength
    }
    
    func shouldReturn() {
        self.dismissKeyboard()
    }
}

extension OneOTPViewController: OneOTPErrorViewDelegate {
    func oneOTPErrorViewDidTapAccept(viewController: UIViewController?, action: (() -> Void)?, shouldDissmiss: Bool) {
        guard shouldDissmiss else {
            action?()
            return
        }
        viewController?.dismiss(animated: true) {
            action?()
        }
    }
}

//MARK: - FloatingButtonLoaderCapable

extension OneOTPViewController {
    
    var oneFloatingButton: OneFloatingButton {
        return self.floatingButton
    }
    
    func dismissLoading(completion: (() -> Void)?) {
        self.hideLoading()
        completion?()
    }
}
