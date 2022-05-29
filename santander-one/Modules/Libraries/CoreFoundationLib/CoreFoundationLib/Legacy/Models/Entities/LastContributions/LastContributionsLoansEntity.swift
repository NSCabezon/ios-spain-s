//
//  LastContributionsLoansEntity.swift
//  Models
//
//  Created by Ignacio González Miró on 03/09/2020.
//

import Foundation
import SANLegacyLibrary

public final class LastContributionsLoansEntity: DTOInstantiable {
    public var dto: LoanDTO
    public var loanDetailDTO: LoanDetailDTO?
    
    public init(_ dto: LoanDTO) {
        self.dto = dto
    }
    
    public init(_ loanDTO: LoanDTO, detailDTO: LoanDetailDTO?) {
        self.dto = loanDTO
        self.loanDetailDTO = detailDTO
    }
    
    public var title: String {
        return self.dto.alias?.camelCasedString ?? ""
    }
    
    public var iban: String {
        let bankCode = self.dto.contract?.contractNumber ?? ""
        let lastFourDigits = bankCode.substring(bankCode.count - 4) ?? "*"
        return "*" + lastFourDigits
    }
    
    public var amount: AmountEntity? {
        return dto.currentBalance.map(AmountEntity.init)
    }
    
    public var startDate: String {
        let openingDateString = self.dateToStringFormat(self.loanDetailDTO?.openingDate)
        return openingDateString
    }
    
    public var endsDate: String {
        let currentDueDateString = self.dateToStringFormat(self.loanDetailDTO?.currentDueDate)
        return currentDueDateString
    }
    
    public var progress: CGFloat {
        guard
            let initialAmount = self.loanDetailDTO?.initialAmount?.value,
            let currentBalance = self.dto.currentBalance?.value,
            abs(initialAmount) > 0
            else {
                return 0
        }
        let paid = abs(currentBalance)
        let total = abs(initialAmount)
        let value = (total - paid) * 100 / total
        let progressPercent = CGFloat(truncating: value as NSNumber)
        return progressPercent > 100 ? 100 : progressPercent
    }
    
    public func amountDecimalToAmountEntity(_ value: Decimal) -> AmountEntity {
        return AmountEntity(value: value)
    }
}

private extension LastContributionsLoansEntity {
    func dateToStringFormat(_ date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        guard let date = date else { return "" }
        let dateString = formatter.string(from: date)
        return dateString
    }
}
