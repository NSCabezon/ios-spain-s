//
//  LoanSimulatorViewModel.swift
//  GlobalPosition
//
//  Created by César González Palomino on 29/01/2020.
//

import CoreFoundationLib

public struct LoanSimulatorViewModel {
    
    private var limitsEntity: LoanSimulationLimitsEntity
    private var simulationEntity: LoanSimulationEntity?
    let offerLocation: PullOfferLocation
    let offerEntity: OfferEntity
    
    init(entity: LoanSimulationLimitsEntity, offerLocation: PullOfferLocation, offerEntity: OfferEntity) {
        self.limitsEntity = entity
        self.offerLocation = offerLocation
        self.offerEntity = offerEntity
    }
    
    // static values
    let amountTitleLabelText: String? = localized("simulator_label_need")
    let moreinfoLabelText: String? = localized("pg_label_moreInfo")
    let monthsText: String? = localized("generic_label_months")
    let monthlyFeeTitleLabelText = "simulator_label_fee"
    
    private var defaultAmount: NSAttributedString? {
        
        var entityAmount: AmountEntity? = limitsEntity.defaultAmount
        if let ammount = selectedAmount {
            entityAmount = AmountEntity(value: Decimal(ammount))
        }
        guard let amount = entityAmount else { return nil }
        return NSAttributedString(string: amount.getFormattedValue(withDecimals: 0))
    }
    
    var amountValueLabelText: String? {
        defaultAmount?.string
    }
    
    private var amountFrom: NSAttributedString? {
        guard let amount = limitsEntity.amountFrom else { return nil }
        let resp = MoneyDecorator(amount,
                                  font: UIFont.santander(family: .text, type: .regular, size: 14.0))
        return resp.formatAsMillionsWithoutDecimals()
    }
    
    var minimumValueLabelText: NSAttributedString? {
        amountFrom
    }
    
    private var amountUntil: NSAttributedString? {
        guard let amount = limitsEntity.amountUntil else { return nil }
        let resp = MoneyDecorator(amount,
                                  font: UIFont.santander(family: .text, type: .bold, size: 14.0))
        return resp.formatAsMillionsWithoutDecimals()
    }
    
    var maximumValueLabelText: String? {
        amountUntil?.string
    }
    
    // only when simulation is done, values come from simulation entity
    var monthlyFeeValueLabelText: NSAttributedString? {
        
        if let fee = simulationEntity?.installmentWithBonus {
            return MoneyDecorator(AmountEntity(value: Decimal(fee)),
                                  font: UIFont.santander(family: .text, type: .bold, size: 24.0),
                                  decimalFontSize: 18.0).formatAsMillions()
        } else {
            return NSAttributedString(string: "--")
        }
    }
    
    // values for the Slider
    var amountMinimun: Float {
        guard let value = limitsEntity.amountFrom?.value,
              let double = Double(value.description) else { return 0.0 }
        return Float(double)
    }
    
    var amountMaximum: Float {
        guard let value = limitsEntity.amountUntil?.value,
              let double = Double(value.description) else { return 0.0 }
        return Float(double)
    }
    
    var amountCurrent: Float {
        if let amount = selectedAmount {
            return Float(amount)
        }
        guard let value = limitsEntity.defaultAmount?.value,
              let double = Double(value.description) else { return 0.0 }
        return Float(double)
    }
    
    // values for the Circular Slider
    var monthsMinimun: Double {
        guard let value = limitsEntity.termFrom?.value
               else { return 0.0 }
        
        return  Double(value.description) ?? 0.0
    }
    
    var monthsMaximum: Double {
        guard let value = limitsEntity.termUntil?.value
               else { return 0.0 }
        
        return  Double(value.description) ?? 0.0
    }
    
    // should be updated when simulation is done
    var monthsCurrent: Double {
        var entityValue: Decimal?
        if let selectedMonths = selectedMonths {
            entityValue = Decimal(selectedMonths)
        }
        guard let value = entityValue ?? limitsEntity.defaultTerm?.value
               else { return 0.0 }
        
        return  Double(value.description) ?? 0.0
    }
 
    // values coming only from the simulation entity
    var openingCommissionLabelText: String {
        comissionStringFor(type: .opening)
    }
    
    var tinLabelText: String {
        comissionStringFor(type: .tin)
    }
    
    var taeLabelText: String {
        comissionStringFor(type: .tae)
    }
    
    private var selectedMonths: Int?
    private var selectedAmount: Int?
    mutating func simulationDoneWith(entity: LoanSimulationEntity, months: Int, amount: Int) {
        self.simulationEntity = entity
        self.selectedMonths = months
        self.selectedAmount = amount
    }
    
    private var taeFormatter: NumberFormatter {
        return formatterForRepresentation(.tae())
    }
    
    private enum ComissionType {
        case tae, tin, opening
    }
    
    private func comissionStringFor(type: ComissionType) -> String {
        
        var placeHolderValue: String = "--"
        var value: Double?
        var title = ""
        switch type {
        case .tae:
            value = simulationEntity?.taeWithBonus
            title = "simulator_label_tae"
        case .tin:
            value = simulationEntity?.interestType
            title = "simulator_label_tin"
        case .opening:
            value = simulationEntity?.openingCommission
            title = "simulator_label_commission"
        }
        
        guard let realValue = value else { return placeHolderValue }
        let number = Decimal(realValue)
        guard
            let resp = taeFormatter.string(from: NSDecimalNumber(decimal: number))
            else { return placeHolderValue }
        placeHolderValue = resp
        
        return localized(title,
                         [StringPlaceholder(.value, placeHolderValue)]).text
    }
}
