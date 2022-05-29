//
//  SendMoneyConfirmationBuilder.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import CoreFoundationLib
import CoreDomain

final class SendMoneyConfirmationBuilder {
    private let dependenciesResolver: DependenciesResolver
    private let operativeData: SendMoneyOperativeData
    private var items: [OneListFlowItemViewModel] = []
    
    lazy var isEditingEnabled: Bool = {
        let modifier = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
        return modifier?.isEditConfirmationEnabled ?? true
    }()
    
    init(dependenciesResolver: DependenciesResolver, operativeData: SendMoneyOperativeData) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
    }
    
    private var sendMoneyModifierProtocol: SendMoneyModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }
    
    func addSender(action: @escaping () -> Void) {
        var detailAccessibilityAttributedLabel = NSAttributedString()
        if #available(iOS 13.0, *) {
            detailAccessibilityAttributedLabel = NSAttributedString(string: self.operativeData.selectedAccount?.getIBANString ?? "", attributes:[.accessibilitySpeechSpellOut: true])
        } else {
            detailAccessibilityAttributedLabel = NSAttributedString(string: self.operativeData.selectedAccount?.getIBANString ?? "")
        }
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_item_sender"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_senderInformation")),
            .init(type: .label(keyOrValue: self.operativeData.selectedAccount?.alias?.camelCasedString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: localized("voiceover_senderAccount", [StringPlaceholder(.value, self.operativeData.selectedAccount?.alias ?? "")]).text),
            .init(type: .label(keyOrValue: self.operativeData.selectedAccount?.getIBANPapel, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1",
                  accessibilityAttributedLabel: detailAccessibilityAttributedLabel),
            .init(type: .image(imageKeyOrUrl: self.bankLogoURLFrom(ibanRepresentable: self.operativeData.selectedAccount?.ibanRepresentable)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemIcn)
        ]
        let item = OneListFlowItemViewModel(items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editSender"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.senderSuffix)
        self.items.append(item)
    }
    
    func addAmount(action: @escaping () -> Void) {
        guard let amount = self.operativeData.amount else { return }
        let decorator = AmountRepresentableDecorator(amount, font: .typography(fontName: .oneB300Regular))
        let currencyName = amount.currencyRepresentable?.currencyName ?? ""
        let description = (self.operativeData.description ?? "").isEmpty ? localized("onePay_label_notConcept") : self.operativeData.description
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_item_amountDescription"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_amountConceptInformation")),
            .init(type: .label(keyOrValue: decorator.getFormattedValue() + " " + currencyName, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: decorator.getFormattedValue() + " " + currencyName),
            .init(type: .label(keyOrValue: description, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1",
                  accessibilityAttributedLabel: NSAttributedString(string: operativeData.description ?? ""))
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editAmountConcept"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.amountSuffix)
        self.items.append(item)
    }
    
    func addSendDate(action: @escaping () -> Void) {
        let (detail, subtitle) = self.getValues()
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendDate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_sendDateInformation")),
            .init(type: .label(keyOrValue: subtitle, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: localized(subtitle)),
            .init(type: .label(keyOrValue: detail, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1",
                  accessibilityAttributedLabel: NSAttributedString(string: detail ?? ""))
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editSendDate"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.dateSuffix)
        self.items.append(item)
    }
    
    func addSendType(action: (() -> Void)? = nil) {
        switch self.operativeData.type {
        case .national:
            guard let action = action else { return }
            self.addNationalSendType(action: action)
        case .sepa: self.addSepaSendType()
        case .noSepa: self.addNoSepaSendType()
        }
        
    }
    
    func addSendDate(action: (() -> Void)? = nil) {
        switch self.operativeData.type {
        case .national: self.addNationalSendDate(action: action)
        case .sepa: self.addSepaSendDate(action: action)
        case .noSepa: self.addNoSepaSendDate()
        }
    }
    
    func addRecipient(action: @escaping () -> Void) {
        var detailAccessibilityAttributedLabel = NSAttributedString()
        if #available(iOS 13.0, *) {
            detailAccessibilityAttributedLabel = NSAttributedString(string: self.operativeData.destinationIBANRepresentable?.ibanString ?? "", attributes:[.accessibilitySpeechSpellOut: true])
        } else {
            detailAccessibilityAttributedLabel = NSAttributedString(string: self.operativeData.destinationIBANRepresentable?.ibanString ?? "")
        }
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_item_recipient"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_recipientInformation")),
            .init(type: .label(keyOrValue: self.operativeData.destinationName, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: self.operativeData.destinationName),
            .init(type: .label(keyOrValue: self.operativeData.destinationIBANRepresentable?.ibanPapel, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1",
                  accessibilityAttributedLabel: detailAccessibilityAttributedLabel),
            .init(type: .image(imageKeyOrUrl: self.bankLogoURLFrom(ibanRepresentable: self.operativeData.destinationIBANRepresentable)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemIcn)
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            isLastItem: true,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editRecipient"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.recipientSuffix)
        self.items.append(item)
    }
    
    func addNoSepaAmount(action: @escaping () -> Void) {
        guard let amount = self.operativeData.noSepaTransferValidation?.settlementAmountBenefRepresentable,
              let exangeRate = self.operativeData.noSepaTransferValidation?.tipoCambioPrecisoRepresentable?.value,
              let sourceCurrencyName = self.operativeData.selectedAccount?.currencyName,
              let convertedAmount = self.operativeData.noSepaTransferValidation?.impCargoContravalRepresentable
        else { return }
        var decorator = AmountRepresentableDecorator(amount,
                                                     font: .typography(fontName: .oneH500Bold),
                                                     decimalFont: .typography(fontName: .oneB400Bold))
        guard let attributedString = decorator.getFormatedWithCurrencyName() else { return }
        var items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_recipientWillReceive"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .attributedLabel(attributedString: attributedString), accessibilityId: AccessibilityOneComponents.oneListFlowItemText)
        ]
        if let description = self.operativeData.description, description.isNotEmpty {
            items.append(
                .init(type: .label(keyOrValue: description, isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
            )
        }
        decorator = AmountRepresentableDecorator(convertedAmount, font: .typography(fontName: .oneH200Bold), decimalFont: .typography(fontName: .oneH200Bold))
        let rate = formatterForRepresentation(.decimal(decimals: 4)).string(from: exangeRate as NSNumber) ?? ""
        let destCurrencyName = self.operativeData.currency?.code ?? self.operativeData.currencyName ?? ""
        items.append(contentsOf: [
            .init(type: .label(keyOrValue: "confirmation_item_exchangeBuyRate", isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "2"),
            .init(type: .label(keyOrValue: "1 \(sourceCurrencyName) = \(rate) \(destCurrencyName)", isBold: true), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "3"),
            .init(type: .label(keyOrValue: "confirmation_item_amountAfterConversion", isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "4"),
            .init(type: .label(keyOrValue: "\(decorator.getFormattedValue() ?? "") \(convertedAmount.currencyRepresentable?.currencyName ?? "")", isBold: true), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "5")
            
        ])
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: isEditingEnabled ? .edit(action: action) : nil,
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.recipientReceiveSuffix)
        self.items.append(item)
    }
    
    func addPaymentCosts(action: @escaping () -> Void) {
        guard let expenses = self.operativeData.expenses,
              let costs = expenses.getTransferExpensesWith(operativeData: self.operativeData) else { return }
        let decorator = AmountRepresentableDecorator(costs, font: .typography(fontName: .oneB400Bold), decimalFont: .typography(fontName: .oneB400Bold))
        guard let costString = decorator.getFormatedWithCurrencyName()?.string else { return }
        let placeHolder = StringPlaceholder(.value, costString)
        let value = localized(expenses.confirmationKey, [placeHolder]).text
        var items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_item_paymentCost"), accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: value, isBold: true), accessibilityId: AccessibilityOneComponents.oneListFlowItemText)
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) : nil,
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.paymentCostSuffix)
        self.items.append(item)
    }
    
    func addNoSepaRecipient(action: @escaping () -> Void) {
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_item_recipient"), accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: self.operativeData.destinationName ?? "", isBold: true), accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: self.operativeData.destinationAccount, isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1"),
            .init(type: .label(keyOrValue: self.getDestinationValue(), isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "2"),
            .init(type: .label(keyOrValue: self.operativeData.description, isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "3")
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            isLastItem: true,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) : nil,
                                            accessibilitySuffix: AccessibilitySendMoneyAmountNoSepa.recipientSuffix)
        self.items.append(item)
    }
    
    func build() -> [OneListFlowItemViewModel] {
        return self.items
    }
}

private extension SendMoneyConfirmationBuilder {
    func bankLogoURLFrom(ibanRepresentable: IBANRepresentable?) -> String? {
        let baseURLProvider: BaseURLProvider = self.dependenciesResolver.resolve()
        guard let ibanRepresentable = ibanRepresentable,
              let entityCode = ibanRepresentable.getEntityCode(offset: 4),
              let baseURL = baseURLProvider.baseURL
        else { return nil }

        return String(format: "%@%@/%@_%@%@",
                      baseURL,
                      GenericConstants.relativeURl,
                      ibanRepresentable.countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    func getValues() -> (String?, String) {
        var detail: String?
        var subtitle: String
        switch self.operativeData.transferDateType {
        case .now, .none:
            subtitle = "confirmation_label_today"
        case .day:
            subtitle = self.operativeData.issueDate.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        case .periodic:
            (detail, subtitle) = self.getPeriodicValue()
        }
        return (detail, subtitle)
    }
    
    func getPeriodicValue() -> (String?, String) {
        var detail: String
        let subtitle = self.operativeData.periodicalTypeTransfer?.text ?? ""
        let startDate = self.operativeData.startDate?.toString(format: TimeFormat.dd_MM_yyyy.rawValue) ?? ""
        let endDate = self.operativeData.endDate?.toString(format: TimeFormat.dd_MM_yyyy.rawValue) ?? ""
        if self.operativeData.isSelectDeadlineCheckbox {
            detail = localized("confirmation_label_dateNoDeadline", [StringPlaceholder(.date, startDate)]).text
        } else {
            detail = localized("confirmation_label_datePeriod", [StringPlaceholder(.date, startDate), StringPlaceholder(.date, endDate)]).text
        }
        return (detail, subtitle)
    }
    
    func addNationalSendType(action: @escaping () -> Void) {
        var value: String?
        var detail: String?
        if let creditCardString = sendMoneyModifierProtocol?.addSendType(operativeData: self.operativeData) {
            detail = creditCardString
        }
        if let title = self.operativeData.selectedTransferType?.type.title {
            value = localized(title)
        }
        if let _ = value, let amount = self.operativeData.selectedTransferType?.fee {
            let decorator = AmountRepresentableDecorator(amount, font: .typography(fontName: .oneB200Regular), decimalFontSize: 1)
            let currencyName = amount.currencyRepresentable?.currencyName ?? ""
            value?.append(" - \(decorator.getFormattedValue() + " " + currencyName)")
        }
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendType"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_sendTypeInformation")),
            .init(type: .label(keyOrValue: value, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: value),
            .init(type: .label(keyOrValue: detail, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editSendType"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.typeSuffix)
        self.items.append(item)
    }
    
    func addSepaSendType() {
        var value: String?
        var detail: String?
        if let creditCardString = sendMoneyModifierProtocol?.addSendType(operativeData: self.operativeData) {
            detail = creditCardString
        }
        if let title = self.operativeData.selectedTransferType?.type.title, let amount = self.operativeData.selectedTransferType?.fee {
            let decorator = AmountRepresentableDecorator(amount, font: .typography(fontName: .oneB200Regular), decimalFontSize: 1)
            if let replacement = decorator.getFormatedWithCurrencyName()?.string {
                let placeHolder = StringPlaceholder(.value, replacement)
                value = localized(title, [placeHolder]).text
            }
        }
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendType"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_sendTypeInformation")),
            .init(type: .label(keyOrValue: value, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: value),
            .init(type: .label(keyOrValue: detail, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            actionAccessibilityLabel: localized("voiceover_editSendType"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.typeSuffix)
        self.items.append(item)
    }
    
    func addNoSepaSendType() {
        guard let selectedTransferType = self.operativeData.selectedTransferType,
              let fee = selectedTransferType.fee,
              let typeKey = selectedTransferType.type.title
        else { return }
        guard let value = AmountRepresentableDecorator(fee, font: .typography(fontName: .oneB400Bold), decimalFont: .typography(fontName: .oneB400Bold)).getFormatedWithCurrencyName()?.string else { return }
        let placeholder = StringPlaceholder(.value, value)
        let stringValue = localized(typeKey, [placeholder]).text
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendType"), accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: stringValue, isBold: true), accessibilityId: AccessibilityOneComponents.oneListFlowItemText)
            
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.typeSuffix)
        self.items.append(item)
    }
    
    func addNationalSendDate(action: (() -> Void)?) {
        guard let action = action else { return }
        let (detail, subtitle) = self.getValues()
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendDate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_sendDateInformation")),
            .init(type: .label(keyOrValue: subtitle, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: subtitle),
            .init(type: .label(keyOrValue: detail, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1",
                  accessibilityAttributedLabel: NSAttributedString(string: detail ?? ""))
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editSendDate"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.dateSuffix)
        self.items.append(item)
    }
    
    func addSepaSendDate(action: (() -> Void)?) {
        guard let action = action else { return }
        var (detail, subtitle) = self.getValues()
        var items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendDate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle,
                  accessibilityLabel: localized("voiceover_sendDateInformation")),
            .init(type: .label(keyOrValue: subtitle, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText,
                  accessibilityLabel: subtitle)
        ]
        if self.operativeData.transferDateType == .now {
            detail = self.operativeData.selectedTransferType?.type.subtitle
            items.append(
                .init(type: .label(keyOrValue: detail, isBold: false),
                      accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1",
                      accessibilityAttributedLabel: NSAttributedString(string: detail ?? ""))
            )
        }
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            action: self.isEditingEnabled ? .edit(action: action) :  nil,
                                            actionAccessibilityLabel: localized("voiceover_editSendDate"),
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.dateSuffix)
        self.items.append(item)
    }
    
    func addNoSepaSendDate() {
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_sendDate"), accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: "confirmation_label_today", isBold: true), accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: "confirmation_label_transferInterArrives", isBold: false), accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        let item = OneListFlowItemViewModel(isFirstItem: false,
                                            items: items,
                                            accessibilitySuffix: AccessibilitySendMoneyConfirmation.Summary.dateSuffix)
        self.items.append(item)
    }
    
    func getDestinationValue() -> String {
        guard let bicSwift = self.operativeData.bicSwift, bicSwift.isNotEmpty else {
            return self.operativeData.bankName ?? ""
        }
        return bicSwift
    }
}

