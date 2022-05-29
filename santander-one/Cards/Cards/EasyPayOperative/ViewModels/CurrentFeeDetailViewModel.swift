//
//  CurrentFeeDetailViewModel.swift
//  Cards
//
//  Created by Luis Escámez Sánchez on 04/12/2020.
//

import CoreFoundationLib

public struct CurrentFeeDetailViewModel {
    
    private let monthlyFeeAmount: AmountEntity?
    private let monthsAmount: Int?
    private let firstFeeDate: Date?
    private let comissionAmount: AmountEntity?
    private let interest: AmountEntity?
    private let taePercentage: Double?
    private let totalAmount: AmountEntity?
    private let localeManager: TimeManager?
    private let symbolNullString: String = "-"
    
    private var keys: CurrentFeeDetailViewModelKeys {
        return CurrentFeeDetailViewModelKeys(monthlyFeeTitle: "generic_label_monthlyFee",
                                             monthsTitle: "easyPay_label_toPay",
                                             firstfeeDateTitle: "easyPay_label_firstInstallment",
                                             comissionTitle: "easyPay_label_commission",
                                             interestsTitle: "easyPay_label_interest",
                                             interestTooltip: "amortization_label_financeBuyContract",
                                             TAEtitle: "generic_label_tae",
                                             totalAmountTitle: "easyPay_label_totalAmount")
    }
    
    public init(monthlyFeeAmount: AmountEntity?,
                monthsAmount: Int?,
                firstFeeDate: Date?,
                comissionAmount: AmountEntity?,
                interest: AmountEntity?,
                taePercentage: Double?,
                totalAmount: AmountEntity?,
                localeManager: TimeManager) {
        self.monthlyFeeAmount = monthlyFeeAmount
        self.monthsAmount = monthsAmount
        self.firstFeeDate = firstFeeDate
        self.comissionAmount = comissionAmount
        self.interest = interest
        self.taePercentage = taePercentage
        self.totalAmount = totalAmount
        self.localeManager = localeManager
    }
}

// MARK: - Private Methods
private extension CurrentFeeDetailViewModel {
    
    var monthlyFeeAttributed: NSAttributedString? {
        guard let monthlyFeeAmount = monthlyFeeAmount else { return nil }
        let amount = MoneyDecorator(monthlyFeeAmount,
                                    font: .santander(family: .text, type: .bold, size: 36),
                                    decimalFontSize: 20)
        return amount.getFormatedCurrency()
    }
    
    func getFirstFeeStringDate() -> String? {
        guard let firstFeeDate = firstFeeDate else { return symbolNullString }
        return localeManager?.toString(date: firstFeeDate, outputFormat: .dd_MMM_yyyy)
    }
}

extension CurrentFeeDetailViewModel {
    
    public var monthlyFeeInfo: (title: String, amount: NSAttributedString) {
        return (localized(keys.monthlyFeeTitle),
                monthlyFeeAttributed ?? NSAttributedString(string: symbolNullString))
    }
    
    public var totalMonthsInfo: (title: String, amount: LocalizedStylableText) {
        let monthsString = monthsAmount != nil ? "\(monthsAmount ?? 0)" : symbolNullString
        let totalMonthsText = localized("simulator_label_months", [StringPlaceholder(.value, monthsString)])
        return (localized(keys.monthsTitle), totalMonthsText)
    }
    
    public var firstFeeInfo: (title: String, date: String?) {
        return (localized(keys.firstfeeDateTitle), getFirstFeeStringDate())
    }
    
    public var comissionInfo: (title: String, amount: String) {
        guard let comissionAmount = comissionAmount else { return (localized(keys.comissionTitle), symbolNullString) }
        return (localized(keys.comissionTitle), comissionAmount.getStringValue(withDecimal: 2))
    }
    
    public var interestInfo: (title: String, tootltiptext: String, amount: String) {
        return (localized(keys.interestsTitle),
                localized(keys.interestTooltip),
                interest?.getStringValue(withDecimal: 2) ?? symbolNullString)
    }
    
    public var TAEInfo: (title: String, percentage: String) {
        guard let taePercentage = taePercentage else { return (localized(keys.TAEtitle), symbolNullString) }
        let roundedTAE = Decimal(taePercentage).getDecimalFormattedValue()
        return (localized(keys.TAEtitle), "\(roundedTAE)%")
    }
    
    public var totalAmountInfo: (title: String, amount: String) {
        guard let totalAmount = totalAmount else { return (localized(keys.totalAmountTitle), symbolNullString) }
        return (localized(keys.totalAmountTitle), totalAmount.getStringValue(withDecimal: 2))
    }
}

public struct CurrentFeeDetailViewModelKeys {
    
    fileprivate let monthlyFeeTitle: String
    fileprivate let monthsTitle: String
    fileprivate let firstfeeDateTitle: String
    fileprivate let comissionTitle: String
    fileprivate let interestsTitle: String
    fileprivate let interestTooltip: String
    fileprivate let TAEtitle: String
    fileprivate let totalAmountTitle: String
    
    public init(monthlyFeeTitle: String,
                monthsTitle: String,
                firstfeeDateTitle: String,
                comissionTitle: String,
                interestsTitle: String,
                interestTooltip: String,
                TAEtitle: String,
                totalAmountTitle: String) {
        self.monthlyFeeTitle = monthlyFeeTitle
        self.monthsTitle = monthsTitle
        self.firstfeeDateTitle = firstfeeDateTitle
        self.comissionTitle = comissionTitle
        self.interestsTitle = interestsTitle
        self.interestTooltip = interestTooltip
        self.TAEtitle = TAEtitle
        self.totalAmountTitle = totalAmountTitle
    }
}

public enum CurrentFeeViewAccesibilityIds: String {
    case monthlyFee
    case totalMonths
    case firstFee
    case comission
    case interests
    case tae
    case totalAmount
    case tooltip
    
    var title: String {
        return self.rawValue+"_title"
    }
    
    var description: String {
        return self.rawValue+"_value"
    }
}
