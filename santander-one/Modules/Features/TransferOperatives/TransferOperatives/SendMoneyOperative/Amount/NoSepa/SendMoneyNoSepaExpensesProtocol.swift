//
//  SendMoneyNoSepaExpensesProtocol.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 1/3/22.
//

import CoreDomain

public protocol SendMoneyNoSepaExpensesProtocol {
    var titleKey: String { get }
    var subtitleKey: String { get }
    var serviceValue: String { get }
    var showsWarning: Bool { get }
    var confirmationKey: String { get }
    
    func getSwiftExpensesWith(operativeData: SendMoneyOperativeData) -> AmountRepresentable?
    func getTransferExpensesWith(operativeData: SendMoneyOperativeData) -> AmountRepresentable?
    func equalsTo(other: SendMoneyNoSepaExpensesProtocol) -> Bool
}

public extension SendMoneyNoSepaExpensesProtocol {
    func equalsTo(other: SendMoneyNoSepaExpensesProtocol) -> Bool {
        return self.subtitleKey == other.subtitleKey &&
        self.titleKey == other.titleKey &&
        self.serviceValue == other.serviceValue
    }
}
