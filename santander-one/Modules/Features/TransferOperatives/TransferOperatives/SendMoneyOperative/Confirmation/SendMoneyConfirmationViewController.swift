//
//  SendMoneyConfirmationViewController.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import UIOneComponents
import Operative
import UIKit
import UI
import CoreFoundationLib

protocol SendMoneyConfirmationView: OperativeView, FloatingButtonLoaderCapable {
    func setConfirmationItems(_ items: [OneListFlowItemViewModel])
    func setTransferAmount(_ amount: NSAttributedString)
    func addNotifyByEmail()
    func addCostsWarningWith(labelValue: String?)
}

protocol SendMoneyConfirmationNationalSepaView: SendMoneyConfirmationView { }
protocol SendMoneyConfirmationNoSepaView: SendMoneyConfirmationView { }

final class SendMoneyConfirmationViewController: UIViewController {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var confirmTitleLabel: UILabel!
    @IBOutlet private weak var confirmValueLabel: UILabel!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    @IBOutlet private weak var footerView: OneGradientView!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    
    let presenter: SendMoneyConfirmationPresenterProtocol
    private lazy var normalCheckBox: OneCheckboxView = {
        let checkBox = OneCheckboxView()
        checkBox.delegate = self
        checkBox.setViewModel(
            OneCheckboxViewModel(status: .inactive,
                                 titleKey: "sendMoney_label_notifyShipment",
                                 accessibilityActivatedLabel: localized("voiceover_notifyShipmentOption"),
                                 accessibilityNoActivatedLabel: localized("voiceover_notifyShipmentOption"))
        )
        return checkBox
    }()
    private lazy var emailView: UIView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        let spacing = UIView()
        spacing.translatesAutoresizingMaskIntoConstraints = false
        spacing.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        view.addArrangedSubview(spacing)
        let label = UILabel()
        label.textColor = .oneLisboaGray
        label.font = .typography(fontName: .oneB300Regular)
        label.text = localized("sendMoney_label_enterEmail")
        label.numberOfLines = .zero
        view.addArrangedSubview(label)
        let input = self.oneInputRegular
        view.addArrangedSubview(input)
        return view
    }()
    private lazy var oneInputRegular: OneInputRegularView = {
        let input = OneInputRegularView()
        input.setupTextField(
            OneInputRegularViewModel(status: .inactive,
                                     placeholder: localized("generic_label_email"),
                                     resetText: true)
        )
        return input
    }()
    private var notifyEmailView: UIView? = nil
    private var checkBoxSpacing: UIView? = nil
    var loadingView: UIView?
    
    init(presenter: SendMoneyConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SendMoneyConfirmationViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.presenter.viewDidLoad()
        self.setAccessibilityIdentifiers()
        self.configureTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    @IBAction private func didTapOnContinue(_ sender: Any) {
        if self.normalCheckBox.status == .activated {
            self.presenter.saveEmail(self.oneInputRegular.getInputText())
        }
        self.presenter.didTapOnContinue()
    }
}

private extension SendMoneyConfirmationViewController {
    func configureViews() {
        self.confirmTitleLabel.font = .typography(fontName: .oneB300Regular)
        self.confirmTitleLabel.textColor = .oneLisboaGray
        self.confirmTitleLabel.text = localized("confirmation_label_confirmBankTransfer")
        self.floatingButton.configureWith(
            type: .primary,
            size: .large(OneFloatingButton.ButtonSize.LargeButtonConfig(
                            title: localized("generic_button_confirm"),
                            subtitle: localized("generic_button_identityCheck"),
                            icons: .right,
                            fullWidth: true)),
            status: .ready)
        self.floatingButton.backgroundColor = .clear
        self.footerView.setupType(.oneGrayGradient())
    }
    
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "genericToolbar_title_confirmation")
            .setLeftAction(.back, customAction: self.didTapBack)
            .setRightAction(.help) {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            }
            .setRightAction(.close, action: self.didTapClose)
            .setAccessibilityTitleLabel(withKey: "genericToolbar_title_confirmation")
            .build(on: self)
    }
    
    func didTapClose() {
        self.presenter.close()
    }
    
    func didTapBack() {
        self.presenter.back()
    }

    func setAccessibilityIdentifiers() {
        self.confirmTitleLabel.accessibilityIdentifier = AccessibilitySendMoneyConfirmation.confirmTitleLabel
        self.confirmValueLabel.accessibilityIdentifier = AccessibilitySendMoneyConfirmation.confirmValueLabel
    }
    
    func setAccessibilityInfo() {
        self.floatingButton.isAccessibilityElement = true
        self.floatingButton.accessibilityLabel = localized("voiceover_button_continueIdentity").text
        self.confirmTitleLabel.isAccessibilityElement = true
        self.confirmTitleLabel.accessibilityLabel = localized("voiceover_confirmBankTransfer")
        self.confirmValueLabel.isAccessibilityElement = true
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func scrollToBottom() {
        self.contentScrollView.layoutIfNeeded()
        let bottomOffset = CGPoint(x: 0,
                                   y: contentScrollView.contentSize.height - contentScrollView.bounds.size.height + contentScrollView.contentInset.bottom)
        self.contentScrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    func configureTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SendMoneyConfirmationViewController: SendMoneyConfirmationNationalSepaView, SendMoneyConfirmationNoSepaView {
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func setConfirmationItems(_ items: [OneListFlowItemViewModel]) {
        items.forEach {
            let item = OneListFlowItemView()
            item.setupViewModel($0)
            self.stackView.addArrangedSubview(item)
        }
    }
    
    func setTransferAmount(_ amount: NSAttributedString) {
        self.confirmValueLabel.attributedText = amount
    }
    
    func addNotifyByEmail() {
        self.stackView.addArrangedSubview(self.normalCheckBox)
        let spacing = UIView()
        spacing.translatesAutoresizingMaskIntoConstraints = false
        spacing.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.checkBoxSpacing = spacing
        self.stackView.addArrangedSubview(spacing)
    }
    
    func addCostsWarningWith(labelValue: String?) {
        guard let value = labelValue else { return }
        let alertView = OneAlertView()
        alertView.setType(.textAndImage(imageKey: "icnInfo", stringKey: value))
        self.stackView.addArrangedSubview(alertView)
        let spacing = UIView()
        spacing.translatesAutoresizingMaskIntoConstraints = false
        spacing.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.stackView.addArrangedSubview(spacing)
    }
}

extension SendMoneyConfirmationViewController: OneCheckboxViewDelegate {
    func didSelectOneCheckbox(_ isSelected: Bool) {
        if isSelected {
            self.notifyEmailView = self.emailView
            guard let view = self.notifyEmailView,
                  let checkBoxSpacing = self.checkBoxSpacing
            else { return }
            self.checkBoxSpacing?.removeFromSuperview()
            self.stackView.addArrangedSubview(view)
            self.stackView.addArrangedSubview(checkBoxSpacing)
            self.scrollToBottom()
            UIAccessibility.post(notification: .layoutChanged, argument: self.emailView)
        } else {
            self.checkBoxSpacing?.removeFromSuperview()
            self.notifyEmailView?.removeFromSuperview()
            self.notifyEmailView = nil
            guard let checkBoxSpacing = self.checkBoxSpacing else { return }
            self.stackView.addArrangedSubview(checkBoxSpacing)
        }
    }
}

//MARK: - FloatingButtonLoaderCapable

extension SendMoneyConfirmationViewController {
    var oneFloatingButton: OneFloatingButton {
        self.floatingButton
    }
}

extension SendMoneyConfirmationViewController: AccessibilityCapable {}
