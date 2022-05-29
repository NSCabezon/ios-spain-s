//
//  AmountAndDateView.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 25/1/22.
//

import Foundation
import UI
import UIOneComponents
import CoreFoundationLib
import UIKit
import CoreDomain

struct AmountAndDateViewModel {
    let isCurrencyEditable: Bool
    var currencyCode: String?
    let amount: AmountRepresentable?
    let description: String?
    let selectedExpense: SendMoneyNoSepaExpensesProtocol?
    let expenses: [SendMoneyNoSepaExpensesProtocol]?
    var pdfAction: (() -> Void)?
}

protocol AmountAndDateViewDelegate: AnyObject {
    func didUpdateAmount(to amount: String)
    func didUpdateDescription(to description: String?)
}

final class AmountAndDateView: XibView, SendMoneyAmountAndDescriptionViewProtocol {
    
    private enum Constants {
        static let descriptionMaxInput = 140
    }
    
    @IBOutlet private weak var amountAndDateTitle: UILabel!
    @IBOutlet private weak var amountLabelView: OneLabelView!
    @IBOutlet private weak var amountInput: OneInputAmountView!
    @IBOutlet private weak var currencyStackView: UIStackView!
    @IBOutlet private weak var currencyLabelView: OneLabelView!
    @IBOutlet private weak var currencyInput: OneInputSelectView!
    @IBOutlet private weak var warningContainer: OneAlertView!
    @IBOutlet private weak var costLabelView: OneLabelView!
    @IBOutlet private weak var costInputView: OneInputSelectView!
    @IBOutlet private weak var costLinkView: OneAppLink!
    @IBOutlet private weak var descriptionLabelView: OneLabelView!
    @IBOutlet private weak var descriptionInput: OneInputRegularView!
    @IBOutlet private weak var dateOfSendingTitle: UILabel!
    @IBOutlet private weak var dateOfSendingValue: UILabel!
    
    private lazy var costsBottomSheetView = UIView()
    private var viewModel: AmountAndDateViewModel?
    private var bottomSheetView: UIView?
    weak var delegate: AmountAndDateViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAccessibilityIds()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAccessibilityIds()
    }
    
    func setupViewModel(_ viewModel: AmountAndDateViewModel, bottomSheetView: UIView, costsBottomSheetView: UIView) {
        self.viewModel = viewModel
        self.costsBottomSheetView = costsBottomSheetView
        if viewModel.isCurrencyEditable {
            self.bottomSheetView = bottomSheetView
            self.currencyStackView.isHidden = false
            self.amountInput.setupTextField(OneInputAmountViewModel(status: .activated,
                                                                    type: .unowned,
                                                                    placeholder: "0,00"))
            self.currencyInput.setViewModel(
                OneInputSelectViewModel(type: .bottomSheet(view: bottomSheetView),
                                        status: .activated,
                                        pickerData: [viewModel.currencyCode ?? ""],
                                        selectedInput: 0,
                                        accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.currencySuffix)
            )
        } else {
            self.amountInput.setupTextField(
                OneInputAmountViewModel(status: .activated,
                                        type: .text,
                                        placeholder: "0,00",
                                        amountRepresentable: AmountRepresented(value: 0, currencyRepresentable: CurrencyRepresented(currencyName: viewModel.currencyCode, currencyCode: viewModel.currencyCode ?? ""))
                                       )
            )
        }
        self.costInputView.setViewModel(OneInputSelectViewModel(type: .bottomSheet(view: self.costsBottomSheetView, type: .auto),
                                                                status: .activated,
                                                                pickerData: [viewModel.selectedExpense?.titleKey ?? ""],
                                                                selectedInput: 0,
                                                                accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.costSuffix))
        if let value = viewModel.amount?.value {
            self.amountInput.setAmount(String(describing: value))
        }
        if let description = viewModel.description {
            self.descriptionInput.setInputText(description)
        }
        if let showsWarning = viewModel.selectedExpense?.showsWarning {
            self.warningContainer.isHidden = !showsWarning
        }
    }
    
    func updateCurrency(currencyCode: String?) {
        self.viewModel?.currencyCode = currencyCode
        guard let viewModel = self.viewModel,
            let bottomSheetView = self.bottomSheetView else { return }
        self.setupViewModel(viewModel, bottomSheetView: bottomSheetView, costsBottomSheetView: self.costsBottomSheetView)
    }
}

private extension AmountAndDateView {
    func setupViews() {
        self.amountAndDateTitle.configureText(withKey: "sendMoney_label_amoundDate")
        self.amountAndDateTitle.font = .typography(fontName: .oneH100Bold)
        self.amountAndDateTitle.textColor = .oneLisboaGray
        self.amountLabelView.setupViewModel(OneLabelViewModel(type: .normal,
                                                              mainTextKey: "sendMoney_label_recipientWillReceive",
                                                              accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.recipientSuffix))
        self.amountInput.setupTextField(OneInputAmountViewModel(status: .activated,
                                                                type: .text,
                                                                placeholder: "0,00"))
        self.amountInput.delegate = self
        self.currencyStackView.isHidden = true
        self.currencyLabelView.setupViewModel(OneLabelViewModel(type: .normal,
                                                                mainTextKey: "sendMoney_label_currency",
                                                                accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.currencySuffix))
        self.warningContainer.setType(.textAndImage(imageKey: "icnInfo", stringKey: "sendMoney_label_helperAmountAndFees"))
        self.costLabelView.setupViewModel(OneLabelViewModel(type: .normal,
                                                            mainTextKey: "sendMoney_label_expensesPay",
                                                            accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.costSuffix))
        self.costLinkView.configureButton(type: .secondary, style: OneAppLink.ButtonContent(text: localized("generic_button_showFees"), icons: .none))
        self.costLinkView.setAlignment(.left)
        self.descriptionLabelView.setupViewModel(OneLabelViewModel(type: .counter,
                                                                   mainTextKey: "sendMoney_label_optionalConcept",
                                                                   actualCounterLabel: "0",
                                                                   maxCounterLabel: String(Constants.descriptionMaxInput),
                                                                   accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.conceptSuffix))
        self.descriptionInput.setupTextField(OneInputRegularViewModel(status: .activated,
                                                                      placeholder: "sendMoney_hint_description",
                                                                      accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.conceptSuffix))
        self.descriptionInput.charactersDelegate = self
        self.descriptionInput.maxCounter = Constants.descriptionMaxInput
        self.dateOfSendingTitle.configureText(withKey: "sendMoney_label_dateSending")
        self.dateOfSendingTitle.font = .typography(fontName: .oneB300Regular)
        self.dateOfSendingTitle.textColor = .oneLisboaGray
        self.dateOfSendingValue.configureText(withKey: "sendMoney_label_today")
        self.dateOfSendingValue.font = .typography(fontName: .oneB400Bold)
        self.dateOfSendingValue.textColor = .oneBrownishGray
    }
    
    func setupAccessibilityIds() {
        self.amountAndDateTitle.accessibilityIdentifier = AccessibilitySendMoneyAmountNoSepa.amountAndDate
        self.dateOfSendingTitle.accessibilityIdentifier = AccessibilitySendMoneyAmountNoSepa.dateSending
        self.dateOfSendingValue.accessibilityIdentifier = AccessibilitySendMoneyAmountNoSepa.dateSendingToday
    }
    
    @IBAction func didTapShowFees(_ sender: OneAppLink) {
        self.viewModel?.pdfAction?()
    }
}

extension AmountAndDateView: OneInputAmountViewDelegate {
    func textFieldDidChange() {
        self.delegate?.didUpdateAmount(to: self.amountInput.getAmount())
    }
    
    func textFielEndEditing() { }
}

extension AmountAndDateView: OneInputRegularCharactersDelegate {
    func updateNumberOfCharacters(_ total: Int) {
        self.descriptionLabelView.setActualCounterLabel(String(total))
        self.delegate?.didUpdateDescription(to: self.descriptionInput.getInputText())
    }
}
