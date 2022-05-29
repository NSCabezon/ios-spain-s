//
//  ReceiptsViewModel.swift
//  Menu
//
//  Created by Ignacio González Miró on 10/06/2020.
//

import CoreFoundationLib

final class ReceiptsViewModel {
    private let ibanEntity: IBANEntity?
    let receipt: TimeLineReceiptEntity
    private let timeManager: TimeManager
    private let baseUrl: String?

    init(_ ibanEntity: IBANEntity?, receipt: TimeLineReceiptEntity, timeManager: TimeManager, baseUrl: String?) {
        self.receipt = receipt
        self.ibanEntity = ibanEntity
        self.timeManager = timeManager
        self.baseUrl = baseUrl
    }
    
    var executedDate: Date? {
        return receipt.fullDate
    }
    
    var executedDateString: String? {
        return timeManager.toStringFromCurrentLocale(date: receipt.fullDate, outputFormat: .dd_MMM_yyyy)?.uppercased()
    }
    
    var shortIban: String {
        return ibanEntity?.ibanShort(asterisksCount: 1) ?? "****"
    }
    
    var title: String {
        return receipt.merchant.name
    }
    
    var amount: NSAttributedString? {
        let amountEntity = AmountEntity(value: receipt.amount)
        let font = UIFont.santander(family: .text, type: .bold, size: 20.0)
        let moneyDecorator = MoneyDecorator(amountEntity, font: font, decimalFontSize: 16.0)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var amountEntity: AmountEntity {
        return AmountEntity(value: receipt.amount)
    }
    
    var iconUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil}
        return String(format: "%@apps/SAN/timeline/merchants/%@.png", baseUrl, receipt.merchant.code)
    }
}
