//
//  StandingOrdersPeriodicViewModel. swift.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 16/7/21.
//

import Foundation
import CoreFoundationLib

public final class StandingOrdersPeriodicViewModel: PeriodicTransferViewModelProtocol {
    public let entity: StandingOrderEntity
    
    public var account: AccountEntity {
        entity.account
    }
    
    public var concept: String {
        (entity.subject ?? localized("onePay_label_genericPeriodic")).camelCasedString
    }
    
    public var dateStartValidity: Date {
        dateFromString(input: entity.startDate, inputFormat: .yyyyMMdd) ?? Date()
    }
    
    public var dateDescription: LocalizedStylableText? {
        formattedDescription()
    }
    
    public var amountAttributedString: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(entity.amount, font: font, decimalFontSize: 16)
        return amount.getFormatedCurrency()
    }
    
    public var isTopSeparatorHidden: Bool = true
    
    private(set) public var index: Int = 0
    
    public func setIndex(_ index: Int) {
        self.index = index
    }
    
    public var order: StandingOrderEntity {
        return entity
    }
    
    public init(entity: StandingOrderEntity ) {
        self.entity = entity
    }
}

private extension StandingOrdersPeriodicViewModel {
    func formattedDescription() -> LocalizedStylableText? {
        var localizableText: LocalizedStylableText?
        guard let day = dateToString(date: self.dateStartValidity, outputFormat: .d) else { return nil }
        switch entity.periodicity {
        case .annualy:
            guard let day = dateToString(date: self.dateStartValidity, outputFormat: .d_MMM) else { return nil }
            localizableText = localized("transfer_label_annualPeriodic", [StringPlaceholder(.date, day)])
        case .bimonth:
            localizableText = localized("transfer_label_bimonthlyPeriodic", [StringPlaceholder(.number, day)])
        case .halfYear:
            localizableText = localized("transfer_label_biannualPeriodic", [StringPlaceholder(.number, day)])
        case .monthly:
            localizableText = localized("transfer_label_monthlyPeriodic", [StringPlaceholder(.number, day)])
        case .weekly:
            guard let weekDay = dateToString(date: self.dateStartValidity, outputFormat: .eeee) else {
                return nil
            }
            localizableText = localized("transfer_label_weeklyPeriodic", [StringPlaceholder(.value, weekDay)])
        case .fixed, .none:
            break
        }
        return localizableText
    }
}
