//
//  ScheduledTransferDetailConfigurationBuilder.swift
//  Transfer
//
//  Created by alvola on 13/07/2021.
//

import Foundation
import CoreFoundationLib

final class ScheduledTransferDetailConfigurationBuilder {
    
    struct ScheduledTransferDetailConfiguration {
        let scheduledTransferDetail: ScheduledTransferDetailEntity?
        let transfer: ScheduledTransferRepresentable?
        let account: AccountEntity
        let originAccount: AccountEntity?
        let baseURL: String
        let sepaRepository: SepaInfoRepositoryProtocol
        let withBalance: Bool
    }
    
    func configureWith(configuration: ScheduledTransferDetailConfiguration) -> TransferDetailConfiguration {
        var config = TransferDetailConfiguration(transferType: TransferDetailType.scheduled(account: configuration.account,
                                                                                            transfer: configuration.transfer,
                                                                                            transferDetail: configuration.scheduledTransferDetail,
                                                                                            originAccount: configuration.originAccount))
        config.config.append(createAmountCell(configuration.scheduledTransferDetail?.transferAmount))
        config.config.append(createConceptCell(configuration.transfer?.concept,
                                               configuration.transfer?.isPeriodic))
        config.config.append(createBalanceCell(configuration.account.currentBalanceAmount,
                                               alias: configuration.account.alias,
                                               withBalance: configuration.withBalance))
        config.config.append(createTransferTypeCell(configuration.transfer?.isPeriodic))
        config.config.append(createDestinationCell(configuration.scheduledTransferDetail?.beneficiaryName,
                                                   configuration.scheduledTransferDetail?.beneficiary?.ibanPapel ?? "",
                                                   account: configuration.account,
                                                   baseURL: configuration.baseURL))
        config.maxViewsNotExpanded = config.config.count
        config.config.append(createDestinationCountryCell(configuration.account.getIBANPapel(),
                                                          sepaInfo: SepaInfoListEntity(dto: configuration.sepaRepository.getSepaList()),
                                                          transferCurrency: configuration.transfer?.currency))
        if configuration.transfer?.isPeriodic ?? false {
            config.config.append(createFromToDateCell(configuration.scheduledTransferDetail?.dateValidFrom,
                                                      toDate: configuration.scheduledTransferDetail?.endDate,
                                                      periodicity: configuration.transfer?.periodicityString))
            config.config.append(createNextEmissionDate(configuration.scheduledTransferDetail?.nextExecutionDate))
        } else {
            config.config.append(createPeriodicityCell())
            config.config.append(createEmissionDateCell(configuration.scheduledTransferDetail?.dateValidFrom))
        }
        return config
    }
}

private extension ScheduledTransferDetailConfigurationBuilder {
    
    func createAmountCell(_ transferAmount: AmountEntity?) -> TransferDetailConfigurationProtocol? {
        return TransferDetailConfiguration.Amount(amount: transferAmount,
                                                  concept: nil)
    }
    
    func createConceptCell(_ concept: String?, _ isPeriodic: Bool?) -> TransferDetailConfigurationProtocol? {
        let transferType = (isPeriodic ?? false) ? "onePay_label_genericPeriodic" : "onePay_label_genericProgrammed"
        let conceptString: String
        if let concept = concept, !concept.isEmpty {
            conceptString = concept
        } else {
            conceptString = localized(transferType)
        }
        return TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_concept",
            content: conceptString.camelCasedString,
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.concept
        )
    }
    
    func createBalanceCell(_ amount: AmountEntity?, alias: String?, withBalance: Bool) -> TransferDetailConfigurationProtocol? {
        var balance: String?
        if let balanceUI = amount?.getFormattedAmountUI(), withBalance {
            balance = " (\(balanceUI))"
        }
        return TransferDetailConfiguration.OriginAccount(
            title: "deliveryDetails_label_originAccount",
            beneficiary: localized(alias ?? "generic_confirm_associatedAccount"),
            balance: balance,
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.scheduledTransferLabelOriginAccount
        )
    }
    
    func createTransferTypeCell(_ isPeriodic: Bool?) -> TransferDetailConfigurationProtocol? {
        let transferType = (isPeriodic ?? false) ? "deliveryDetails_label_periodic" : "detailsOnePay_label_standardProgrammed"
        return TransferDetailConfiguration.DefaultViewConfig(
            title: "transfer_label_sendType",
            content: transferType,
            accessibilityIdentifier: transferType
        )
    }
    
    func createDestinationCell(_ beneficiaryName: String?, _ iban: String, account: AccountEntity, baseURL: String) -> TransferDetailConfigurationProtocol? {
        guard !iban.isEmpty else { return nil }
        let ibanEntity = IBANEntity.create(fromText: iban)
        let iconPath = bankIconPath(with: ibanEntity, account: account, baseURL: baseURL)
        return TransferDetailConfiguration.DestinationAccount(beneficiary: beneficiaryName,
                                                              iban: ibanEntity.ibanPapel,
                                                              bankIconUrl: iconPath)
    }
    
    func createDestinationCountryCell(_ iban: String, sepaInfo: SepaInfoListEntity, transferCurrency: String?) -> TransferDetailConfigurationProtocol? {
        let ibanEntity = IBANEntity.create(fromText: iban)
        guard let country = sepaInfo.countryFor(ibanEntity.countryCode),
              let transferCurrency = transferCurrency,
              let currency = sepaInfo.currencyFor(transferCurrency)
        else { return nil }
        return TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_destinationCountry",
            content: "\(country) - \(currency)",
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.scheduledTransferLabelDestinationCountry
        )
    }
    
    func createFromToDateCell(_ fromDate: Date?, toDate: Date?, periodicity: String?) -> TransferDetailConfigurationProtocol? {
        let fromDate = dateToString(date: fromDate,
                                    outputFormat: .dd_MMM_yyyy)
        let endDate: String
        if toDate?.year ?? 0 >= 2100 {
            endDate = localized("detailsOnePay_label_indefinite")
        } else {
            endDate = dateToString(date: toDate, outputFormat: .dd_MMM_yyyy) ?? ""
        }
        return TransferDetailConfiguration.DefaultWithSubtitleViewConfig(
            title: "detailsOnePay_label_periodicy",
            content: periodicity,
            subtitle: "\((fromDate ?? "")) - \(endDate)",
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.scheduledTransferLabelPeriodicity
        )
    }
    
    func createNextEmissionDate(_ nextExecutionDate: Date?) -> TransferDetailConfigurationProtocol? {
        guard let nextEmissionDate = dateToString(date: nextExecutionDate,
                                                  outputFormat: .dd_MMM_yyyy)
        else { return nil }
        return TransferDetailConfiguration.DefaultViewConfig(
            title: "detailsOnePay_label_nextIssuanceDate",
            content: nextEmissionDate,
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.scheduledTransferLabelNextEmissionDate
        )
    }
    
    func createPeriodicityCell() -> TransferDetailConfigurationProtocol? {
        return TransferDetailConfiguration.DefaultViewConfig(
            title: "detailsOnePay_label_periodicy",
            content: "summary_label_timely",
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.scheduledTransferLabelPeriodicity
        )
    }
    
    func createEmissionDateCell(_ date: Date?) -> TransferDetailConfigurationProtocol? {
        return TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_issuanceDate",
            content: dateToString(date: date,
                                  outputFormat: .dd_MMM_yyyy),
            accessibilityIdentifier: ScheduledTransferDetailAccessibilityIdentifier.scheduledTransferLabelEmissionDate
        )
    }
    
    func bankIconPath(with iban: IBANEntity, account: AccountEntity, baseURL: String) -> String? {
        guard let entityCode = iban.ibanElec.substring(4, 8),
              let countryCode = account.contryCode
        else { return nil }
        return String(format: "%@%@/%@_%@%@", baseURL,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}
