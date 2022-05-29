//
//  DeleteScheduledTransferShareConfiguration.swift
//  Transfer
//
//  Created by Alvaro Royo on 27/7/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

enum DeleteScheduledTransferShareConfiguration {
    case text(title: String, subtitle: String, secondary: String?)
    case account(title: String, accountNumber: String, bankImage: String?)
    case amount(amount: AmountEntity?)
    case header(name: String)
    
    var view: UIView {
        switch self {
        case .text(let title, let subtitle, let secondary):
            return DeleteScheduledTransferShareViewDefault(title: title,
                                                           subtitle: subtitle,
                                                           secondary: secondary)
        case .header(let name):
            return DeleteScheduledTransferShareViewHeader(name)
        case .amount(let amount):
            return DeleteScheduledTransferShareViewAmount(amount)
        case .account(let title, let accountNumber, let bankImage):
            return DeleteScheduledTransferShareViewAccount(title: title,
                                                           bankImage: bankImage,
                                                           accountNumber: accountNumber)
        }
    }
    
    static func defaultConfiguration(name: String, operativeData: DeleteScheduledTransferOperativeData, dependencyResolver: DependenciesResolver) -> [DeleteScheduledTransferShareConfiguration] {
        let isPeriodic = operativeData.order?.isPeriodic ?? false
        let amount = operativeData.order?.transferAmount
        let defaultSubject = isPeriodic ? "onePay_label_genericPeriodic" : "onePay_label_genericProgrammed"
        let subject = (operativeData.order?.concept ?? localized(defaultSubject)).camelCasedString
        let transferType: String = localized(isPeriodic ? "summary_label_periodic" : "summary_label_programmed")
        let startDateTitle: String = localized(isPeriodic ? "summary_item_sentDate" : "summary_item_issuanceDate")
        let startDate = dateToStringFromCurrentLocale(date: operativeData.detail?.dateValidFrom, outputFormat: .dd_MM_yyyy) ?? ""
        let baseUrl: String = dependencyResolver.resolve(for: BaseURLProvider.self).baseURL ?? ""
        let destinationAccountIban = operativeData.detail?.beneficiary?.ibanShort(asterisksCount: 1) ?? ""
        let destinationAccountIcon = bankIconPath(with: operativeData.detail?.beneficiary,
                                                  baseUrl: baseUrl)
        let originAccountIban = operativeData.detail?.iban?.ibanShort(asterisksCount: 1) ?? ""
        let originAccountIcon = bankIconPath(with: operativeData.detail?.iban,
                                             baseUrl: baseUrl)
        let periodicity = operativeData.order?.periodicityString ?? ""
        let periodicityFinal: String?
        if operativeData.order?.isPeriodic ?? false {
            periodicityFinal = "\(startDate) - \(localized("summary_label_indefinite"))"
        } else {
            periodicityFinal = nil
        }
        return [
            .header(name: name),
            .amount(amount: amount),
            .text(title: localized("summary_item_concept"), subtitle: subject, secondary: nil),
            .text(title: localized("summary_item_sendType"), subtitle: transferType, secondary: nil),
            .text(title: startDateTitle, subtitle: startDate, secondary: nil),
            .account(title: localized("summary_item_destinationAccounts"), accountNumber: destinationAccountIban, bankImage: destinationAccountIcon),
            .account(title: localized("summary_item_originAccount"), accountNumber: originAccountIban, bankImage: originAccountIcon),
            .text(title: localized("summary_item_periodicity"), subtitle: localized(periodicity), secondary: periodicityFinal)
        ]
    }
}

private extension DeleteScheduledTransferShareConfiguration {
    static func bankIconPath(with iban: IBANEntity?, baseUrl: String) -> String {
        guard let entityCode = iban?.ibanElec.substring(4, 8),
              let countryCode = iban?.countryCode.lowercased()
        else { return "" }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      countryCode,
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    static func nameForPeriodicityType(_ type: StandingOrderPeriodicityType?) -> String {
        guard let type = type else { return "" }
        switch type {
        case .fixed: return localized("summary_label_programmed")
        case .monthly: return localized("generic_label_monthly")
        case .halfYear: return localized("generic_label_quarterly")
        case .weekly: return localized("generic_label_weekly")
        case .annualy: return localized("generic_label_annual")
        case .bimonth: return localized("generic_label_bimonthly")
        default: return ""
        }
    }
}

private extension SepaInfoListEntity {
    func currencyFor(currencySymbol: String) -> String? {
        return self.allCurrencies.first(where: { $0.symbol == currencySymbol })?.name
    }
}
