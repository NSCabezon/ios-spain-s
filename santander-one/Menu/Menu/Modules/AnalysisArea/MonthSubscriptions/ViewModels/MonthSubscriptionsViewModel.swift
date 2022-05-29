//
//  MonthSubscriptionsViewModel.swift
//  Menu
//
//  Created by Laura González on 11/06/2020.
//

import CoreFoundationLib

final class MonthSubscriptionsViewModel {
    let ibanEntity: IBANEntity?
    let subscription: TimeLineSubscriptionEntity
    private let timeManager: TimeManager
    
    init(_ ibanEntity: IBANEntity?,
         subscription: TimeLineSubscriptionEntity,
         timeManager: TimeManager) {
        self.ibanEntity = ibanEntity
        self.subscription = subscription
        self.timeManager = timeManager
    }
    
    var executedDate: Date? {
        return subscription.fullDate
    }
    
    var executedDateString: String? {
        return timeManager.toStringFromCurrentLocale(date: subscription.fullDate, outputFormat: .dd_MMM_yyyy)?.uppercased()
    }
    
    var iban: String {
        return ibanEntity?.ibanShort(asterisksCount: 1) ?? "****"
    }
    
    var concept: String? {
        return subscription.name
    }
    
    var amount: NSAttributedString? {
        let amountEntity = AmountEntity(value: subscription.amount)
        let font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        let moneyDecorator = MoneyDecorator(amountEntity, font: font, decimalFontSize: 16.0)
        return moneyDecorator.getFormatedCurrency()
    }
}

extension MonthSubscriptionsViewModel: Equatable {
    static func == (lhs: MonthSubscriptionsViewModel, rhs: MonthSubscriptionsViewModel) -> Bool {
        let lhsValue = lhs.subscription.amount
        let rhsValue = rhs.subscription.amount
        guard let lhsDate = lhs.executedDate,
            let rhsDate = rhs.executedDate
            else { return lhsValue == rhsValue }
        return lhsDate == rhsDate && lhsValue == rhsValue
    }
}

extension MonthSubscriptionsViewModel: Comparable {
    static func < (lhs: MonthSubscriptionsViewModel, rhs: MonthSubscriptionsViewModel) -> Bool {
        let lhsValue = lhs.subscription.amount
        let rhsValue = rhs.subscription.amount
        guard let lhsDate = lhs.executedDate,
            let rhsDate = rhs.executedDate,
            lhsDate != rhsDate
            else { return lhsValue  < rhsValue }
        return lhsDate < rhsDate
    }
}
