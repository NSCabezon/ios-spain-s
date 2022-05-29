//
//  MonthlyFeeViewModel.swift
//  Cards
//
//  Created by alvola on 10/12/2020.
//

import CoreFoundationLib
import UI

struct MonthlyFeeViewModel: EasyPayMonthlyFeeViewProtocol {
    var day: String
    var month: String
    var year: String
    var feeNum: LocalizedStylableText
    var feeAmount: NSAttributedString?
    var pendingAmount: String?
    var amortizationAmount: String?
    var feeStatus: String?
    var viewType: MonthlyViewModelType
    var feeStatusColor: UIColor?
    var calendarColor: UIColor
    var secondTitleLabel: String
    var thirdTitleLabel: String
    
    init(amortization: AmortizationEntity, num: Int, timeManager: TimeManager) {
        secondTitleLabel = localized("amortization_label_pending")
        thirdTitleLabel = localized("amortization_label_amortizationAmount")
        feeNum = localized("amortization_label_fee", [StringPlaceholder(.value, String(num + 1))])
        feeAmount = MonthlyFeeViewModel.getTotalAmountValue(amortization.totalFeeAmount)
        amortizationAmount = MonthlyFeeViewModel.getAmountValue(amortization.amortizedAmount)
        pendingAmount = MonthlyFeeViewModel.getAmountValue(amortization.pendingAmount)
        day = timeManager.toString(date: amortization.nextAmortizationDate, outputFormat: TimeFormat.d) ?? ""
        month = timeManager.toString(date: amortization.nextAmortizationDate, outputFormat: TimeFormat.MMM) ?? ""
        year = timeManager.toString(date: amortization.nextAmortizationDate, outputFormat: TimeFormat.yyyy) ?? ""
        viewType = .easyPay
        feeStatus = nil
        feeStatusColor = nil
        calendarColor = .coolGray
    }
    
    init(amortization: FinanceableMovementDetailAmortizationEntity, timeManager: TimeManager) {
        secondTitleLabel = localized("transaction_label_pendingAmount")
        thirdTitleLabel = localized("easyPay_label_interest")
        let paymentDate = timeManager.fromString(input: amortization.paymentDate, inputFormat: .yyyyMMdd)
        feeNum = localized("amortization_label_fee", [StringPlaceholder(.value, String(amortization.paymentNumber ?? 0))])
        feeAmount = MonthlyFeeViewModel.getTotalAmountValue(amortization.feeAmount)
        amortizationAmount = MonthlyFeeViewModel.getAmountValue(amortization.interest)
        pendingAmount = MonthlyFeeViewModel.getAmountValue(amortization.pendingPaymentCapital)
        day = timeManager.toString(date: paymentDate, outputFormat: TimeFormat.d) ?? ""
        month = timeManager.toString(date: paymentDate, outputFormat: TimeFormat.MMM) ?? ""
        year = timeManager.toString(date: Date(), outputFormat: TimeFormat.yyyy) ?? ""
        viewType = .fractionablePurchase
        switch amortization.descriptionPaymentState {
        case .cancelled:
            feeStatus = localized("fractionatePurchases_label_canceled")
        case .pending:
            feeStatus = localized("fractionatePurchases_label_pending")
        case .settled:
            feeStatus = localized("fractionatePurchases_label_liquidated")
        }
        switch amortization.descriptionPaymentState {
        case .settled:
            feeStatusColor = .limeGreen
            calendarColor = .limeGreen
        case .pending:
            feeStatusColor = .santanderYellow
            calendarColor = .coolGray
        default:
            feeStatusColor = .bostonRedLight
            calendarColor = .bostonRedLight
        }
    }
}

private extension MonthlyFeeViewModel {
    static func getTotalAmountValue(_ amountEntity: AmountEntity?) -> NSAttributedString? {
        guard let entity = amountEntity else {
            return nil
        }
        let decorator = MoneyDecorator(entity, font: UIFont.santander(type: .bold, size: 16.0), decimalFontSize: 14.0)
        return decorator.getFormatedCurrency()
    }
    
    static func getAmountValue(_ amountEntity: AmountEntity?) -> String? {
        guard let entity = amountEntity else {
            return nil
        }
        return entity.value != 0 ? entity.getFormattedAmountUIWith1M() : entity.getFormattedAmountAsMillions(withDecimals: 2)
    }
}
