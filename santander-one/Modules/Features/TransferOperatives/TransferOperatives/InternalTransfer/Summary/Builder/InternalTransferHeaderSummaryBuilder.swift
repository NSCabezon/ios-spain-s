//
//  InternalTransferHeaderSummaryBuilder.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 11/3/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UIOneComponents

final class InternalTransferHeaderSummaryBuilder {
    private let dependencies: InternalTransferSummaryDependenciesResolver
    private let operativeData: InternalTransferOperativeData
    private var summaryItems: [OneListFlowItemViewModel] = []
    private lazy var defaultCurrency: CurrencyType = NumberFormattingHandler.shared.getDefaultCurrency()
    private lazy var modifier: InternalTransferSummaryModifierProtocol = dependencies.external.resolve()
    
    init(dependencies: InternalTransferSummaryDependenciesResolver, operativeData: InternalTransferOperativeData) {
        self.dependencies = dependencies
        self.operativeData = operativeData
    }
    
    func addSourceAccount() {
        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "confirmation_label_originAccount"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: operativeData.originAccount?.alias,
                               isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: operativeData.originAccount?.getIBANPapel,
                               isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1"),
            .init(type: .image(imageKeyOrUrl: bankLogoURLFrom(ibanRepresentable: operativeData.originAccount?.ibanRepresentable)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemIcn)
        ]
        append(items, suffix: AccessibilityInternalTransferSummary.Summary.sourceSuffix, isFirstItem: true)
    }
    
    func addAmount() {
        guard let amount = operativeData.amount else { return }
        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "summary_item_amountDescription"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .attributedLabel(attributedString: getFormattedAmountWithCurrency(amount: amount,
                                                                                          font: .oneB300Bold,
                                                                                          decimalFont: .oneB300Bold)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: operativeData.description ?? "summary_label_transferOwnAccount",
                               isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        append(items, suffix: AccessibilityInternalTransferSummary.Summary.amountSuffix)
    }
    
    func addExchangeRate() {
        switch operativeData.transferType {
        case .doubleExchange(sellExchange: let sellRate, buyExchange: let buyRate):
            addTwoConversionsType(sellRate: sellRate, buyRate: buyRate)
        case .simpleExchange(sellExchange: let rate):
            addOneConversionType(rate: rate)
        default:
            break
        }
    }
    
    func addSendDate() {
        guard let originAccount = operativeData.originAccount,
              let destinationAccount = operativeData.destinationAccount else { return }
        let date = operativeData.issueDate.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        let dateString = operativeData.issueDate.isDayInToday() ? "confirmation_label_today" : date
        var items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "summary_label_sendDate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle)
        ]
        
        if modifier.freeTransferFor(originAccount: originAccount,
                                    destinationAccount: destinationAccount,
                                    date: operativeData.issueDate) {
            items.append(.init(type: .tag(tag: .init(itemKeyOrValue: dateString, tagKeyOrValue: localized("sendMoney_tag_free"))),
                               accessibilityId: AccessibilityOneComponents.oneListFlowItemTagSummary))
        } else {
            items.append(.init(type: .label(keyOrValue: dateString, isBold: true),
                               accessibilityId: AccessibilityOneComponents.oneListFlowItemText))
        }
        append(items, suffix: AccessibilityInternalTransferSummary.Summary.dateSuffix)
    }
    
    func addDestinationAccount() {
        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "confirmation_label_destinationAccount"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: operativeData.destinationAccount?.alias, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: operativeData.destinationAccount?.getIBANPapel, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1"),
            .init(type: .image(imageKeyOrUrl: bankLogoURLFrom(ibanRepresentable: operativeData.destinationAccount?.ibanRepresentable)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemIcn)
        ]
        append(items, suffix: AccessibilityInternalTransferSummary.Summary.destinationSuffix, isLastItem: true)
    }
    
    func build() -> [OneListFlowItemViewModel] {
        return summaryItems
    }
}

private extension InternalTransferHeaderSummaryBuilder {
    func append(_ items: [OneListFlowItemViewModel.Item], suffix: String, isFirstItem: Bool = false, isLastItem: Bool = false) {
        summaryItems.append(
            OneListFlowItemViewModel(
                isFirstItem: isFirstItem,
                isLastItem: isLastItem,
                items: items,
                accessibilitySuffix: suffix
            )
        )
    }
    
    func bankLogoURLFrom(ibanRepresentable: IBANRepresentable?) -> String? {
        guard let ibanRepresentable = ibanRepresentable else { return nil }
        return ibanRepresentable.bankLogoURLFrom(baseURLProvider: dependencies.external.resolve())
    }
    
    func getFormattedAmountWithCurrency(amount: AmountRepresentable, font: FontName, decimalFont: FontName) -> NSAttributedString {
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: font),
            decimalFont: .typography(fontName: decimalFont)
        )
        return decorator.getFormatedWithCurrencyName() ?? NSAttributedString()
    }
    
    func addOneConversionType(rate: InternalTransferExchangeType) {
        guard let amount = operativeData.receiveAmount,
              let rateValue = rate.rate else { return }
        let localCurrency = defaultCurrency.rawValue
        let foreignCurrency = rate.originCurrency.currencyType.rawValue != localCurrency ? rate.originCurrency : rate.destinationCurrency
        let conversionString = String(format: "1 %@ - %.4f %@", foreignCurrency.currencyType.rawValue, rateValue.doubleValue, localCurrency)
        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "confirmation_item_exchangeSellRate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: conversionString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: "summary_label_recipientWillReceive", isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .attributedLabel(attributedString: getFormattedAmountWithCurrency(amount: amount,
                                                                                          font: .oneH500Bold,
                                                                                          decimalFont: .oneB400Bold)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        append(items, suffix: AccessibilityInternalTransferSummary.Summary.exchangeSuffix)
    }
    
    func addTwoConversionsType(sellRate: InternalTransferExchangeType, buyRate: InternalTransferExchangeType) {
        guard let amount = operativeData.receiveAmount,
              let sellRateValue = sellRate.rate,
              let buyRateValue = buyRate.rate else { return }
        let localCurrency = defaultCurrency.rawValue
        let fromCurrency = sellRate.originCurrency.currencyType.rawValue
        let toCurrency = buyRate.originCurrency.currencyType.rawValue
        let sellConversionString = String(format: "1 %@ - %.4f %@", fromCurrency, sellRateValue.doubleValue, localCurrency)
        let buyConversionString = String(format: "1 %@ - %.4f %@", toCurrency, buyRateValue.doubleValue, localCurrency)

        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "summary_item_exchangeBuyRate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: sellConversionString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .title(keyOrValue: "confirmation_label_exchangeSellRate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: buyConversionString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: "summary_label_recipientWillReceive", isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .attributedLabel(attributedString: getFormattedAmountWithCurrency(amount: amount,
                                                                                          font: .oneH500Bold,
                                                                                          decimalFont: .oneB400Bold)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        append(items, suffix: AccessibilityInternalTransferSummary.Summary.exchangeSuffix)
    }
}
