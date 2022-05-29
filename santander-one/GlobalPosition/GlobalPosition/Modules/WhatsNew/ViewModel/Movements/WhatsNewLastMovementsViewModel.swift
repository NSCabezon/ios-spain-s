//
//  LastMovementsViewModel.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 15/07/2020.
//

import Foundation
import CoreFoundationLib

enum MovementType {
    case card
    case account
}

public final class WhatsNewLastMovementsViewModel {
    var clickToActionValuesForAccounts: AccountsCTAParameters
    var offers: [PullOfferLocation: OfferEntity]
    var clickToActionValuesForCards: CardsCTAParameters
    var baseUrl: String
    
    private let unreadAccountMovements: [AccountTransactionWithAccountEntity]
    private let unreadCardsMovements: [CardTransactionWithCardEntity]
    private let accountFractionableTransactions: [AccountTransactionWithAccountEntity]
    private let cardFractionableTransactions: [CardTransactionWithCardEntity]
    private var unreadItems: [UnreadMovementItem] = [UnreadMovementItem]()
    private var items: [Date: [UnreadMovementItem]] = [:]
    private var sections: [Date] = [Date]()
    
    public var accountFractionableMovements: [AccountTransactionWithAccountEntity] {
        var fractionableTransactions: [AccountTransactionWithAccountEntity] = []
        accountFractionableTransactions.forEach({ accountTransaction in
            let fundableType = isFundableForAccountTransaction(transaction: accountTransaction)
            if isEasyPayEnabledForAccountTransaction(transaction: accountTransaction, fundableType: fundableType) {
                fractionableTransactions.append(accountTransaction)
            }
        })
        return fractionableTransactions
    }
    
    public var cardFractionableMovements: [CardTransactionWithCardEntity] {
        var fractionableTransactions: [CardTransactionWithCardEntity] = []
        cardFractionableTransactions.forEach({ cardTransaction in
            if isCardTransactionElegibleForFraccionate(transaction: cardTransaction),
                isEasyPayEnabledForCardTransaction(transaction: cardTransaction) {
                fractionableTransactions.append(cardTransaction)
            }
        })
        return fractionableTransactions
    }

    public var totalTransactions: Int {
        unreadItems.count
    }

    public var totalFractionableCards: Int {
        unreadFractionedMovements.cards.count
    }

    public var allCardEntities: Set<CardEntity> {
        let cardEntities = unreadCardsMovements.map({$0.cardEntity})
        return Set(cardEntities)
    }
    
    public var allAccountEntities: Set<AccountEntity> {
        let accountEntities = unreadAccountMovements.map({$0.accountEntity})
        return Set(accountEntities)
    }
    
    public init(useCaseResponse: GetUnreadMovementsUseCaseOkOutput, baseUrl: String) {
        self.baseUrl = baseUrl
        self.unreadAccountMovements = useCaseResponse.accountMovements
        self.unreadCardsMovements = useCaseResponse.cardMovements
        self.clickToActionValuesForCards = useCaseResponse.cardsCrossSellingParameters
        self.clickToActionValuesForAccounts = useCaseResponse.accountsCrossSellingParameters
        self.offers = useCaseResponse.pullOffersOutputCandidates
        self.accountFractionableTransactions = useCaseResponse.accountFractionableMovements
        self.cardFractionableTransactions = useCaseResponse.cardFractionableMovements
    }
    
    public func rebuildModel(firstFourMovements: Bool, fractionableSection: LastMovementsConfiguration.FractionableSection) {
        items.removeAll()
        unreadItems.removeAll()
        sections.removeAll()
        self.buildModel(firstFourMovements: firstFourMovements, fractionableSection: fractionableSection)
    }

    public func rowsAtSection(_ section: Int) -> Int {
        guard section <= sections.count, sections.count > 0 else {
            return 0
        }
        let date = sections[section]
        let item = items[date]
        return item?.count ?? 0
    }
    
    public func itemAtIndexPath(_ indexPath: IndexPath) -> UnreadMovementItem? {
        let bydate = sections[indexPath.section]
        if let item = items[bydate] {
            return item[indexPath.row]
        }
        return nil
    }
    
    public func sectionItemAt(_ index: Int) -> Date? {
        guard index <= sections.count, sections.count > 0 else {
            return nil
        }
        return sections[index]
    }
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func accountTransactionFromItem(_ item: UnreadMovementItem, isFractionable: Bool) -> (accountTransactionsWithAccountEntity: AccountTransactionWithAccountEntity?, transactions: [AccountTransactionWithAccountEntity]?) {
        if isFractionable {
            let query = self.accountFractionableMovements.first(where: {$0.accountTransactionEntity.hashValue == item.movementID})
            let sortedTransactions = self.accountFractionableMovements.sorted(by: { $0.accountTransactionEntity.operationDate ?? Date() > $1.accountTransactionEntity.operationDate ?? Date()})
            return (query, sortedTransactions)
        }
        let query = unreadAccountMovements.first(where: {$0.accountTransactionEntity.hashValue == item.movementID})
        let sortedTransactions = self.unreadAccountMovements.sorted(by: {$0.accountTransactionEntity.operationDate ?? Date() > $1.accountTransactionEntity.operationDate ?? Date()})
        return (query, sortedTransactions)
    }
    
    public func cardTransactionFromItem(_ item: UnreadMovementItem, isFractionable: Bool) -> (cardTransactionsWithAccountEntity: CardTransactionWithCardEntity?, transactions: [CardTransactionWithCardEntity]?) {
        if isFractionable {
            let query = self.cardFractionableMovements.first(where: {$0.cardTransactionEntity.hashValue == item.movementID})
            let sortedTransactions = self.cardFractionableMovements.sorted(by: {$0.cardTransactionEntity.operationDate ?? Date() > $1.cardTransactionEntity.operationDate ?? Date()})
            return (query, sortedTransactions)
        }
        let query = unreadCardsMovements.first(where: {$0.cardTransactionEntity.hashValue == item.movementID})
        let sortedTransactions = self.unreadCardsMovements.sorted(by: {$0.cardTransactionEntity.operationDate ?? Date() > $1.cardTransactionEntity.operationDate ?? Date()})
        return (query, sortedTransactions)
    }
    
    func getCardTransaction(_ item: UnreadMovementItem) -> CardTransactionWithCardEntity? {
        return unreadCardsMovements.first {$0.cardTransactionEntity.hashValue == item.movementID }
    }
    
    func getAccountTransaction(_ item: UnreadMovementItem) -> AccountTransactionWithAccountEntity? {
        return unreadAccountMovements.first { $0.accountTransactionEntity.hashValue == item.movementID }
    }
}

private extension WhatsNewLastMovementsViewModel {
    func buildModel(firstFourMovements: Bool, fractionableSection: LastMovementsConfiguration.FractionableSection) {
        self.loadLastMovements()
        self.loadFractionedPayments(fractionableSection: fractionableSection)
        self.configViewModel(firstFourMovements: firstFourMovements)
    }
    
    // MARK: Methods used in buildModel(_:)
    func loadLastMovements() {
        let cardMovements = self.cardMovements()
        let accountMovements = self.accountMovements()
        unreadItems.append(contentsOf: accountMovements)
        unreadItems.append(contentsOf: cardMovements)
    }
    
    func loadFractionedPayments(fractionableSection: LastMovementsConfiguration.FractionableSection) {
        switch fractionableSection {
        case .fractionableCards:
            let fractionableCardMovements = self.getCardFractionableMovements()
            unreadItems.removeAll()
            unreadItems.append(contentsOf: fractionableCardMovements)
        case .fundableAccounts:
            let fractionableAccountMovements = self.getAccountFractionableMovements()
            unreadItems.removeAll()
            unreadItems.append(contentsOf: fractionableAccountMovements)
        default:
            break
        }
    }
    
    func configViewModel(firstFourMovements: Bool) {
        let sortedUnreadItems = unreadItems.sorted(by: {$0.date ?? Date() > $1.date ?? Date()})
        let movements = firstFourMovements ? sortedUnreadItems.prefix(4).compactMap({$0}) : unreadItems
        // group by dates acounts and cards movements
        let empty: [Date: [UnreadMovementItem]] = [:]
        let groupByDate = movements.reduce(into: empty) { (result, unreadItem) in
            guard let date = unreadItem.date, let cdate = dateGetCurrentLocaleDate(inputDate: date) else {
                return
            }
            let existing = result[cdate] ?? []
            result[cdate] = existing + [unreadItem]
        }
        let orderedSections = groupByDate.keys.sorted(by: {$0 > $1})
        items = groupByDate
        sections = Array(orderedSections)
    }
    
    func cardMovements() -> [UnreadMovementItem] {
        let cardMovements = unreadCardsMovements.map({ cardTransaction -> UnreadMovementItem in
            let unreadItemCrossSelling = UnreadCardItemCrossSellingViewModel(
                cardTransaction: cardTransaction,
                crossSellingParams: clickToActionValuesForCards,
                offers: offers)
            let items = UnreadMovementItem(concept: cardTransaction.cardTransactionEntity.description,
                                           date: cardTransaction.cardTransactionEntity.operationDate,
                                           amount: cardTransaction.cardTransactionEntity.amount,
                                           imageUrl: baseUrl + cardTransaction.cardEntity.buildImageRelativeUrl(miniature: true),
                                           alias: cardTransaction.cardEntity.getAliasCamelCase(),
                                           shortContract: cardTransaction.cardEntity.shortContract,
                                           type: .card,
                                           movementId: cardTransaction.cardTransactionEntity.hashValue,
                                           crossSelling: unreadItemCrossSelling,
                                           isFractional: isFractionableCard(cardTransaction)
            )
            return items
        })
        return cardMovements
    }
    
    func accountMovements() -> [UnreadMovementItem] {
        let accountMovements = unreadAccountMovements.map({ accountTransaction -> UnreadMovementItem in
            let unreadItemCrossSelling = UnreadAccountItemCrossSellingViewModel(
                accountTransaction: accountTransaction,
                crossSellingParams: clickToActionValuesForAccounts,
                offers: offers)
            let items = UnreadMovementItem(
                concept: accountTransaction.accountTransactionEntity.dto.description,
                date: accountTransaction.accountTransactionEntity.operationDate,
                amount: accountTransaction.accountTransactionEntity.amount,
                imageUrl: "icnLogoSanSmall",
                alias: accountTransaction.accountEntity.alias,
                shortContract: accountTransaction.accountEntity.getIBANShort,
                type: .account,
                movementId: accountTransaction.accountTransactionEntity.hashValue,
                crossSelling: unreadItemCrossSelling,
                isFractional: isFractionableAccount(accountTransaction)
            )
            return items
        })
        return accountMovements
    }
    
    func isFractionableAccount(_ transaction: AccountTransactionWithAccountEntity) -> Bool {
        let fundableType = isFundableForAccountTransaction(transaction: transaction)
        return isEasyPayEnabledForAccountTransaction(transaction: transaction, fundableType: fundableType)
    }
    
    func isFractionableCard(_ transaction: CardTransactionWithCardEntity) -> Bool {
        return isEasyPayEnabledForCardTransaction(transaction: transaction)
    }
}

extension WhatsNewLastMovementsViewModel: AccountEasyPayChecker {}
