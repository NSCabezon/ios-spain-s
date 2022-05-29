//
//  OperativeConfirmationAcceptRequestAcceptRequestViewController.swift
//  Operative
//
//  Created by Cristobal Ramos Laina on 04/12/2020.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib
import Operative

public protocol BizumConfirmationWithCommentPresenterProtocol: OperativeStepPresenterProtocol {
    func didSelectContinue(comment: String?)
}

class BizumConfirmationWithCommentViewController: UIViewController {
    @IBOutlet private weak var containerStackView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var commentView: BizumConfirmationCommentView!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    
    private let presenter: BizumConfirmationWithCommentPresenterProtocol
    let keyboardManager: KeyboardManager = KeyboardManager()
    
    public init(presenter: BizumConfirmationWithCommentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "BizumConfirmationWithCommentViewController", bundle: .module)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.keyboardManager.setDelegate(self)
        self.keyboardManager.setKeyboardButtonEnabled(true)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
    
    func addConfirmationItemView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    @objc private func continueButtonSelected() {
        self.presenter.didSelectContinue(comment: self.commentView.getComment())
    }
    
    private func continueButtonSelectedTextfield(_ textfield: EditText) {
        self.continueButtonSelected()
    }
}

private extension BizumConfirmationWithCommentViewController {
    
    func setupView() {
        self.containerStackView.drawBorder(cornerRadius: 0, color: .mediumSkyGray, width: 1)
        self.continueButton.addSelectorAction(target: self, #selector(continueButtonSelected))
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnSend.rawValue
    }

}

extension BizumConfirmationWithCommentViewController: OperativeConfirmationViewProtocol {

    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    func setContinueTitle(_ text: String) {
        self.continueButton.setTitle(text, for: .normal)
    }
    
    func add(_ confirmationItem: ConfirmationItemViewModel) {
        let confirmationItemView = ConfirmationItemView(frame: .zero)
        confirmationItemView.translatesAutoresizingMaskIntoConstraints = false
        confirmationItemView.setup(with: confirmationItem)
        self.addConfirmationItemView(confirmationItemView)
    }
    
    func add(_ confirmationItems: [ConfirmationItemViewModel]) {
        confirmationItems.forEach(add)
    }
    
    func add(_ totalViewItem: ConfirmationTotalOperationItemViewModel) {
        let total = ConfirmationTotalOperationItemView(frame: .zero)
        total.translatesAutoresizingMaskIntoConstraints = false
        total.setup(with: totalViewItem)
        self.addConfirmationItemView(total)
    }
    
    func add(_ containerItem: ConfirmationContainerViewModel) {
        let containerItemView = ConfirmationContainerView(frame: .zero)
        containerItemView.translatesAutoresizingMaskIntoConstraints = false
        containerItemView.setup(containerItem)
        self.addConfirmationItemView(containerItemView)
    }
    
    func add(_ containerView: UIView) {
        let containerItemView = containerView
        containerItemView.translatesAutoresizingMaskIntoConstraints = false
        self.addConfirmationItemView(containerItemView)
    }
    
    func add(_ containerViews: [UIView]) {
        containerViews.forEach(add)
    }
}

extension BizumConfirmationWithCommentViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"),
                                             accessibilityIdentifier: AccessibilityBizumContact.acceptButton,
                                             action: self.continueButtonSelectedTextfield,
                                             actionType: .continueAction)
    }
}
