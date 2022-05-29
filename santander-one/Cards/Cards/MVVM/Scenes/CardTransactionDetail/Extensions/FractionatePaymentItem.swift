//
//  FractionatePaymentViewModel.swift
//  Pods
//
//  Created by Boris Chirino Fernandez on 30/04/2020.
//

import CoreFoundationLib
import Foundation

public struct MontlyPaymentFeeItem: MontlyPaymentFeeConformable {
    /// montly fee amount
    public var fee: Decimal
    /// number of months that fee apply
    public var months: Int
    public var entity: EasyPayAmortizationEntity?
}

public class FractionatePaymentItem {
    var entity: FractionatePaymentEntity?
    var isAllInOneCard = false
    private var numberOfMonthsList = [Int]()
    private var currentAmount: Decimal = 0
    public init() {}
    
    public var fractionsQuantity: Int {
        entity?.montlyFeeItems.count ?? 0
    }
    
    public var minAmount: Int {
        entity?.minimumAmount ?? 0
    }
    
    public func updateEntity(entity: FractionatePaymentEntity) {
        self.entity = entity
    }

    public var showNoInterestText: Bool {
        isAllInOneCard &&
        numberOfMonthsList[InstallmentsConstants.averageTermIndex] == InstallmentsConstants.allInOneNoInterestTerm &&
        currentAmount >= InstallmentsConstants.allInOneCardLowerLimitQuote &&
        currentAmount <= InstallmentsConstants.allInOneCardUpperLimitQuote
    }
    
    /// Return the title, subtitle for each of the monthly fee
    /// - Parameter index: the index of a collection of MontlyFeeItems
    public func textInformationAtIndex(_ index: Int) -> (title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        guard  index < fractionsQuantity, let easyPayItem = self.entity?.montlyFeeItems[index] else {
            return (LocalizedStylableText.empty, LocalizedStylableText.empty)
        }
        
        if easyPayItem.fee == 0 && easyPayItem.months == 0 {
            return textForOtherTermOption()
        }
        let monthlyFeeText = formattedMoneyFromAmount(easyPayItem.fee)
        let numberOfMonthsText = String(describing: easyPayItem.months)
        let localizedTextForTitle = localized("easyPay_button_monthPayment", [StringPlaceholder(.value, monthlyFeeText)])
        var localizedTextForSubTitle: LocalizedStylableText
        if showNoInterestText && index == 0 {
            localizedTextForSubTitle = localized("easyPay_text_payIn", [StringPlaceholder(.number, numberOfMonthsText)])
        } else {
            localizedTextForSubTitle = localized("easyPay_text_forMonths", [StringPlaceholder(.number, numberOfMonthsText)])
        }
        return (localizedTextForTitle, localizedTextForSubTitle)
    }
    
    public func montlyPaymentAtIndex(_ index: Int) -> MontlyPaymentFeeItem? {
        guard  index < fractionsQuantity, let montlyFeeEntity = entity?.montlyFeeItems[index] else {
            return nil
        }
        
        return MontlyPaymentFeeItem(fee: montlyFeeEntity.fee, months: montlyFeeEntity.months, entity: montlyFeeEntity.easyPayAmortization)
    }
    
    public func getNumberOfMonthsForQuoteCalculation(amount: Decimal?, isAllInOneCard: Bool) -> [Int]? {
        guard let paramAmount = amount else { return nil }
        self.isAllInOneCard = isAllInOneCard
        let realAmount = abs(paramAmount)
        self.currentAmount = realAmount
        var numberOfMonths = [Int]()
        let maximumTerm = calculateMaximumTerm(amount: realAmount)
        let mediumTerm = calculateMediumTerm(maximumTerm: maximumTerm)
        numberOfMonths = [(mediumTerm as NSDecimalNumber).intValue,
                          (maximumTerm as NSDecimalNumber).intValue]
        if isAllInOneCard &&
            realAmount >= InstallmentsConstants.allInOneCardLowerLimitQuote && realAmount <= InstallmentsConstants.allInOneCardUpperLimitQuote {
            numberOfMonths[InstallmentsConstants.averageTermIndex] = InstallmentsConstants.allInOneNoInterestTerm
            if numberOfMonths[InstallmentsConstants.maximumTermIndex] == InstallmentsConstants.allInOneNoInterestTerm {
                numberOfMonths[InstallmentsConstants.maximumTermIndex] = InstallmentsConstants.minimumInstallmentsNumber
            }
        }
        numberOfMonthsList = numberOfMonths
        return numberOfMonths
    }
    
    public func calculateMaximumTerm(amount: Decimal) -> Decimal {
        let result = Decimal(InstallmentsConstants.maximumInstallmentsNumber)
        let maximunTerm = (amount as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: InstallmentsConstants.minimumFeeAmount))
        let roundedMaximumTerm = roundedDecimalToInt(decimal: Decimal(maximunTerm.doubleValue), down: true)
        if roundedMaximumTerm > InstallmentsConstants.maximumInstallmentsNumber {
            return result
        }
        return Decimal(roundedMaximumTerm)
    }
    
    public func calculateMediumTerm(maximumTerm: Decimal) -> Decimal {
        let nominalMediumTerm = (maximumTerm as NSDecimalNumber).dividing(by: 2)
        let mediumTerm = roundedDecimalToInt(decimal: Decimal(nominalMediumTerm.doubleValue), down: false)
        return Decimal(mediumTerm)
    }
}

private extension FractionatePaymentItem {
    /// Return an appropiate description of currency based on a decimal quantity
    /// - Parameter amount: Money amount
    func formattedMoneyFromAmount(_ amount: Decimal) -> String {
        let amountEntity = AmountEntity(value: amount)
        return amountEntity.getFormattedAmountAsMillions()
    }
    
    /// return appropiate texts for other term option
    func textForOtherTermOption() -> (title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        let upperLimitText = String(describing: self.entity?.maxMonths ?? 0)
        let localizedTextForSubTitle = localized("easyPay_text_untilMonths", [StringPlaceholder(.number, upperLimitText)])
        return (localized("easyPay_button_anotherTerm"), localizedTextForSubTitle)
    }
    
    func roundedDecimalToInt(decimal: Decimal, down: Bool) -> Int {
        let value = NSDecimalNumber(decimal: decimal)
        let doubleDecimal = abs(value.doubleValue).rounded(down ? .towardZero : .awayFromZero)
        return Int(doubleDecimal)
    }
}
