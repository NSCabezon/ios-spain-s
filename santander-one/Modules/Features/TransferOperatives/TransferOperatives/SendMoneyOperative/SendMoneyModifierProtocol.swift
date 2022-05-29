//
//  SendMoneyModifierProtocol.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 5/10/21.
//

import Operative
import CoreDomain
import CoreFoundationLib

public protocol SendMoneyModifierProtocol {
    var shouldShowSaveAsFavourite: Bool { get }
    var selectionDateOneFilterViewModel: SelectionDateOneFilterViewModel? { get }
    var freqOneInputSelectViewModel: OneInputSelectViewModel? { get }
    var bussinessOneInputSelectViewModel: OneInputSelectViewModel? { get }
    func shouldIncludeAccount(_ account: AccountRepresentable) -> Bool
    var isDescriptionRequired: Bool { get }
    var isEditConfirmationEnabled: Bool { get }
    func getSendMoneyPeriodicityType(_ index: Int) -> SendMoneyPeriodicityTypeViewModel
    func transferTypeFor(onePayType: OnePayTransferType, subtype: String) -> String
    func getTransferTypeStep(dependencies: DependenciesInjector & DependenciesResolver) -> OperativeStep?
    func serviceKeyForPeriodicity(_ periodicity: SendMoneyPeriodicityTypeViewModel) -> String
    func serviceKeyForWorkingDayIssue(_ workingDay: SendMoneyEmissionTypeViewModel) -> String
    func goToSendMoney()
    var doubleValidationRequired: Bool { get }
    var isEnabledSimulationTransfer: Bool { get }
    var amountToShow: SendMoneyAmountToShow { get }
    var isEnabledChangeCountry: Bool { get }
    func addSendType(operativeData: SendMoneyOperativeData) -> String?
    func isConfirmationEmailEnabled(_ sendMoneyDateType: SendMoneyDateTypeViewModel) -> Bool
    var giveUpOpinator: String { get }
    var favoriteGiveUpOpinator: String { get }
    var selectionIssueDateViewModel: SelectionIssueDateViewModel { get }
    func isCurrencyEditable(_ operativeData: SendMoneyOperativeData) -> Bool
    var expensesItems: [SendMoneyNoSepaExpensesProtocol] { get }
    func getScaSteps(dependencies: DependenciesInjector & DependenciesResolver) -> [OperativeStep]
    var maxProgressBarSteps: Int { get }
    func getAmountStep(operativeData: SendMoneyOperativeData, dependencies: DependenciesResolver) -> OperativeStep
}

public extension SendMoneyModifierProtocol {
    var shouldShowSaveAsFavourite: Bool {
        return true
    }
    var selectionDateOneFilterViewModel: SelectionDateOneFilterViewModel? {
        nil
    }
    var freqOneInputSelectViewModel: OneInputSelectViewModel? {
        nil
    }
    var bussinessOneInputSelectViewModel: OneInputSelectViewModel? {
        nil
    }
    
    func shouldIncludeAccount(_ account: AccountRepresentable) -> Bool {
        return true
    }
    
    var isDescriptionRequired: Bool {
        return false
    }
    
    var isEditConfirmationEnabled: Bool {
        return true
    }
    
    func getSendMoneyPeriodicityType(_ index: Int) -> SendMoneyPeriodicityTypeViewModel {
        return .month
    }
    
    func transferTypeFor(onePayType: OnePayTransferType, subtype: String) -> String {
        return "N"
    }
    
    func getTransferTypeStep(dependencies: DependenciesInjector & DependenciesResolver) -> OperativeStep? {
        return nil
    }
    
    func serviceKeyForPeriodicity(_ periodicity: SendMoneyPeriodicityTypeViewModel) -> String {
        switch periodicity {
        case .month: return "1"
        case .bimonthly: return "2"
        case .quarterly: return "3"
        case .semiannual: return "6"
        case .weekly: return "7"
        case .annual: return "12"
        }
    }
    
    func serviceKeyForWorkingDayIssue(_ workingDay: SendMoneyEmissionTypeViewModel) -> String {
        switch workingDay {
        case .next: return "P"
        case .previous: return "A"
        }
    }

    func goToSendMoney() {
        return
    }
    
    var doubleValidationRequired: Bool {
        return true
    }
    
    var isEnabledSimulationTransfer: Bool {
        return true
    }
    
    var amountToShow: SendMoneyAmountToShow {
        .currentBalance
    }

    var isEnabledChangeCountry: Bool {
        return false
    }
    
    func addSendType(operativeData: SendMoneyOperativeData) -> String? {
        return nil
    }
    
    func isConfirmationEmailEnabled(_ sendMoneyDateType: SendMoneyDateTypeViewModel) -> Bool {
        return false
    }
    
    var giveUpOpinator: String {
        return ""
    }
    
    var favoriteGiveUpOpinator: String {
        return ""
    }
    
    var selectionIssueDateViewModel: SelectionIssueDateViewModel {
        return SelectionIssueDateViewModel(minDate: Date().addDay(days: 2), maxDate: nil)
    }
    
    func isCurrencyEditable(_ operativeData: SendMoneyOperativeData) -> Bool {
        return false
    }
    
    var expensesItems: [SendMoneyNoSepaExpensesProtocol] { [] }
    
    func getScaSteps(dependencies: DependenciesInjector & DependenciesResolver) -> [OperativeStep] {
        return []
    }
    
    func getAmountStep(operativeData: SendMoneyOperativeData, dependencies: DependenciesResolver) -> OperativeStep {
        if operativeData.type != .noSepa {
            return SendMoneyAmountStep(dependenciesResolver: dependencies)
        } else {
            return SendMoneyAmountNoSepaStep(dependenciesResolver: dependencies)
        }
    }
}
