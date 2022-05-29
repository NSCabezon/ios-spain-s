import CoreFoundationLib
import Foundation
import Operative
import SANLegacyLibrary
import UIOneComponents

final class SummaryAmortizationViewModel {
    private var operativeData: LoanPartialAmortizationOperativeData
    let timeManager: TimeManager

    init(operativeData: LoanPartialAmortizationOperativeData, timeManager: TimeManager) {
        self.operativeData = operativeData
        self.timeManager = timeManager
    }

    var loanAmount: NSAttributedString {
        guard let amount = operativeData.amortizationAmount
        else { return NSAttributedString(string: "") }
        let moneyDecorator = AmountRepresentableDecorator(amount, font: .santander(family: .text, type: .bold, size: 32))
        return moneyDecorator.getFormatedAbsWith1M() ?? NSAttributedString(string: "")
    }

    var loanAlias: String {
        guard let alias = operativeData.selectedLoan.alias
        else { return "" }
        return alias
    }

    var loanContractNumber: String {
        let loan = operativeData.selectedLoan
        if let bankCode = loan.contractRepresentable?.bankCode,
           let branchCode = loan.contractRepresentable?.branchCode,
           let contractNumber = loan.contractRepresentable?.contractNumber,
           let product = loan.contractRepresentable?.product {
            return "\(bankCode) \(branchCode) \(product) \(contractNumber)"
        } else {
            return ""
        }
    }

    var loanHolderName: String {
        return (operativeData.selectedLoanDetail?.holder ?? "").capitalized
    }

    var iban: String {
        if let accountIban = operativeData.account?.getIBANPapel {
            return accountIban
        } else {
            return ""
        }
    }

    var pendingAmount: String {
        guard let amount =  operativeData.partialAmortization?.pendingAmount else { return "" }
        let decorator = AmountRepresentableDecorator(amount, font: .santander(family: .text, type: .bold, size: 14))
        return decorator.getStringValue()
    }

    var loanExpiringDate: String {
        guard let date = operativeData.partialAmortization?.getExpiration
        else { return "" }
        return timeManager.toString(input: date,
                                    inputFormat: .yyyyMMdd,
                                    outputFormat: .d_MMM_yyyy) ?? ""
    }

    var initialLimit: String {
        guard let limit = operativeData.partialAmortization?.getStartLimit else { return "" }
        let decorator = AmountRepresentableDecorator(limit, font: .santander(family: .text, type: .bold, size: 14))
        return decorator.getStringValue()
    }

    var amortizationType: String {
        guard let type = operativeData.amortizationType
        else { return "" }
        switch type {
        case .decreaseFee:
            return localized("anticipatedAmortization_label_decreaseFee")
        case .decreaseTime:
            return localized("anticipatedAmortization_label_advanceExpiration")
        }
    }

    var loanValueDate: String {
        return timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? ""
    }

    var amortizationAmount: String {
        guard let amortization = operativeData.amortizationAmount else { return "" }
        let decorator = AmountRepresentableDecorator(amortization, font: .santander(family: .text, type: .bold, size: 14))
        return decorator.getStringValue()
    }

    var finantialLoss: String? {
        guard let amountDto = operativeData.partialLoanAmortizationValidation?.finantialLossAmountRepresentable as? AmountDTO
        else { return nil }
        let decorator = AmountRepresentableDecorator(amountDto, font: .santander(family: .text, type: .bold, size: 14))
        return decorator.getStringValue()
    }

    var compensation: String? {
        guard let amountDto = operativeData.partialLoanAmortizationValidation?.compensationAmountRepresentable as? AmountDTO
        else { return nil }
        let decorator = AmountRepresentableDecorator(amountDto, font: .santander(family: .text, type: .bold, size: 14))
        return decorator.getStringValue()
    }

    var insuranceFee: String? {
        guard let amountDto = operativeData.partialLoanAmortizationValidation?.insuranceFeeAmountRepresentable as? AmountDTO
        else { return nil }
        let decorator = AmountRepresentableDecorator(amountDto, font: .santander(family: .text, type: .bold, size: 14))
        return decorator.getStringValue()
    }
}
