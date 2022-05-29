//
//  MonthDebtsViewModel.swift
//  Menu
//
//  Created by Laura González on 08/06/2020.
//

import CoreFoundationLib

final class MonthDebtsViewModel {
    let ibanEntity: IBANEntity?
    let debt: TimeLineDebtEntity
    private let timeManager: TimeManager
    
    init(_ ibanEntity: IBANEntity?,
         debt: TimeLineDebtEntity,
         timeManager: TimeManager) {
        self.ibanEntity = ibanEntity
        self.debt = debt
        self.timeManager = timeManager
    }
    
    var executedDate: Date? {
        return debt.fullDate
    }
    
    var executedDateString: String? {
        return timeManager.toStringFromCurrentLocale(date: debt.fullDate, outputFormat: .dd_MMM_yyyy)?.uppercased()
    }
    
    var iban: String {
        return ibanEntity?.ibanShort(asterisksCount: 1) ?? "****"
    }
    
    var concept: String? {
        return debt.description
    }
    
    var amount: NSAttributedString? {
        let amountEntity = AmountEntity(value: debt.amount)
        let font = UIFont.santander(family: .text, type: .regular, size: 20.0)
        let moneyDecorator = MoneyDecorator(amountEntity, font: font, decimalFontSize: 16.0)
        return moneyDecorator.getFormatedCurrency()
    }
}

extension MonthDebtsViewModel: Equatable {
    static func == (lhs: MonthDebtsViewModel, rhs: MonthDebtsViewModel) -> Bool {
        let lhsValue = lhs.debt.amount
        let rhsValue = rhs.debt.amount
        guard let lhsDate = lhs.executedDate,
            let rhsDate = rhs.executedDate
            else { return lhsValue == rhsValue }
        return lhsDate == rhsDate && lhsValue == rhsValue
    }
}

extension MonthDebtsViewModel: Comparable {
    static func < (lhs: MonthDebtsViewModel, rhs: MonthDebtsViewModel) -> Bool {
        let lhsValue = lhs.debt.amount
        let rhsValue = rhs.debt.amount
        guard let lhsDate = lhs.executedDate,
            let rhsDate = rhs.executedDate,
            lhsDate != rhsDate
            else { return lhsValue  < rhsValue }
        return lhsDate < rhsDate
    }
}
