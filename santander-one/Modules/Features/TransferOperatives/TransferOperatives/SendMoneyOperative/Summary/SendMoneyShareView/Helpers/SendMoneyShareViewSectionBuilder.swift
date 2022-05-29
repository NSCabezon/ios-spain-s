//
//  SendMoneyShareViewSectionBuilder.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 5/4/22.
//

import CoreFoundationLib
import CoreDomain

struct SendMoneyShareViewSectionBuilder {
    let dependenciesResolver: DependenciesResolver
    let operativeData: SendMoneyOperativeData
    let fullName: String?
    
    enum SummaryShareType {
        case nationalSepa, noSepa
    }
    
    func buildSummaryFor(_ type: SummaryShareType) -> [UIView] {
        switch type {
        case .nationalSepa:
            return [
                SendMoneyShareItem.headerImage.view,
                self.addGreetingSection(),
                self.addAmountSection(),
                self.addDescriptionSection(),
                self.addSendDate(),
                self.addSender(),
                self.addRecipient()
            ]
        case .noSepa:
            return [
                SendMoneyShareItem.headerImage.view,
                self.addGreetingSection(),
                self.addAmountSection(),
                self.addDescriptionSection(),
                self.addPaymentCosts(),
                self.addNoSepaSendDate(),
                self.addSender(),
                self.addNoSepaRecipient()
            ]
        }
    }
}

private extension SendMoneyShareViewSectionBuilder {
    func addGreetingSection() -> UIView {
        let view = SendMoneyShareItem.greeting(value: self.nameTitle, accessibilityId: AccessibilitySendMoneySummary.ShareView.nameTitle).view
        return view
    }
    
    func addAmountSection() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        let value = self.operativeData.type == .noSepa ? self.noSepaAmountText : self.amountText
        let items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_amount", isBold: false),
            .attributedString(value: value ?? NSAttributedString(), accessibilityId: AccessibilitySendMoneySummary.ShareView.amountText),
            .separator
        ]
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addDescriptionSection() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        var description = "onePay_label_notConcept"
        if let desc = self.operativeData.description, desc.isNotEmpty {
            description = desc
        }
        let items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_concept", isBold: false),
            .label(keyOrValue: description, isBold: true, accessibilityId: AccessibilitySendMoneySummary.ShareView.descriptionText),
            .separator
        ]
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addSendDate() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        let items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_sendingDate", isBold: false),
            .label(keyOrValue: self.formattedDate, isBold: true, accessibilityId: AccessibilitySendMoneySummary.ShareView.sentDateText),
            .separator
        ]
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addSender() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        let items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_remitter", isBold: false),
            .labelAndImage(keyOrValue: self.operativeData.selectedAccount?.ibanRepresentable?.ibanShort(asterisksCount: 4) ?? "", imageKeyOrUrl: self.bankLogoURLFrom(ibanRepresentable: self.operativeData.selectedAccount?.ibanRepresentable), accessibilityId:  AccessibilitySendMoneySummary.ShareView.senderAccountText),
            .separator
        ]
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addRecipient() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        let items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_recipient", isBold: false),
            .label(keyOrValue: self.operativeData.destinationIBANRepresentable?.ibanShort(asterisksCount: 4) ?? "", isBold: true, accessibilityId: AccessibilitySendMoneySummary.ShareView.recipientAccountText)
        ]
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addPaymentCosts() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        var items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_paymentCost", isBold: false),
            .label(keyOrValue: self.operativeData.expenses?.titleKey ?? "", isBold: true, accessibilityId: AccessibilitySendMoneySummary.ShareView.recipientAccountText)
        ]
        if let showsWarning = self.operativeData.expenses?.showsWarning, showsWarning {
            items.append(.label(keyOrValue: "share_item_feesBank", isBold: false))
        }
        items.append(.separator)
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addNoSepaSendDate() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        let items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_sendingDate", isBold: false),
            .label(keyOrValue: "sendMoney_label_today", isBold: true),
            .label(keyOrValue: "share_item_transferInterArrives", isBold: false),
            .separator
        ]
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func addNoSepaRecipient() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        var items: [SendMoneyShareItem] = [
            .label(keyOrValue: "share_item_recipient", isBold: false),
            .label(keyOrValue: self.operativeData.destinationIBANRepresentable?.ibanShort(asterisksCount: 4) ?? "", isBold: true, accessibilityId: AccessibilitySendMoneySummary.ShareView.recipientAccountText)
        ]
        if let swift = self.operativeData.bicSwift, swift.isNotEmpty {
            items.append(.label(keyOrValue: swift, isBold: false))
        } else if let bankName = self.operativeData.bankName, bankName.isNotEmpty {
            items.append(.label(keyOrValue: bankName, isBold: false))
            if let bankAddress = self.operativeData.bankAddress, bankAddress.isNotEmpty {
                items.append(.label(keyOrValue: bankAddress, isBold: false))
            }
        }
        items.forEach { stackView.addArrangedSubview($0.view) }
        return stackView
    }
    
    func bankLogoURLFrom(ibanRepresentable: IBANRepresentable?) -> String {
        let baseURLProvider: BaseURLProvider = self.dependenciesResolver.resolve()
        guard let ibanRepresentable = ibanRepresentable,
              let entityCode = ibanRepresentable.getEntityCode(offset: 4),
              let baseURL = baseURLProvider.baseURL
        else { return "" }

        return String(format: "%@%@/%@_%@%@",
                      baseURL,
                      GenericConstants.relativeURl,
                      ibanRepresentable.countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var amountText: NSAttributedString? {
        guard let amount = self.operativeData.amount else { return nil}
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH200Bold)
        )
        return decorator.getFormatedWithCurrencyName()
    }
    
    var noSepaAmountText: NSAttributedString? {
        guard let amount = self.operativeData.noSepaTransferValidation?.settlementAmountBenefRepresentable else { return nil}
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH200Bold)
        )
        return decorator.getFormatedWithCurrencyName()
    }
    
    var formattedDate: String {
        return dateToString(date: self.operativeData.issueDate, outputFormat: .dd_MM_yyyy_hyphen_HHmm_h, timeZone: .local) ?? ""
    }
    
    var nameTitle: LocalizedStylableText {
        return localized(
            "share_text_picture",
            [StringPlaceholder(.name, self.fullName?.camelCasedString ?? "")]
        )
    }
}
