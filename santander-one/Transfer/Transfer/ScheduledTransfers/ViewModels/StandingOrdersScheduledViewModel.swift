//
//  StandingOrdersScheduledViewModel.swift
//  Transfer
//
//  Created by Boris Chirino Fernandez on 16/7/21.
//

import CoreFoundationLib

public final class StandingOrdersScheduledViewModel: ScheduledTransferViewModelProtocol {
    public let entity: StandingOrderEntity
    
    public var account: AccountEntity {
        entity.account
    }
    
    public var concept: String {
        (entity.subject ?? localized("onePay_label_genericProgrammed")).camelCasedString
    }
    
    public var dateStartValidity: Date {
        dateFromString(input: entity.startDate, inputFormat: .yyyyMMdd) ?? Date()
    }
    
    public var date: String? {
        dateToString(date: dateStartValidity, outputFormat: .dd_MMM_yyyy)
    }
    
    public var amountAttributedString: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(entity.amount, font: font, decimalFontSize: 16)
        return amount.getFormatedCurrency()
    }
    
    public var isTopSeparatorHidden: Bool = true
    
    public private (set) var index: Int = 0
    
    public func setIndex(_ index: Int) {
        self.index = index
    }
    
    public init(entity: StandingOrderEntity ) {
        self.entity = entity
    }
}
