import CoreFoundationLib

final class OldCardTransactionDetailViewModel {
    
    var transaction: CardTransactionEntity
    var card: CardEntity
    var timeManager: TimeManager
    var detail: CardTransactionDetailEntity?
    var error: String?
    var minEasyPayAmount: Double?
    var isEasyPayModeEnabled: Bool?
    var offerEntity: OfferEntity?
    var offerRatio: CGFloat?
    var isSplitExpensesEnabled: Bool?
    var transactionUpdated: Bool?
    var isAlreadyFractionated: Bool = false
    var viewConfiguration: CardTransactionDetailViewConfigurationProtocol?
    
    init(transaction: CardTransactionEntity,
         card: CardEntity,
         error: String?,
         minEasyPayAmount: Double?,
         timeManager: TimeManager,
         isEasyPayModeEnabled: Bool?,
         isSplitExpensesEnabled: Bool?,
         offerEntity: OfferEntity? = nil,
         offerRatio: CGFloat? = nil,
         viewConfiguration: CardTransactionDetailViewConfigurationProtocol? = nil) {
        self.transaction = transaction
        self.card = card
        self.timeManager = timeManager
        self.detail = nil
        self.error = error
        self.minEasyPayAmount = minEasyPayAmount
        self.isEasyPayModeEnabled = isEasyPayModeEnabled
        self.offerEntity = offerEntity
        self.offerRatio = offerRatio
        self.isSplitExpensesEnabled = isSplitExpensesEnabled
        self.viewConfiguration = viewConfiguration
    }
    
    init(transaction: CardTransactionEntity,
         card: CardEntity,
         detail: CardTransactionDetailEntity?,
         minEasyPayAmount: Double?,
         timeManager: TimeManager,
         isEasyPayModeEnabled: Bool?,
         isSplitExpensesEnabled: Bool?,
         offerEntity: OfferEntity? = nil,
         offerRatio: CGFloat? = nil,
         viewConfiguration: CardTransactionDetailViewConfigurationProtocol? = nil) {
        self.transaction = transaction
        self.card = card
        self.timeManager = timeManager
        self.detail = detail
        self.error = nil
        self.minEasyPayAmount = minEasyPayAmount
        self.isEasyPayModeEnabled = isEasyPayModeEnabled
        self.offerEntity = offerEntity
        self.offerRatio = offerRatio
        self.isSplitExpensesEnabled = isSplitExpensesEnabled
        self.viewConfiguration = viewConfiguration
    }
    
    var description: String {
        return transaction.description?.capitalized ?? ""
    }
    
    var cardAlias: String {
        return card.alias ?? ""
    }
    
    var formattedAmount: NSAttributedString? {
        guard let amount = transaction.amount else { return nil }
        let font = UIFont.santander(family: .text, type: .bold, size: 32)
        let moneyDecorator = MoneyDecorator(amount, font: font)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var operationDate: NSAttributedString? {
        let date = timeManager.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
        guard transactionUpdated == true else {
            let date = timeManager.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
            return self.formattedOperationDate(date: date, time: "")
        }
        guard let time = operationTime else {
            let date = timeManager.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
            let time = timeManager.toString(date: transaction.operationDate, outputFormat: .HHmm) ?? ""
            return self.formattedOperationDate(date: date, time: time)
        }
        return self.formattedOperationDate(date: date, time: time)
    }
    
    var operationTime: String? {
        guard let time = self.detail?.transactionDate else { return nil }
        guard let dateString = timeManager.toString(input: time, inputFormat: TimeFormat.HHmmssZ, outputFormat: TimeFormat.HHmm) else {
            return nil
        }
        return dateString
    }
    
    var annotationDescription: String? {
        guard annotationDate != nil else { return nil }
        return  localized("transaction_label_annotationDate")
    }
    
    var annotationDate: String? {
        return timeManager.toString(date: transaction.annotationDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var retentionDescription: String? {
        guard bankCharge != nil else { return nil }
        return localized("transaction_label_fees")
    }
    
    var bankCharge: String? {
        return detail?.bankCharge?.getStringValue()
    }
    
    var soldOutDescription: String? {
        guard self.detail != nil else { return nil }
        if self.isSoldOut {
            return localized("cardDetail_text_liquidated")
        } else {
            return localized("cardDetail_text_notLiquidated")
        }
    }
    
    var isSoldOut: Bool {
        return detail?.isSoldOut ?? false
    }
    
    var soldOutDate: String? {
        guard let detail = self.detail, detail.isSoldOut, let soldOutDate = detail.soldOutDate else { return nil }
        return timeManager.toString(date: soldOutDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var isEasyPayEnabled: Bool {
        guard isEasyPayModeEnabled ?? false else { return false }
        guard card.isCreditCard, !card.isBeneficiary else { return false }
        guard let minEasyPayAmount = self.minEasyPayAmount else { return false }
        let value = NSDecimalNumber(decimal: transaction.amount?.value ?? 0)
        return abs(value.doubleValue) >= minEasyPayAmount
    }
    
    var isTransactionNegative: Bool {
        guard let amount = self.amount.value else {
            return false
        }
        return amount < 0
    }
    
    var isSplitExpensesOperativeEnabled: Bool {
        guard let isSplitExpensesEnabled = self.isSplitExpensesEnabled else {
            return false
        }
        return self.isTransactionNegative && isSplitExpensesEnabled
    }
    
    var showPossitiveAmountBackground: Bool {
        guard let modifier = viewConfiguration else { return true }
        return modifier.showAmountBackground
    }
    
    func getConfiguration() -> [CardTransactionDetailViewConfiguration] {
        if let modifier = viewConfiguration {
            return modifier.getConfiguration(from: transaction)
        } else {
            let operationDate = CardTransactionDetailView(title: localized("transaction_label_operationDate"),
                                                          value: self.operationDate ?? NSAttributedString())
            let soldOut = CardTransactionDetailView(title: soldOutDescription ?? "",
                                                    value: soldOutDate ?? " ")
            let configRow1 = CardTransactionDetailViewConfiguration(left: operationDate, right: soldOut)
            let annotationDate = CardTransactionDetailView(title: annotationDescription ?? "",
                                                           value: self.annotationDate ?? "")
            let retentionCharges = CardTransactionDetailView(title: retentionDescription ?? "",
                                                             value: bankCharge ?? "")
            let configRow2 = CardTransactionDetailViewConfiguration(left: annotationDate, right: retentionCharges)
            return [configRow1, configRow2]
        }
    }
}

extension OldCardTransactionDetailViewModel: SplitableExpenseProtocol {
    var amount: AmountEntity {
        return self.transaction.amount ?? AmountEntity(value: 0)
    }
    
    var concept: String {
        return self.description
    }
    
    var productAlias: String {
        return self.cardAlias
    }
}

extension OldCardTransactionDetailViewModel: Equatable {
    
    static func == (lhs: OldCardTransactionDetailViewModel, rhs: OldCardTransactionDetailViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension OldCardTransactionDetailViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        hasher.combine(transaction.operationDate)
        hasher.combine(card.detailUI)
        hasher.combine(transaction.transactionDay?.description)
    }
}

extension OldCardTransactionDetailViewModel: Shareable {
    
    func getShareableInfo() -> String {
        if let shareable = viewConfiguration?.getShareable(from: transaction) {
            return shareable
        } else {
            return CardTransactionDetailStringBuilder()
                .add(description: description)
                .add(amount: formattedAmount)
                .add(operationDate: operationDate)
                .add(annotationDate: annotationDate)
                .add(bankCharge: bankCharge)
                .build()
        }
    }
}

private extension OldCardTransactionDetailViewModel {
    func formattedOperationDate(date: String, time: String) -> NSAttributedString {
        let font = UIFont.santander(family: .text, type: .regular, size: 14)
        let fullText = time.isEmpty ? date : "\(date) · \(time)"
        return TextStylizer.Builder(fullText: fullText)
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: date).setStyle(font))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: "· \(time)").setStyle(font.withSize(11)))
            .build()
    }
}
