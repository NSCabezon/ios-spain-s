//
//  RecipientBankView.swift
//  TransferOperatives-TransferOperatives
//
//  Created by José María Jiménez Pérez on 25/1/22.
//

import Foundation
import UI
import UIOneComponents
import CoreFoundationLib

struct RecipientBankViewModel {
    let bicSwift: String?
    let bankName: String?
    let bankAddress: String?
    let swiftHelperUrl: String
    let swiftHelperDefaultImageKey: String
}

struct RecipientBankViewOutput {
    var bicSwift: String?
    var bankName: String?
    var bankAddress: String?
}

protocol RecipientBankViewDelegate: AnyObject {
    func saveRecipientBankViewOutput(_ output: RecipientBankViewOutput)
    func hasEdited(_ field: String?)
}

final class RecipientBankView: XibView {
    @IBOutlet private weak var recipientBankTitle: UILabel!
    @IBOutlet private weak var recipientBankContent: UIStackView!
    @IBOutlet private weak var bicSwiftContainerView: UIView!
    @IBOutlet private weak var bicSwiftLabel: OneLabelView!
    @IBOutlet private weak var bicSwiftInputRegular: OneInputRegularView!
    @IBOutlet private weak var bankNameContainerView: UIView!
    @IBOutlet private weak var bankNameLabel: OneLabelView!
    @IBOutlet private weak var bankNameInput: OneInputRegularView!
    @IBOutlet private weak var bankAddressLabel: OneLabelView!
    @IBOutlet private weak var bankAddressInput: OneInputRegularView!
    
    private var viewModel: RecipientBankViewModel?
    private var output = RecipientBankViewOutput()
    weak var delegate: RecipientBankViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAccesibilityIds()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAccesibilityIds()
    }
    
    func setupViewModel(_ viewModel: RecipientBankViewModel) {
        self.viewModel = viewModel
        if let bankName = viewModel.bankName, !bankName.isEmpty {
            self.bankNameContainerView.isHidden = false
            self.bicSwiftContainerView.isHidden = true
            self.bankNameInput.setInputText(bankName)
            if let bankAddress = viewModel.bankAddress {
                self.bankAddressInput.setInputText(bankAddress)
            }
        }
        self.bicSwiftInputRegular.setInputText(viewModel.bicSwift)
    }
}

private extension RecipientBankView {
    enum Constants {
        static let maxSwiftCharacters = 11
        static let bankNameLength = 50
        static let addressLength = 50
        enum Fields {
            static let bicSwift: String = "bic_swift"
            static let bankName: String = "bank_name"
            static let bankAddress: String = "bank_address"
        }
    }
    
    var swiftHelpView: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 303).isActive = true
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.fullFit(topMargin: 0, bottomMargin: 16, leftMargin: 0, rightMargin: 0)
        imageView.contentMode = .scaleAspectFit
        guard let defaultImageKey = self.viewModel?.swiftHelperDefaultImageKey else { return view }
        _ = imageView.setImage(url: self.viewModel?.swiftHelperUrl, placeholder: Assets.image(named: defaultImageKey))
        return view
    }
    func setupViews() {
        self.recipientBankTitle.configureText(withKey: "sendMoney_label_recipientBank")
        self.recipientBankTitle.font = .typography(fontName: .oneH100Bold)
        self.recipientBankTitle.textColor = .oneLisboaGray
        self.bicSwiftLabel.setupViewModel(
            OneLabelViewModel(type: .helperAndAction,
                              mainTextKey: "sendMoney_label_bicSwift",
                              actionTextKey: "sendMoney_button_dontHaveBicSwift",
                              helperAction: self.showBottomSheet,
                              action: self.toggleViews,
                              accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.bicSuffix,
                              actionTextLabelKey: nil)
        )
        self.bicSwiftInputRegular.setupTextField(
            OneInputRegularViewModel(status: .activated,
                                     placeholder: "sendMoney_hint_bic",
                                     accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.bicSuffix)
        )
        self.bicSwiftInputRegular.delegate = self
        self.bicSwiftInputRegular.maxCounter = Constants.maxSwiftCharacters
        self.bankNameLabel.setupViewModel(
            OneLabelViewModel(type: .action,
                              mainTextKey: "sendMoney_label_receivingBankName",
                              actionTextKey: "sendMoney_button_haveBicSwift",
                              action: self.toggleViews,
                              accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.bankNameSuffix)
        )
        self.bankNameInput.setupTextField(
            OneInputRegularViewModel(status: .activated,
                                     placeholder: "sendMoney_label_nameBank",
                                     accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.bankNameSuffix)
        )
        self.bankNameInput.delegate = self
        self.bankNameInput.maxCounter = Constants.bankNameLength
        self.bankAddressLabel.setupViewModel(
            OneLabelViewModel(type: .normal,
                              mainTextKey: "sendMoney_label_optionalBankAddress",
                              accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.optionalBankAddress)
        )
        self.bankAddressInput.setupTextField(
            OneInputRegularViewModel(status: .activated,
                                     placeholder: "sendMoney_label_bankAddress",
                                     accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.optionalBankAddress)
        )
        self.bankAddressInput.delegate = self
        self.bankAddressInput.maxCounter = Constants.addressLength
    }
    
    func setupAccesibilityIds() {
        self.recipientBankTitle.accessibilityIdentifier = AccessibilitySendMoneyAmountNoSepa.recipientBank
    }
    
    func toggleViews() {
        self.bicSwiftContainerView.isHidden = !self.bicSwiftContainerView.isHidden
        self.bankNameContainerView.isHidden = !self.bankNameContainerView.isHidden
        if self.bicSwiftContainerView.isHidden {
            self.bicSwiftInputRegular.setInputText("")
            self.output.bicSwift = nil
        } else {
            self.bankNameInput.setInputText("")
            self.output.bankName = nil
            self.bankAddressInput.setInputText("")
            self.output.bankAddress = nil
        }
        self.delegate?.saveRecipientBankViewOutput(self.output)
    }
    
    func showBottomSheet() {
        guard let viewController = self.parentContainerViewController() else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: viewController,
                         type: .custom(isPan: true, bottomVisible: false),
                         component: .all,
                         view: self.swiftHelpView)
    }
}

extension RecipientBankView: OneInputRegularViewDelegate {
    func textDidChange(_ text: String) {
        self.output.bicSwift = self.bicSwiftInputRegular.getInputText()
        self.output.bankName = self.bankNameInput.getInputText()
        self.output.bankAddress = self.bankAddressInput.getInputText()
        self.delegate?.saveRecipientBankViewOutput(self.output)
    }
    
    func shouldReturn() { }
    
    func didEndEditing(_ view: OneInputRegularView) {
        let editedField: String? = {
            switch view {
            case self.bicSwiftInputRegular:
                return Constants.Fields.bicSwift
            case self.bankNameInput:
                return Constants.Fields.bankName
            case self.bankAddressInput:
                return Constants.Fields.bankAddress
            default:
                return nil
            }
            return nil
        }()
        self.delegate?.hasEdited(editedField)
    }
}
