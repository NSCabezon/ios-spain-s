//
//  FractionatePurchasesCarouselViewModel.swift
//  Menu
//
//  Created by Ignacio González Miró on 8/7/21.
//

import UI
import CoreFoundationLib

public enum FractionatePurchasesCarouselItemType {
    case item
    case seeMoreItems
}

public final class FractionatePurchasesCarouselViewModel {
    let baseUrl: String
    var cardEntity: CardEntity?
    var financeableMovement: FinanceableMovementEntity?
    var financeableMovementDetail: FinanceableMovementDetailEntity?
    var timeManager: TimeManager?
    var carouselItemType: FractionatePurchasesCarouselItemType
    
    public init(baseUrl: String, cardEntity: CardEntity?, financeableMovement: FinanceableMovementEntity?, financeableMovementDetail: FinanceableMovementDetailEntity?, timeManager: TimeManager?, carouselItemType: FractionatePurchasesCarouselItemType) {
        self.baseUrl = baseUrl
        self.cardEntity = cardEntity
        self.financeableMovement = financeableMovement
        self.financeableMovementDetail = financeableMovementDetail
        self.timeManager = timeManager
        self.carouselItemType = carouselItemType
    }
    
    var cardAliasAndNumber: String? {
        guard let cardEntity = self.cardEntity else {
            return nil
        }
        let cardAlias = cardEntity.alias ?? ""
        let cardNumber = " | " + cardEntity.shortContract
        return cardAlias + cardNumber
    }
    
    var cardImageUrl: String? {
        guard let cardEntity = self.cardEntity else {
            return nil
        }
        return self.baseUrl + cardEntity.cardImageUrl()
    }

    var movementViewModel: FractionableMovementViewModel? {
        guard let financeableMovement = self.financeableMovement else {
            return nil
        }
        return FractionableMovementViewModel(
            identifier: financeableMovement.identifier ?? "",
            operativeDate: dateToString(date: financeableMovement.date, outputFormat: .dd_MMM_yyyy) ?? "",
            name: financeableMovement.name ?? "",
            amount: financeableMovement.amount,
            pendingFees: financeableMovement.pendingFees,
            totalFees: financeableMovement.totalFees,
            addTapGesture: false
        )
    }
    
    var feeDetailViewModel: FractionatePurchasesCarouselDetailViewModel? {
        guard let amortizations = financeableMovementDetail?.amortizations,
              let amortizationEntity = amortizations
                .reversed()
                .first(where: { $0.descriptionPaymentState == .pending }),
              let timeManager = self.timeManager else {
            return nil
        }
        return FractionatePurchasesCarouselDetailViewModel(amortization: amortizationEntity, timeManager: timeManager)
    }
}

public final class FractionatePurchasesCarouselDetailViewModel: EasyPayMonthlyFeeViewProtocol {
    public var day: String
    public var month: String
    public var year: String
    public var feeNum: LocalizedStylableText
    public var feeAmount: NSAttributedString?
    public var pendingAmount: String?
    public var amortizationAmount: String?
    public var feeStatus: String?
    public var viewType: MonthlyViewModelType
    public var feeStatusColor: UIColor?
    public var calendarColor: UIColor
    public var secondTitleLabel: String
    public var thirdTitleLabel: String

    public init(amortization: FinanceableMovementDetailAmortizationEntity, timeManager: TimeManager) {
        self.secondTitleLabel = localized("transaction_label_pendingAmount")
        self.thirdTitleLabel = localized("easyPay_label_interest")
        let paymentDate = timeManager.fromString(input: amortization.paymentDate, inputFormat: .yyyyMMdd)
        self.feeNum = localized("amortization_label_fee", [StringPlaceholder(.value, String(amortization.paymentNumber ?? 0))])
        self.feeAmount = FractionatePurchasesCarouselDetailViewModel.getTotalAmountValue(amortization.feeAmount)
        self.amortizationAmount = FractionatePurchasesCarouselDetailViewModel.getAmountValue(amortization.interest)
        self.pendingAmount = FractionatePurchasesCarouselDetailViewModel.getAmountValue(amortization.pendingPaymentCapital)
        self.day = timeManager.toString(date: paymentDate, outputFormat: TimeFormat.d) ?? ""
        self.month = timeManager.toString(date: paymentDate, outputFormat: TimeFormat.MMM) ?? ""
        self.year = timeManager.toString(date: Date(), outputFormat: TimeFormat.yyyy) ?? ""
        self.viewType = .fractionablePurchase
        self.feeStatus = amortization.descriptionPaymentState.rawValue
        switch amortization.descriptionPaymentState {
        case .pending:
            self.feeStatusColor = .santanderYellow
            self.calendarColor = .coolGray
        default:
            self.feeStatusColor = .darkRed
            self.calendarColor = .coolGray
        }
    }
}

private extension FractionatePurchasesCarouselDetailViewModel {
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
