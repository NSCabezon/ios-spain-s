//
//  MovementDetailViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/06/2020.
//

import CoreFoundationLib

public struct AnalysisMovementDetailEntity {
    private let description: String
    private let iban: String
    private let amount: Decimal
    private var operationDate: Date
    
    public init(description: String, iban: String, amount: Decimal, opDate: Date) {
        self.description = description
        self.iban = iban
        self.amount = amount
        self.operationDate = opDate
    }
    
    public var concept: String {
        description
    }
    
    public var ibanString: String {
        iban
    }
    
    public var operationDateString: String {
        dateToString(date: operationDate, outputFormat: .d_MMMM_YYYY) ?? ""
    }
    
    var attributedAmountString: NSAttributedString? {
        let font = UIFont.santander(family: .text, type: .bold, size: 32.0)
        let amountEntity = AmountEntity(value: amount)
        let moneyDecorator = MoneyDecorator(amountEntity,
                                            font: font,
                                            decimalFontSize: 18.0)
        return moneyDecorator.getFormatedCurrency()
    }
}

public struct MovementDetailViewModel {
    private let movements: [AnalysisMovementDetailEntity]
    private let selected: AnalysisMovementDetailEntity
    public init(movements: [AnalysisMovementDetailEntity], selected: AnalysisMovementDetailEntity) {
        self.movements = movements
        self.selected = selected
    }
    
    var movementsCount: Int {
        movements.count
    }
    
    func itemAtIndexPath(_ indexpath: IndexPath) -> AnalysisMovementDetailEntity? {
        guard indexpath.row <= movementsCount else {
            return nil
        }
        return movements[indexpath.row]
    }
}
