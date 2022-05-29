//
//  InternalTransferConfirmationBuilder.swift
//  TransferOperatives
//
//  Created by Juan Sánchez Marín on 3/3/22.
//

import CoreFoundationLib
import CoreDomain
import UIOneComponents

final class InternalTransferConfirmationBuilder {
    private let dependencies: InternalTransferConfirmationDependenciesResolver
    private let operativeData: InternalTransferOperativeData
    private var confirmItems: [OneListFlowItemViewModel] = []
    private lazy var defaultCurrency: CurrencyType = NumberFormattingHandler.shared.getDefaultCurrency()
    private lazy var modifier: InternalTransferConfirmationModifierProtocol = dependencies.external.resolve()

    init(dependencies: InternalTransferConfirmationDependenciesResolver, operativeData: InternalTransferOperativeData) {
        self.dependencies = dependencies
        self.operativeData = operativeData
    }

    func addSourceAccount() {
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_originAccount"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: operativeData.originAccount?.alias?.camelCasedString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: operativeData.destinationAccount?.getIBANPapel, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1"),
            .init(type: .image(imageKeyOrUrl: bankLogoURLFrom(ibanRepresentable: operativeData.originAccount?.ibanRepresentable)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemIcn)
        ]
        append(items, suffix: AccessibilityInternalTransferConfirmation.sourceSuffix, isFirstItem: true)
    }

    func addAmount() {
        guard let amount = operativeData.amount else { return }
        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "confirmation_item_amountDescription"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .attributedLabel(attributedString: getFormattedAmountWithCurrency(amount: amount,
                                                                                          font: .oneB300Bold,
                                                                                          decimalFont: .oneB300Bold)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: operativeData.description ?? "confirmation_label_transferOwnAccount", isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        append(items, suffix: AccessibilityInternalTransferConfirmation.amountSuffix)
    }

    func addExchangeRate() {
        switch operativeData.transferType {
        case .simpleExchange(sellExchange: let sellExchange):
            addSimpleExchangeRate(sellExchange)
        case .doubleExchange(sellExchange: let sellExchange, buyExchange: let buyExchange):
            addDoubleExchangeRate(sellExchange: sellExchange, buyExchange: buyExchange)
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
            .init(type: .title(keyOrValue: "confirmation_label_sendDate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle)
        ]

        if modifier.freeTransferFor(originAccount: originAccount,
                                    destinationAccount: destinationAccount,
                                    date: operativeData.issueDate) {
            items.append(.init(type: .tag(tag: .init(itemKeyOrValue: dateString, tagKeyOrValue: localized("sendMoney_tag_free"))),
                               accessibilityId: AccessibilityOneComponents.oneListFlowItemTagConfirmation))
        } else {
            items.append(.init(type: .label(keyOrValue: dateString, isBold: true),
                               accessibilityId: AccessibilityOneComponents.oneListFlowItemText))
        }
        append(items, suffix: AccessibilityInternalTransferConfirmation.dateSuffix)
    }

    func addDestinationAccount() {
        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_destinationAccount"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: operativeData.destinationAccount?.alias, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: operativeData.destinationAccount?.ibanRepresentable?.ibanPapel, isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1"),
            .init(type: .image(imageKeyOrUrl: bankLogoURLFrom(ibanRepresentable: operativeData.destinationAccount?.ibanRepresentable)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemIcn)
        ]
        append(items, suffix: AccessibilityInternalTransferConfirmation.destinationSuffix, isLastItem: true)
    }

    func build() -> [OneListFlowItemViewModel] {
        return confirmItems
    }
}

private extension InternalTransferConfirmationBuilder {
    func append(_ items: [OneListFlowItemViewModel.Item], suffix: String, isFirstItem: Bool = false, isLastItem: Bool = false) {
        confirmItems.append(
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

    func addSimpleExchangeRate(_ sellExchange: InternalTransferExchangeType) {
        guard let amount = operativeData.receiveAmount,
            let rateValue = sellExchange.rate else { return }
        let localCurrency = defaultCurrency.rawValue
        let foreignCurrency = sellExchange.originCurrency.currencyType.rawValue != localCurrency ? sellExchange.originCurrency : sellExchange.destinationCurrency
        let conversionString = String(format: "1 %@ - %.4f %@", foreignCurrency.currencyType.rawValue, rateValue.doubleValue, localCurrency)

        let items: [OneListFlowItemViewModel.Item] =
        [
            .init(type: .title(keyOrValue: "confirmation_label_exchangeSellRate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: conversionString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .title(keyOrValue: "confirmation_label_recipientWillReceive"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo),
            .init(type: .attributedLabel(attributedString: getFormattedAmountWithCurrency(amount: amount,
                                                                                          font: .oneH500Bold,
                                                                                          decimalFont: .oneB400Bold)))
        ]
        append(items, suffix: AccessibilityInternalTransferConfirmation.exchangeSuffix)
    }

    func addDoubleExchangeRate(sellExchange: InternalTransferExchangeType, buyExchange: InternalTransferExchangeType) {
        guard let amount = operativeData.receiveAmount,
            let sellRateValue = sellExchange.rate,
            let buyRateValue = buyExchange.rate
        else { return }
        let localCurrency = defaultCurrency.rawValue
        let fromCurrency = sellExchange.originCurrency.currencyType.rawValue
        let toCurrency = buyExchange.originCurrency.currencyType.rawValue
        let sellConversionString = String(format: "1 %@ - %.4f %@", fromCurrency, sellRateValue.doubleValue, localCurrency)
        let buyConversionString = String(format: "1 %@ - %.4f %@", toCurrency, buyRateValue.doubleValue, localCurrency)
        
        let items: [OneListFlowItemViewModel.Item] = [
            .init(type: .title(keyOrValue: "confirmation_item_exchangeBuyRate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: sellConversionString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .title(keyOrValue: "confirmation_label_exchangeSellRate"),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemTitle),
            .init(type: .label(keyOrValue: buyConversionString, isBold: true),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .label(keyOrValue: "confirmation_label_recipientWillReceive", isBold: false),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemText),
            .init(type: .attributedLabel(attributedString: getFormattedAmountWithCurrency(amount: amount,
                                                                                          font: .oneH500Bold,
                                                                                          decimalFont: .oneB400Bold)),
                  accessibilityId: AccessibilityOneComponents.oneListFlowItemInfo + "1")
        ]
        append(items, suffix: AccessibilityInternalTransferConfirmation.exchangeSuffix)
    }
}
