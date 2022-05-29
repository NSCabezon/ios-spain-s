//
//  SpainNoSepaExpenses.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 1/3/22.
//

import TransferOperatives
import CoreDomain
import SANLibraryV3

enum SpainNoSepaTransferExpenses: SendMoneyNoSepaExpensesProtocol {
    case shared
    case beneficiary
    case payer
    
    var titleKey: String {
        switch self {
        case .shared: return "sendMoney_label_shared"
        case .beneficiary: return "sendMoney_label_byYourSide"
        case .payer: return "sendMoney_label_byThePayer"
        }
    }
    
    var subtitleKey: String {
        switch self {
        case .shared: return "sendMoney_textPopup_shared"
        case .beneficiary: return "sendMoney_textPopup_byYourSide"
        case .payer: return "sendMoney_textPopup_byThePayer"
        }
    }
    
    var confirmationKey: String {
        switch self {
        case .shared: return "confirmation_label_shared"
        case .beneficiary: return "confirmation_label_byYourSide"
        case .payer: return "sendMoney_label_byThePayer"
        }
    }
    
    var serviceValue: String {
        switch self {
        case .shared: return ExpensesType.shared.rawValue
        case .beneficiary: return ExpensesType.benf.rawValue
        case .payer: return ExpensesType.our.rawValue
        }
    }
    
    var showsWarning: Bool {
        switch self {
        case .payer: return false
        default: return true
        }
    }
    
    func getSwiftExpensesWith(operativeData: SendMoneyOperativeData) -> AmountRepresentable? {
        guard let expenses = operativeData.expenses as? SpainNoSepaTransferExpenses else { return nil }
        switch expenses {
        case .shared, .payer:
            return operativeData.noSepaTransferValidation?.swiftExpensesRepresentable?.impConcepLiqCompRepresentable
        case .beneficiary:
            return operativeData.noSepaTransferValidation?.swiftExpensesRepresentable?.impConcepLiqBenefActRepresentable
        }
    }
    
    func getTransferExpensesWith(operativeData: SendMoneyOperativeData) -> AmountRepresentable? {
        guard let expenses = operativeData.expenses as? SpainNoSepaTransferExpenses else { return nil }
        switch expenses {
        case .shared, .payer:
            return operativeData.noSepaTransferValidation?.expensesRepresentable?.impConcepLiqCompRepresentable
        case .beneficiary:
            return operativeData.noSepaTransferValidation?.expensesRepresentable?.impConcepLiqBenefActRepresentable
        }
    }
}
