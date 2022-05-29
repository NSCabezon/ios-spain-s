//
//  GetCardTransactionConfigUseCase.swift
//  Cards
//
//  Created by Gloria Cano López on 6/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol GetCardTransactionConfigUseCase {
    func fetchConfig(card: CardRepresentable,
                     transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailConfig, Error>
}

struct DefaultGetCardTransactionConfigUseCase {
    private let repository: AppConfigRepositoryProtocol
    private let appConfig: LocalAppConfig
    private let defaultMinimimAmount = Double(60)
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.appConfig = dependencies.resolve()
    }
}

extension DefaultGetCardTransactionConfigUseCase: GetCardTransactionConfigUseCase {
    func fetchConfig(card: CardRepresentable, transaction: CardTransactionRepresentable) -> AnyPublisher<CardTransactionDetailConfig, Error> {
        return Publishers.Zip4(
            repository.value(for: "enableCardTransactionsMap", defaultValue: false),
            repository.value(for: "enableSplitExpenseBizum", defaultValue: false),
            repository.value(for: "enableEasyPayCards", defaultValue: true),
            repository.value(for: "easyPayCardsModeClassic", defaultValue: true)
        )
            .map(defaultConfig)
            .map { config in configOptions(card: card, transaction: transaction, config: config)}
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func defaultConfig(enabledMap: Bool, enabledSplit: Bool, enabledEasyPay: Bool, enabledEasyPlayClassic: Bool) -> CardTransactionDetailConfig {
        var isSplitExpensesEnabled = enabledSplit
        let localEnableSplitExpenseBizum = appConfig.enableSplitExpenseBizum
        if localEnableSplitExpenseBizum {
            isSplitExpensesEnabled = localEnableSplitExpenseBizum
        }
        return CardTransactionDetailConfig(isEnabledMap: enabledMap, isSplitExpensesEnabled: isSplitExpensesEnabled, enableEasyPayCards: enabledEasyPay, isEasyPayClassicEnabled: enabledEasyPlayClassic)
        
    }
    
    func configOptions(card: CardRepresentable, transaction: CardTransactionRepresentable, config: CardTransactionDetailConfig) -> CardTransactionDetailConfig {
        let transactionValue = NSDecimalNumber(decimal: transaction.amountRepresentable?.value ?? 0).doubleValue
        let isEasyPayEnabled = config.enableEasyPayCards
        && transactionValue < 0.0
        && abs(transactionValue) >= defaultMinimimAmount
        && card.isCreditCard
        && !(card.isBeneficiary)
        let isEasyPayClassicEnabled = config.isEasyPayClassicEnabled && isEasyPayEnabled
        return CardTransactionDetailConfig(isEnabledMap: config.isEnabledMap, isSplitExpensesEnabled: config.isSplitExpensesEnabled, enableEasyPayCards: isEasyPayEnabled, isEasyPayClassicEnabled: isEasyPayClassicEnabled)
    }
}
