import UI
import CoreFoundationLib

public class FractionablePurchaseDetailCarouselViewModel {
    var financeableMovementEntityList: [FractionablePurchaseDetailViewModel]
    var selectedFinanceableMovementEntity: FractionablePurchaseDetailViewModel

    public init(_ selected: FractionablePurchaseDetailViewModel, detailEntityList: [FractionablePurchaseDetailViewModel]) {
        self.selectedFinanceableMovementEntity = selected
        self.financeableMovementEntityList = detailEntityList
    }
}

public class FractionablePurchaseDetailViewModel {
    let financeableMovementEntity: FinanceableMovementEntity
    var financeableMovementDetailEntity: FinanceableMovementDetailEntity?
    let cardEntity: CardEntity
    var carouselState: ResizableState = .colapsed
    var itemStatus: FractionablePurchaseItemStatus = .loading
    var timeManager: TimeManager
    
    public init(_ entity: FinanceableMovementEntity, detailEntity: FinanceableMovementDetailEntity?, cardEntity: CardEntity, timeManager: TimeManager) {
        financeableMovementEntity = entity
        financeableMovementDetailEntity = detailEntity
        self.cardEntity = cardEntity
        self.timeManager = timeManager
    }
    
    // MARK: FeeDetail View
    var pendingPaymentCapitalAmountAttributeString: NSAttributedString? {
        guard let amount = pendingPaymentCapitalAmount else {
            return nil
        }
        let font: UIFont = .santander(family: .text, type: .bold, size: 26)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 20.0)
        return decorator.getFormatedCurrency()
    }
    
    var feeAmountAttributeString: NSAttributedString? {
        guard let amount = feeAmountEntity else {
            return nil
        }
        let font: UIFont = .santander(family: .text, type: .regular, size: 13)
        let decorator = MoneyDecorator(amount, font: font)
        return decorator.getFormatedCurrency()
    }
    
    var pendingQuotas: String? {
        guard let pendingQuotas = financeableMovementDetailEntity?.pendingQuotas else {
            return nil
        }
        return String(pendingQuotas)
    }
    
    var numOfMonthsLocalizedString: LocalizedStylableText? {
        guard let numOfFees = self.numOfFees else {
            return nil
        }
        let stringPlaceholder = [StringPlaceholder(.value, "\(numOfFees)")]
        return localized("simulator_label_months", stringPlaceholder)
    }
    
    // MARK: Operation View
    var operationDateFormatted: String? {
        guard let operationDateString = self.operationDate else {
            return nil
        }
        let lastLiquidationDate = timeManager.fromString(input: operationDateString, inputFormat: .yyyyMMdd)
        return timeManager.toString(date: lastLiquidationDate, outputFormat: .dd_MM_yyyy)
    }
        
    var lastLiquidationDateFormatted: String? {
        guard let lastLiquidationDateString = self.lastLiquidationDate else {
            return nil
        }
        let lastLiquidationDate = timeManager.fromString(input: lastLiquidationDateString, inputFormat: .yyyyMMdd)
        return timeManager.toString(date: lastLiquidationDate, outputFormat: .dd_MM_yyyy)
    }
    
    // MARK: Amortized View
    var paidCapitalAmountString: String? {
        guard let paidCapitalAmount = self.paidCapitalAmount else {
            return nil
        }
        return paidCapitalAmount.getStringValue(withDecimal: 2)
    }
    
    var totalAmountString: String? {
        guard let totalAmount = self.totalAmountEntity else {
            return nil
        }
        return totalAmount.getStringValue(withDecimal: 2)
    }
    
    // MARK: MoreInfo View
    var numOfFeeLocalizedString: LocalizedStylableText? {
        guard let numOfFeesString = self.pendingQuotas, let numOfFees = Int(numOfFeesString), let feeAmount = self.feeAmountAttributeString else {
            return nil
        }
        let stringPlaceholder = [StringPlaceholder(.number, String(numOfFees)), StringPlaceholder(.value, feeAmount.string)]
        switch numOfFees {
        case 0:
            return localized("fractionatePurchases_label_instalmentsValueLoading_other", stringPlaceholder)
        case 1:
            return localized("fractionatePurchases_label_instalmentsValue_one", stringPlaceholder)
        default:
            return localized("fractionatePurchases_label_instalmentsValue_other", stringPlaceholder)
        }
    }
    
    var feeAmountString: String? {
        guard let feeAmount = self.feeAmountEntity else {
            return nil
        }
        return feeAmount.getStringValue(withDecimal: 2)
    }
    
    var interestAmountString: String? {
        guard let interestAmount = self.interestAmount else {
            return nil
        }
        return interestAmount.getStringValue(withDecimal: 2)
    }
    
    var capitalAmountString: String? {
        guard let capitalAmount = self.capitalAmount else {
            return nil
        }
        return capitalAmount.getStringValue(withDecimal: 2)
    }
    
    // MARK: FeeDetail ErrorView
    var numOfFeesInErrorString: LocalizedStylableText {
        let stringPlaceholder = [StringPlaceholder(.number, String(financeableMovementEntity.pendingFees))]
        return financeableMovementEntity.pendingFees == 1
            ? localized("fractionatePurchases_label_instalmentsValueLoading_one", stringPlaceholder)
            : localized("fractionatePurchases_label_instalmentsValueLoading_other", stringPlaceholder)

    }
    
    // MARK: MonthlyFeeViewModel
    var amortizations: [MonthlyFeeViewModel]? {
        return financeableMovementDetailEntity?.amortizations?.map({ amortization  in
            return MonthlyFeeViewModel(amortization: amortization, timeManager: timeManager)
        })
    }
}

private extension FractionablePurchaseDetailViewModel {
    var totalAmountEntity: AmountEntity? {
        financeableMovementDetailEntity?.totalAmount
    }
    
    var pendingPaymentCapitalAmount: AmountEntity? {
        financeableMovementDetailEntity?.pendingPaymentCapital
    }
    
    var feeAmountEntity: AmountEntity? {
        financeableMovementDetailEntity?.feeAmount
    }
    
    var numOfFees: Int? {
        financeableMovementDetailEntity?.numberFees
    }
    
    var operationDate: String? {
        financeableMovementDetailEntity?.operationDate
    }
    
    var lastLiquidationDate: String? {
        financeableMovementDetailEntity?.lastLiquidationDate
    }
    
    var interestAmount: AmountEntity? {
        financeableMovementDetailEntity?.interestAmount
    }
    
    var capitalAmount: AmountEntity? {
        financeableMovementDetailEntity?.capitalAmount
    }
    
    var paidCapitalAmount: AmountEntity? {
        financeableMovementDetailEntity?.paidCapital
    }
}
