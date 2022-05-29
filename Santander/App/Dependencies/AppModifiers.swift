//
//  AppModifier.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 2/2/21.
//  Copyright © 2021 Ciber. All rights reserved.
//

import UI
import CoreFoundationLib
import Account
import Foundation
import CoreDomain
import GlobalPosition
import Cards
import Transfer
import PersonalArea
import WebViews
import TransferOperatives
import Menu
import Login
import Loans

final class AppModifiers {
    private let dependencieEngine: DependenciesResolver & DependenciesInjector
    private lazy var depositModifier: GlobalPosition.DepositModifier = {
        return DepositModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var fundModifier: GlobalPosition.FundModifier = {
        return FundModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var insuranceProtectionModifier: GlobalPosition.InsuranceProtectionModifier = {
        return InsuranceProtectionModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var cardHomeActionModifier: Cards.CardHomeActionModifier = {
        return CardHomeActionModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var transferActionModifier: SpainTransferHomeActionModifier = {
        return SpainTransferHomeActionModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var digitalProfileModifier: DigitalProfileItemsProviderProtocol = {
        return SpainDigitalProfileItemsProvider(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var cardTransactionsSearchModifier: CardTransactionsSearchModifierProtocol = {
        return SpainCardTransactionsSearchModifier(dependenciesResolver: dependencieEngine)
    }()
    private lazy var gpAccountOperativeModifier: GetGPAccountOperativeOptionProtocol = {
        return GetGPAccountOperativeModifier(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var cardTransactionDetailActionModifier: CardTransactionDetailActionFactoryModifierProtocol = {
        return CardTransactionDetailActionFactoryModifier()
    }()
    private lazy var accountTransactionDetailActionModifier: AccountTransactionDetailActionModifierProtocol = {
        return AccountTransactionDetailActionModifier()
    }()
    private lazy var getAllTransfersModifier: GetAllTransfersUseCaseModifierProtocol = {
        return GetAllTransfersModifier()
    }()
    private lazy var webViewProvider: WebViewProviderProtocol = {
        return WebViewProvider(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var cardBlockModifier: CardBlockModifierProtocol = {
        return SpainCardBlockModifier()
    }()
    private lazy var textFieldValidator: TextFieldValidatorProtocol = {
        return EmojiValidator()
    }()
    private lazy var accountsHomePresenterModifier: AccountsHomePresenterModifier = {
        return SpainAccountsHomePresenterModifier()
    }()
    private lazy var adobeTargetOfferUseCaseModifier: GetAdobeTargetOfferUseCaseProtocol = {
        return GetAdobeTargetOfferUseCase(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var carbonFootprintIdUseCaseModifier: GetCarbonFootprintIdUseCaseProtocol = {
        return GetCarbonFootprintIdUseCase(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var carbonFootprintDataUseCaseModifier: GetCarbonFootprintDataUseCaseProtocol = {
        return GetCarbonFootprintDataUseCase(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var getNewMortgageLawPDFUseCaseModifier: GetNewMortgageLawPDFUseCaseProtocol = {
        return SpainGetNewMortgageLawPDFUseCase(dependenciesResolver: self.dependencieEngine)
    }()
    private lazy var cardBoardingModifier: CardBoardingModifierProtocol = {
        return SpainCardBoardingModifier()
    }()
    init(dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.dependencieEngine = dependenciesEngine
        self.registerDependencies()
    }
}

private extension AppModifiers {
    func registerDependencies() {
        self.dependencieEngine.register(for: DepositModifier.self) { _ in
            return self.depositModifier
        }
        self.dependencieEngine.register(for: FundModifier.self) { _ in
            return self.fundModifier
        }
        self.dependencieEngine.register(for: InsuranceProtectionModifier.self) { _ in
            return self.insuranceProtectionModifier
        }
        self.dependencieEngine.register(for: CardHomeActionModifier.self) { _ in
            return self.cardHomeActionModifier
        }
        self.dependencieEngine.register(for: ShareIbanFormatterProtocol.self) { _ in
            return ShareIbanFormatter()
        }
        self.dependencieEngine.register(for: DigitalProfileItemsProviderProtocol.self) { _ in
            return self.digitalProfileModifier
        }
        self.dependencieEngine.register(for: GetGPAccountOperativeOptionProtocol.self) { _ in
            return self.gpAccountOperativeModifier
        }
        self.dependencieEngine.register(for: CardTransactionDetailActionFactoryModifierProtocol.self) { _ in
            return self.cardTransactionDetailActionModifier
        }
        self.dependencieEngine.register(for: AccountTransactionDetailActionModifierProtocol.self) { _ in
            return self.accountTransactionDetailActionModifier
        }
        self.dependencieEngine.register(for: GetAllTransfersUseCaseModifierProtocol.self) { _ in
            return self.getAllTransfersModifier
        }
        self.dependencieEngine.register(for: TransferHomeModifierActionsDelegate.self) { _ in
            return self.transferActionModifier
        }
        self.dependencieEngine.register(for: TransferHomeModifierActionsDataSource.self) { _ in
            return self.transferActionModifier
        }
        self.dependencieEngine.register(for: ContactsSortedHandlerProtocol.self) { _ in
            return ContactsSortedHandler()
        }
        self.dependencieEngine.register(for: WebViewProviderProtocol.self) { _ in
            return self.webViewProvider
        }
        self.dependencieEngine.register(for: CardBlockModifierProtocol.self) { _ in
            return self.cardBlockModifier
        }
        self.dependencieEngine.register(for: CardBlockUseCaseProtocol.self) { resolver in
            return SpainCardBlockUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: ScheduledTransfersSelectedTransferModifierProtocol.self) { _ in
            return SpainScheduledTransfersSelectedTransferModifier()
        }
        self.dependencieEngine.register(for: TextFieldValidatorProtocol.self) { _ in
            return self.textFieldValidator
        }
        self.dependencieEngine.register(for: AccountDetailModifierProtocol.self) { _ in
            return SpainAccountDetailModifier()
        }
        self.dependencieEngine.register(for: GetCardOnOffPredefinedSCAUseCaseProtocol.self) { _ in
            return SpainGetCardOnOffPredefinedSCAUseCase()
        }
        self.dependencieEngine.register(for: CardTransactionsSearchModifierProtocol.self) { _ in
            return self.cardTransactionsSearchModifier
        }
        self.dependencieEngine.register(for: ConfirmGenericSendMoneyUseCaseProtocol.self) { resolver in
            return ConfirmGenericSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: ValidateCardOnOffUseCaseProtocol.self) { resolver in
            return SpainValidateCardOnOffUseCase(resolver: resolver)
        }
        self.dependencieEngine.register(for: GetAccountHomeActionUseCaseProtocol.self) { resolver in
            return GetSpainAccountHomeActionUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: AccountHomeActionModifierProtocol.self) { resolver in
            return SpainAccountHomeActionModifier(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: GetAccountOtherOperativesActionUseCaseProtocol.self) { resolver in
            return GetSpainAccountOtherOperativesActionUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: AccountOtherOperativesActionModifierProtocol.self) { resolver in
            return SpainAccountOtherOperativesActionModifier(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: SendMoneyModifierProtocol.self) { resolver in
            return SpainSendMoneyModifier(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: SendMoneyTransferTypeUseCaseProtocol.self) { resolver in
            return SendMoneyTransferTypeUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: SendMoneyTransferTypeUseCaseInputAdapterProtocol.self) { _ in
            return SendMoneyTransferTypeUseCaseInputAdapter()
        }
        self.dependencieEngine.register(for: SendMoneyUseCaseProviderProtocol.self) { resolver in
            return SendMoneyUseCaseProvider(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: ConfirmCardOnOffUseCaseProtocol.self) { resolver in
            return SpainConfirmOnOffCardUseCase(resolver: resolver)
        }
        self.dependencieEngine.register(for: SetSetNeedUpdatePasswordDelegateProtocol.self) { _ in
            SpainNeedUpdatePassword(dependenciesEngine: self.dependencieEngine)
        }
        self.dependencieEngine.register(for: GetAdobeTargetOfferUseCaseProtocol.self) { _ in
            return self.adobeTargetOfferUseCaseModifier
        }
        self.dependencieEngine.register(for: GetCarbonFootprintIdUseCaseProtocol.self) { _ in
            return self.carbonFootprintIdUseCaseModifier
        }
        self.dependencieEngine.register(for: GetCarbonFootprintDataUseCaseProtocol.self) { _ in
            return self.carbonFootprintDataUseCaseModifier
        }
        self.dependencieEngine.register(for: GetNewMortgageLawPDFUseCaseProtocol.self) { resolver in
            return self.getNewMortgageLawPDFUseCaseModifier
        }
        self.dependencieEngine.register(for: CardBoardingModifierProtocol.self) { resolver in
            return self.cardBoardingModifier
        }
        SendMoneyDependencies(dependenciesEngine: self.dependencieEngine).registerDependencies()
        self.dependencieEngine.register(for: ValidateLoanPartialAmortizationUseCaseProtocol.self) { resolver in
            return ValidateLoanPartialAmortizationUseCase(dependenciesResolver: resolver)
        }
        
        // MARK: - Testing only has something in countries
        self.dependencieEngine.register(for: ConfirmationAmortizationStepPresenterModifierProtocol.self) { resolver in
            return ConfirmationAmortizationStepPresenterSpain(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: ConfirmationAmortizationStepPresenterSpainProtocol.self) { resolver in
            return ConfirmationAmortizationStepPresenterSpain(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: ConfirmationAmortizationStepViewModifierProtocol.self) { resolver in
            resolver.resolve(for: ConfirmationAmortizationStepViewControllerSpain.self)
        }
        self.dependencieEngine.register(for: ConfirmationAmortizationStepViewControllerSpain.self) { resolver in
            let presenterSpain = resolver.resolve(for: ConfirmationAmortizationStepPresenterSpainProtocol.self)
            let viewController = ConfirmationAmortizationStepViewControllerSpain(presenter: presenterSpain)
            presenterSpain.view = viewController
            presenterSpain.viewSpain = viewController
            return viewController
        }
        self.dependencieEngine.register(for: ConfirmScheduledSendMoneyUseCaseProtocol.self) { resolver in
            return ConfirmScheduledSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: CheckStatusSendMoneyTransferUseCaseProtocol.self) { resolver in
            return CheckStatusSendMoneyTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencieEngine.register(for: LoadFundableTypeUseCaseProtocol.self) { resolver in
            return LoadFundableTypeUseCase(dependenciesResolver: resolver)
        }
    }
}
