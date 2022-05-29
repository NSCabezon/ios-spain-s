import Foundation
import CoreFoundationLib
import CoreDomain
import SANLegacyLibrary
import UIKit

final class CardDetail {
    private var baseUrl: String? {
        baseURLProvider.baseURL
    }
    private var textColor: [CardTextColorEntity] {
        dependencies.external.resolve()
    }
    private let cardDetail: CardDetailRepresentable?
    private let dependencies: CardDetailDependenciesResolver
    private var baseURLProvider: BaseURLProvider {
        dependencies.external.resolve()
    }
    private lazy var timeManager: TimeManager = {
        self.dependencies.external.resolve()
    }()
    private let cardHolderNameMaxChars = 26
    
    var cardDetailConfiguration: CardDetailConfiguration?
    var card: CardRepresentable
    var tintColor: UIColor {
        let alpha: CGFloat = self.hasDisabledStyle ? 0.5 : 1.0
        guard let visualCode = self.card.visualCode else {
            return UIColor.white.withAlphaComponent(alpha)
        }
        let visualCodeInPreferences =  self.textColor.contains(where: {$0.cardCode == visualCode})
        return visualCodeInPreferences ? UIColor.black.withAlphaComponent(alpha) : UIColor.white.withAlphaComponent(alpha)
    }
    
    var fullCardImageStringUrl: String? {
        guard let url = baseUrl else { return "" }
        return url + buildImageRelativeUrl()
    }
    
    var isPanMasked: Bool {
        guard let isPanMasked = self.cardDetailConfiguration?.isCardPANMasked else {
            return false
        }
        return isPanMasked
    }
    
    var isChangeAliasEnabled: Bool {
        return cardDetailConfiguration?.cardAliasConfiguration?.isChangeAliasEnabled ?? true
    }
    
    var maxAliasLength: Int? {
        return cardDetailConfiguration?.cardAliasConfiguration?.maxAliasLength
    }
    
    var regExValidatorString: CharacterSet? {
        return cardDetailConfiguration?.cardAliasConfiguration?.regExValidatorString
    }
    
    var pan: String? {
        if isPanMasked {
            return self.maskedPANLabel
        } else {
            guard let plasticCard = cardDetailConfiguration?.cardPAN else { return card.detailUI }
            return plasticCard
        }
    }
    
    var maskedPANLabel: String? {
        guard let lastPanDigits = card.pan?.substring(ofLast: 4) else { return nil }
        let circles = "\u{25CF}\u{25CF}\u{25CF}\u{25CF} \u{25CF}\u{25CF}\u{25CF}\u{25CF} \u{25CF}\u{25CF}\u{25CF}\u{25CF} "
        return circles + lastPanDigits
    }
    
    var expirationDate: String {
        guard let expirationDate = cardDetail?.expirationDate else {
            return ""
        }
        let expirationDateFormatted = timeManager.toString(date: expirationDate,
                                                           outputFormat: .MMyy)
        return expirationDateFormatted ?? ""
    }
    
    var stampedName: String? {
        var owner: String?
        guard let isCardHolderEnabled = self.cardDetailConfiguration?.isCardHolderEnabled, isCardHolderEnabled else {
            return nil
        }
        if let holder = cardDetail?.holder, !holder.isEmpty {
            owner = toCardNameCase(name: holder, maxSize: cardHolderNameMaxChars, permute: true)
        }
        if let stampedName = card.stampedName, !stampedName.isEmpty, owner == nil {
            owner = stampedName.substring(0, min(cardHolderNameMaxChars, stampedName.count))
        }
        if let cardDetail = cardDetail, owner == nil {
            owner = toCardNameCase(name: cardDetail.beneficiary ?? "", maxSize: cardHolderNameMaxChars, permute: true)
        }
        return owner
    }
    
    func getAmountToString(amount: AmountRepresentable?) -> String? {
        let defaultCurrency: CurrencyType = CoreCurrencyDefault.default
        let amountToString = amount ?? AmountDTO(value: 0, currency: .create(defaultCurrency))
        return AmountRepresentableDecorator(amountToString, font: UIFont.santander(size: 10)).getFormatedWithCurrencySymbol()?.string
    }
    
    var creditLimit: String? {
        getAmountToString(amount: cardDetail?.creditLimitAmountRepresentable ?? card.creditLimitAmountRepresentable)
    }
    
    var withdrawnCreditAmount: String? {
        getAmountToString(amount: card.currentBalanceRepresentable )
    }
    
    var monthBalance: AmountRepresentable?
    
    var monthBalanceFormat: String? {
        getAmountToString(amount: self.monthBalance)
    }
    
    var availableBalance: String? {
        getAmountToString(amount: card.availableAmountRepresentable)
    }
    
    var tradeLimit: String? {
        getAmountToString(amount: card.dailyCurrentLimitAmountRepresentable)
    }
    
    var atmLimit: String? {
        getAmountToString(amount: card.atmLimitRepresentable)
    }
    
    var isInactive: Bool {
        return card.inactive ?? false
    }
    
    var shareType: CardDetailShareType = .pan
    
    var hasDisabledStyle: Bool {
        return isInactive || card.isTemporallyOff ?? false  || card.isContractBlocked
    }
    
    init(card: CardRepresentable,
         cardDetail: CardDetailRepresentable?,
         cardDetailConfiguration: CardDetailConfiguration?,
         dependencies: CardDetailDependenciesResolver) {
        self.card = card
        self.cardDetail = cardDetail
        self.cardDetailConfiguration = cardDetailConfiguration
        self.dependencies = dependencies
    }
    
    var products: [CardDetailProduct] {
        let cardDetailElements: [CardDetailDataType] = cardDetailConfiguration?.cardDetailElements ?? []
        let builder = CardDetailBuilder()
        cardDetailElements.forEach { cardDataType in
            switch cardDataType {
            case .pan: builder.addPAN(pan: self.pan, isMasked: self.isPanMasked)
            case .alias: builder.addAlias(alias: self.alias)
            case .description: builder.addDescription(description: self.description)
            case .holder: builder.addHolderName(holderName: self.holderName)
            case .beneficiary: builder.addBeneficiary(beneficiary: self.beneficiary)
            case .linkedAccount: builder.addAccountLinked(accountLinked: self.accountLinked)
            case .paymentModality: builder.addPaymentModality(paymentModality: self.paymentModality, isCreditCard: self.isCreditCard)
            case .situation: builder.addSituation(situation: self.situation)
            case .expirationDate: builder.addExpirationDate(expirationDate: self.expirationDateWithMonth)
            case .status: builder.addStatus(status: self.status)
            case .type: builder.addType(type: self.type)
            case .currency: builder.addCurrency(currency: self.currency)
            case .creditCardAccountNumber: builder.addCreditCardAccountNumber(creditCardAccountNumber: self.creditCardAccountNumber, isMasked: false)
            case .insurance: builder.addInsurance(insurance: self.insurance)
            case .interestRate: builder.addInterestRate(interestRate: self.interestRate)
            case .withholdings: builder.addWithholdings(withholdings: self.withholdings)
            case .previousPeriodInterest: builder.addPreviousPeriodInterest(previousPeriodInterest: self.previousPeriodInterest)
            case .minimumOutstandingDue: builder.addMinimumOutstandingDue(minimumOutstandingDue: self.minimumOutstandingDue)
            case .currentMinimumDue: builder.addCurrentMinimumDue(currentMinimumDue: self.currentMinimumDue)
            case .totalMinimumRepaymentAmount: builder.addTotalMinimumRepaymentAmount(totalMinimumRepaymentAmount: self.totalMinimumRepaymentAmount)
            case .lastStatementDate: builder.addLastStatementDate(lastStatementDate: self.lastStatementDate)
            case .nextStatementDate: builder.addNextStatementDate(nextStatementDate: self.nextStatementDate)
            case .actualPaymentDate: builder.addActualPaymentDate(actualPaymentDate: self.actualPaymentDate)
            }
        }
        return builder.build()
    }
}

private extension CardDetail {
    var alias: String {
        self.card.alias?.camelCasedString ?? " "
    }
    
    var description: String? {
        self.card.description?.camelCasedString
    }
    
    var beneficiary: String? {
        self.cardDetail?.beneficiary?.camelCasedString
    }
    
    var holderName: String? {
        self.cardDetail?.holder?.camelCasedString
        
    }
    
    var accountLinked: String? {
        self.cardDetailConfiguration?.formatLinkedAccount
    }
    
    var paymentModality: String? {
        self.cardDetail?.paymentModality
    }
    
    var situation: String? {
        var stateValue: CardContractStatusType?
        let cardSituation = self.card.situation
        let cardStatus = self.card.cardContractStatusType
        if cardSituation != .other && cardSituation != nil {
            stateValue = cardSituation
        } else if cardStatus != .other && cardStatus != nil {
            stateValue = cardStatus
        }
        switch stateValue {
        case .active:
            return localized("cardDetail_label_statusActive")
        case .blocked:
            return localized("cardDetail_label_statusBlocked")
        default:
            return nil
        }
    }
    
    var status: String? {
        return self.card.statusDescription?.camelCasedString
    }
    
    var type: String? {
        if card.isPrepaidCard {
            return localized("cardDetail_text_ecashCard")
        } else if card.isCreditCard {
            return localized("cardDetail_text_CreditCard")
        } else if card.isDebitCard {
            return localized("cardDetail_text_debitCard")
        }
        return nil
    }
    
    var currency: String? {
        return self.cardDetail?.currency
    }
    
    var creditCardAccountNumber: String? {
        return self.cardDetailConfiguration?.formatLinkeWithCreditCardAccountNumber
    }
    
    var insurance: String? {
        return self.cardDetail?.insurance
    }
    
    var interestRate: String? {
        return self.cardDetail?.interestRate
    }
    
    var withholdings: String? {
        getAmountToString(amount: cardDetail?.withholdingsRepresentable)
    }
    
    var previousPeriodInterest: String? {
        getAmountToString(amount: cardDetail?.previousPeriodInterestRepresentable)
    }
    
    var minimumOutstandingDue: String? {
        getAmountToString(amount: cardDetail?.minimumOutstandingDueRepresentable)
    }
    
    var currentMinimumDue: String? {
        getAmountToString(amount: cardDetail?.currentMinimumDueRepresentable)
    }
    
    var totalMinimumRepaymentAmount: String? {
        getAmountToString(amount: cardDetail?.totalMinimumRepaymentAmountRepresentable)
    }
    
    var lastStatementDate: String? {
        return self.timeManager.toString(date: cardDetail?.lastStatementDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var nextStatementDate: String? {
        return self.timeManager.toString(date: cardDetail?.nextStatementDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var actualPaymentDate: String? {
        return self.timeManager.toString(date: cardDetail?.actualPaymentDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var isCreditCard: Bool {
        self.card.isCreditCard
    }
    
    var expirationDateWithMonth: String? {
        guard let expirationDate = cardDetail?.expirationDate else {
            return nil
        }
        return dateToString(expirationDate)
    }
    
    var visualCode: String? {
        if let visualCode = card.visualCode {
            return visualCode
        }
        return productType+productSubtype
    }
    var productType: String {
        return card.productSubtypeRepresentable?.productType ?? ""
    }
    
    var productSubtype: String {
        return card.productSubtypeRepresentable?.productSubtype ?? ""
    }
    
    func dateToString(_ date: Date) -> String {
        return timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy)?.lowercased() ?? ""
    }
    
    func toCardNameCase(name: String, maxSize: Int, permute: Bool) -> String {
        let text = name.uppercased().trim()
        let tokens = text.split(" ")
        if text.count <= maxSize {
            if tokens.count == 3 {
                return permute ? tokens[2] + " " + tokens[0] + " " + tokens[1] : text
            }
            return text
        }
        let reduced = reduceCardName(name: text)
        if tokens.count == 3 {
            return toCardNameCase(name: reduced, maxSize: maxSize, permute: permute)
        }
        
        if reduced.count >= text.count && reduced.count >= maxSize {
            return reduced.substring(0, maxSize)!
        }
        return toCardNameCase(name: reduced, maxSize: maxSize, permute: false)
    }
    
    func reduceCardName(name: String) -> String {
        var tokens = name.split(" ")
        for index in stride(from: tokens.count - 1, to: 0, by: -1) {
            let token = tokens[index]
            if token.count > 2 {
                tokens[index] = token.substring(0, 1)! + "."
                break
            }
        }
        var result = ""
        for token in tokens {
            result += "\(token) "
        }
        return result.trim()
    }
}

extension CardDetail: Shareable {
    func getShareableInfo() -> String {
        switch self.shareType {
        case .pan:
            return self.pan ?? ""
        case .accountNumber:
            return self.creditCardAccountNumber ?? ""
        }
    }
}

private extension CardDetail {
    func buildImageRelativeUrl() -> String {
        if let visualCode = visualCode {
            return Constants.CardImage.relativeURl
            + (visualCode)
            + Constants.CardImage.fileExtension
        }
        let productType = productType
        let productSubtype = productSubtype
        return Constants.CardImage.relativeURl
        + productType
        + productSubtype
        + Constants.CardImage.fileExtension
    }
}
