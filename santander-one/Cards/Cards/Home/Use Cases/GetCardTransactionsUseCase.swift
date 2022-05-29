import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain
import Foundation

class GetCardTransactionsUseCase: UseCase<GetCardTransactionsUseCaseInput, GetCardTransactionsUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private var provider: BSANManagersProvider {
        return dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    private var pfmHelper: PfmHelperProtocol {
        return dependenciesResolver.resolve(for: PfmHelperProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetCardTransactionsUseCaseInput) throws -> UseCaseResponse<GetCardTransactionsUseCaseOkOutput, StringErrorOutput> {
        let userId = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self).userCodeType ?? ""
        let pagination = requestValues.pagination?.dto
        guard requestValues.filters != nil, let filters = requestValues.filters else {
            if requestValues.isEnabledPFM {
                return try getPFMCardTransactions(userID: userId, card: requestValues.card)
            } else {
                return try getCardTransactions(cardDTO: requestValues.card.dto, filters: nil, pagination: pagination)
            }
        }
        if requestValues.isEnabledPFM, let searchTerm = filters.getTransactionDescription(), !searchTerm.isEmpty {
            return try getPFMCardTransations(userID: userId, card: requestValues.card, filters: filters, pagination: pagination, isEnabledPFM: requestValues.isEnabledPFM)
        } else if filters.getDateRange() != nil {
            return try getCardTransactions(cardDTO: requestValues.card.dto, filters: filters, pagination: pagination)
        } else if filters.fromAmount != nil && filters.toAmount != nil {
            return try getCardTransactions(cardDTO: requestValues.card.dto, filters: filters, pagination: pagination)
        } else if filters.getCardOperationType() != .all {
            return try getCardTransactions(cardDTO: requestValues.card.dto, filters: filters, pagination: pagination)
        } else if filters.getMovementType() != .all {
            return try getCardTransactions(cardDTO: requestValues.card.dto, filters: filters, pagination: pagination)
        } else {
            return try getPFMCardTransations(userID: userId, card: requestValues.card, filters: filters, pagination: pagination, isEnabledPFM: requestValues.isEnabledPFM)
        }
    }
    
    func filterByMovementType(_ transactions: [CardTransactionEntityProtocol], cardOperationType: CardOperationType) -> CardTransactionsListEntity {
        switch cardOperationType {
        case .payment:
            return CardTransactionsListEntity(transactions: transactions.filter { $0.amount?.value?.isSignMinus ?? false })
        case .charge:
            return CardTransactionsListEntity(transactions: transactions.filter { !($0.amount?.value?.isSignMinus ?? false) })
        case .all:
            return CardTransactionsListEntity(transactions: transactions)
        }
    }
}

private extension GetCardTransactionsUseCase {
    func getCardTransactions(cardDTO: CardDTO, filters: TransactionFiltersEntity?, pagination: PaginationDTO?) throws -> UseCaseResponse<GetCardTransactionsUseCaseOkOutput, StringErrorOutput> {
        
        if let dates = filters?.getDateRange() {
            return try getAllCardTransactions(cardDTO: cardDTO,
                                              pagination: pagination,
                                              searchTerm: filters?.getTransactionDescription(),
                                              dateFilter: DateFilter(from: dates.fromDate, to: dates.toDate),
                                              fromAmount: filters?.fromAmount,
                                              toAmount: filters?.toAmount,
                                              movementType: filters?.getMovementType(),
                                              cardOperationType: filters?.getCardOperationType())
        } else if filters != nil {
            return try getAllCardTransactions(cardDTO: cardDTO,
                                              pagination: pagination,
                                              searchTerm: filters?.getTransactionDescription(),
                                              dateFilter: nil,
                                              fromAmount: filters?.fromAmount,
                                              toAmount: filters?.toAmount,
                                              movementType: filters?.getMovementType(),
                                              cardOperationType: filters?.getCardOperationType())
        } else {
            return try getAllCardTransactions(cardDTO: cardDTO, pagination: pagination, dateFilter: nil, cardOperationType: filters?.getCardOperationType())
        }
    }
    
    func getAllCardTransactions(cardDTO: CardDTO, pagination: PaginationDTO?, searchTerm: String? = nil, dateFilter: DateFilter?, fromAmount: Decimal? = nil, toAmount: Decimal? = nil, movementType: TransactionConceptType? = nil, cardOperationType: CardOperationType? = nil) throws -> UseCaseResponse<GetCardTransactionsUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = provider.getBsanCardsManager()
        let response = try cardsManager.getAllCardTransactions(cardDTO: cardDTO,
                                                               pagination: pagination,
                                                               searchTerm: searchTerm,
                                                               dateFilter: dateFilter,
                                                               fromAmount: fromAmount,
                                                               toAmount: toAmount,
                                                               movementType: getMovementType(movementType),
                                                               cardOperationType: getCardOperationType(cardOperationType))
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(StringErrorOutput(errorMessage))
        }
        let transactions = dto.transactionDTOs.compactMap({
            return CardTransactionEntity($0)
        })
        guard let cardOperationType = cardOperationType,
              cardOperationType != .all else {
            let transactionsList = CardTransactionsListEntity(transactions: transactions, pagination: PaginationEntity(dto.pagination))
            return UseCaseResponse.ok(GetCardTransactionsUseCaseOkOutput(transactionList: transactionsList))
        }
        let transactionList = self.filterByMovementType(transactions, cardOperationType: cardOperationType)
        return UseCaseResponse.ok(GetCardTransactionsUseCaseOkOutput(transactionList: transactionList))
    }
        
    func getPFMCardTransations(userID: String, card: CardEntity, filters: TransactionFiltersEntity?, pagination: PaginationDTO?, isEnabledPFM: Bool) throws -> UseCaseResponse<GetCardTransactionsUseCaseOkOutput, StringErrorOutput> {
        guard isEnabledPFM else {
            return try getCardTransactions(cardDTO: card.dto, filters: filters, pagination: pagination)
        }
        guard let filters = filters else {
            return try getPFMCardTransactions(userID: userID, card: card)
        }
        var cardTransactions: [CardTransactionEntity] = []
        if let searchTerm = filters.getTransactionDescription(), !searchTerm.isEmpty {
            let dateInterval = filters.getDateRange()
            let date = Date().getDateByAdding(days: -89, ignoreHours: true)
            let intervalFromDate = dateInterval?.fromDate ?? date
            let fromDate = intervalFromDate > date ? intervalFromDate : date
            cardTransactions = pfmHelper.getLastMovementsFor(userId: userID, card: card, searchText: searchTerm, fromDate: fromDate, toDate: dateInterval?.toDate)
        } else if let dates = filters.getDateRange(), let fromDate = dates.fromDate, let toDate = dates.toDate {
            cardTransactions = pfmHelper.getLastMovementsFor(userId: userID, card: card, startDate: fromDate, endDate: toDate)
        }
        let transactionList = self.filterByMovementType(cardTransactions, cardOperationType: filters.getCardOperationType())
        return UseCaseResponse.ok(GetCardTransactionsUseCaseOkOutput(transactionList: transactionList))
    }
    
    func getPFMCardTransactions(userID: String, card: CardEntity) throws -> UseCaseResponse<GetCardTransactionsUseCaseOkOutput, StringErrorOutput> {
        let cardTransactions = pfmHelper.getLastMovementsFor(userId: userID, card: card)
        let transactionList = CardTransactionsListEntity(transactions: cardTransactions)
        return UseCaseResponse.ok(GetCardTransactionsUseCaseOkOutput(transactionList: transactionList))
    }
    
    private func getMovementType(_ movementType: TransactionConceptType? = nil) -> String? {
        if let movementType = movementType {
            switch movementType {
            case .income:
                return  "CREDIT"
            case .expenses:
                 return "DEBIT"
            default:
                return nil
            }
        }
        return nil
    }
    
    private func getCardOperationType(_ cardOperationType: CardOperationType?) -> String? {
        if let cardOperationType = cardOperationType {
            switch cardOperationType {
            case .charge:
                return "CREDIT"
            case .payment:
                 return "DEBIT"
            default:
                 return nil
            }
        }
        return nil
    }
}

struct GetCardTransactionsUseCaseInput {
    let card: CardEntity
    let filters: TransactionFiltersEntity?
    let pagination: PaginationEntity?
    let isEnabledPFM: Bool
}

struct GetCardTransactionsUseCaseOkOutput {
    let transactionList: CardTransactionsListEntity
}
