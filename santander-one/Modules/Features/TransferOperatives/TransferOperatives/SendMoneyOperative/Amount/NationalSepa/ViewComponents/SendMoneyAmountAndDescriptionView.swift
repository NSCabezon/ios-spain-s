//
//  SendMoneyAmountAndDescriptionView.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 28/9/21.
//

import UI
import UIOneComponents
import CoreFoundationLib
import UIKit

public protocol SendMoneyAmountAndDescriptionViewDelegate: AnyObject {
    func saveAmountAndDescription(amount: String, description: String?)
}

public protocol SendMoneyAmountAndDescriptionViewProtocol {
    func updateCurrency(currencyCode: String?)
}

public final class SendMoneyAmountAndDescriptionView: XibView, SendMoneyAmountAndDescriptionViewProtocol {
    @IBOutlet private weak var oneLabelAmountView: OneLabelView!
    @IBOutlet private weak var oneLabelDescriptionView: OneLabelView!
    @IBOutlet private weak var oneTextFieldView: OneInputRegularView!
    @IBOutlet private weak var amountView: OneInputAmountView!
    @IBOutlet private weak var oneLabelCurrencyView: OneLabelView!
    @IBOutlet private weak var oneInputSelectView: OneInputSelectView!
    @IBOutlet private weak var currencyStackView: UIStackView!
    public weak var delegate: SendMoneyAmountAndDescriptionViewDelegate?
    private var isCurrencyEditable: Bool = false
    private var bottomSheet: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAmountView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAmountView()
    }
    
    public func setDescriptionView(maxCounterLabel: String, actualCounterLabel: String) {
        let viewModel = OneInputRegularViewModel(status: .activated, placeholder: localized("sendMoney_hint_description"))
        self.oneTextFieldView.setupTextField(viewModel)
        let oneLabelViewModel = OneLabelViewModel(type: .counter, mainTextKey: localized("sendMoney_label_description"), actualCounterLabel: actualCounterLabel, maxCounterLabel: maxCounterLabel, counterLabelsAccessibilityText: localized("voiceover_numberTotalCharacters", [.init(.number, "\(actualCounterLabel)"), .init(.number, "\(maxCounterLabel)")]).text)
        self.oneLabelDescriptionView.setupViewModel(oneLabelViewModel)
        self.oneLabelDescriptionView.setAccessibilitySuffix(AccessibilitySendMoneyAmount.descriptionSuffix)
        self.oneTextFieldView.maxCounter = Int(maxCounterLabel)
        self.oneTextFieldView.charactersDelegate = self
        self.setAccessibility {
            self.setAccessibilityInfo(maxCounterLabel: maxCounterLabel)
        }
    }
    
    public func textFieldFirstResponder () {
        if !UIAccessibility.isVoiceOverRunning {
            self.amountView.textFieldFirstResponder()
        }
    }
    
    public func getAmount() -> String {
        return self.amountView.getAmount()
    }
    
    public func setAmount(_ amount: String){
        let decimalAmount = amount.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
        self.amountView.setAmount(decimalAmount)
    }
    
    public func getDescription() -> String? {
        return self.oneTextFieldView.getInputText()
    }
    
    public func setDescription(_ description: String) {
        self.oneTextFieldView.setInputText(description)
        self.oneLabelDescriptionView.setActualCounterLabel(String(description.count))
    }
    
    public func setBottomSheet(isCurrencyEditable: Bool, bottomSheetView: UIView, currencyCode: String?) {
        self.isCurrencyEditable = isCurrencyEditable
        self.bottomSheet = bottomSheetView
        self.setAmountView(bottomSheetView: bottomSheetView, currencyCode: currencyCode)
    }
    
    public func updateCurrency(currencyCode: String?) {
        self.setAmountView(bottomSheetView: self.bottomSheet, currencyCode: currencyCode)
    }
}

private extension SendMoneyAmountAndDescriptionView {
    func setAmountView(bottomSheetView: UIView? = nil, currencyCode: String? = nil) {
        self.amountView.delegate = self
        let oneLabelViewModel = OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_amount")
        self.oneLabelAmountView.setupViewModel(oneLabelViewModel)
        self.oneLabelAmountView.setAccessibilitySuffix(AccessibilitySendMoneyAmount.amountSuffix)
        let viewModel = self.getOneInputAmountViewModel()
        self.amountView.setupTextField(viewModel)
        let labelCurrencyViewModel = OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_currency")
        self.oneLabelCurrencyView.setupViewModel(labelCurrencyViewModel)
        self.setCurrencyView(view: bottomSheetView, currencyCode: currencyCode)
    }
    
    func setAccessibilityInfo(maxCounterLabel: String) {
        self.oneLabelAmountView.setAccessibilityLabel(accessibilityLabel: localized("voiceover_insertAmount"))
        self.oneLabelDescriptionView.setAccessibilityLabel(accessibilityLabel: localized("voiceover_insertConcept", [.init(.number, "\(maxCounterLabel)")]).text)
    }
    
    func getOneInputAmountViewModel() -> OneInputAmountViewModel {
        var type: OneInputAmountViewModel.AmountType = .text
        if self.isCurrencyEditable {
            type = .unowned
        }
        return OneInputAmountViewModel(status: .activated,
                                       type: type,
                                       placeholder: "0,00")
    }
    
    func setCurrencyView(view: UIView?, currencyCode: String?) {
        self.currencyStackView.isHidden = !self.isCurrencyEditable
        guard let view = view else { return }
        let inputSelectViewModel = OneInputSelectViewModel(type: .bottomSheet(view: view),
                                                           status: .activated,
                                                           pickerData: [currencyCode ?? ""],
                                                           selectedInput: 0)
        self.oneInputSelectView.setViewModel(inputSelectViewModel)
    }
}

extension SendMoneyAmountAndDescriptionView: OneInputRegularCharactersDelegate {
    public func updateNumberOfCharacters(_ total: Int) {
        self.oneLabelDescriptionView.setActualCounterLabel(String(total))
        self.delegate?.saveAmountAndDescription(amount: self.amountView.getAmount(), description: self.oneTextFieldView.getInputText())
    }
}

extension SendMoneyAmountAndDescriptionView: OneInputAmountViewDelegate {
    public func textFielEndEditing() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.oneLabelDescriptionView)
    }
    
    public func textFieldDidChange() {
        self.delegate?.saveAmountAndDescription(amount: self.amountView.getAmount(), description: self.oneTextFieldView.getInputText())
    }
}

extension SendMoneyAmountAndDescriptionView: AccessibilityCapable {}
