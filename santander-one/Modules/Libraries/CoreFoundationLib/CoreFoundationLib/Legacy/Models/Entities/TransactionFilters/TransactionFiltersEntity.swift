//
//  AccountFilterEntity.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 31/01/2020.
//
import CoreDomain

public enum ActiveFilters {
    case byAmount(from: String?, limit: String?)
    case byTransactionType(TransactionOperationTypeEntity)
    case byConceptType(TransactionConceptType)
    case byCardOperationType(CardOperationType)
    case byDateRange(DateInterval)
    case byDescriptions(String)
    case custome(CustomActiveFilterProtocol)
    
    public func literal() -> String {
        switch self {
        case .byAmount(let from, let limit):
            if from != nil && limit != nil {
                return "search_text_sinceUntilAmount"
            } else if from != nil && limit == nil {
                return "search_text_sinceAmount"
            }
            return "search_text_untilAmount"
        case .byTransactionType(let operationType):
            return operationType.descriptionKey
        case .byConceptType(let conceptType):
            return conceptType.descriptionKey
        case .byCardOperationType(let cardOperationType):
            return cardOperationType.descriptionKey
        case .byDateRange(let dateRange):
            return dateRange.keys()
        case .byDescriptions(let descr):
            return descr
        case .custome(let option):
            return option.literal
        }
    }
    
    public func accessibilityIdentifier() -> String {
        switch self {
        case .byAmount:
            return "btnValueRange"
        case .byTransactionType(let operationType):
            return operationType.descriptionKey
        case .byConceptType(let conceptType):
            return conceptType.descriptionKey
        case .byCardOperationType(let cardOperationType):
            return cardOperationType.descriptionKey
        case .byDateRange(let dateRange):
            return dateRange.keys()
        case .byDescriptions:
            return "search_text_description"
        case .custome(let option):
            return option.accessibilityIdentifier
        }
    }
}

extension ActiveFilters: Equatable {
    public static func == (lhs: ActiveFilters, rhs: ActiveFilters) -> Bool {
        switch (lhs, rhs) {
        case (.byAmount(let fromLhs, let limitLhs), byAmount(let fromRhs, let limitRhs)):
            return fromLhs == fromRhs && limitLhs == limitRhs
        case (.byTransactionType(let lhs), .byTransactionType(let rhs)):
            return lhs == rhs
        case (.byConceptType(let lhs), .byConceptType(let rhs)):
            return lhs == rhs
        case (.byCardOperationType(let lhs), .byCardOperationType(let rhs)):
            return lhs == rhs
        case (.byDateRange(let lhs), .byDateRange(let rhs)):
            return lhs == rhs
        case (.byDescriptions(let lhs), .byDescriptions(let rhs)):
            return lhs == rhs
        case (.custome(let lhs), .custome(let rhs)):
            return lhs.literal == rhs.literal && lhs.accessibilityIdentifier == rhs.accessibilityIdentifier
        default:
            return false
        }
    }
}

public enum TransactionOperationTypeEntity: Int, CaseIterable {
    case all = 0
    case checkDeposit
    case checkPayment
    case cashDeposit
    case cashPayment
    case receivedTransfer
    case issuedTransfer
    case severalDocumentCharges
    case receiptsCharges

    public static var allTypes: [TransactionOperationTypeEntity] {
        return [.all, .checkDeposit, .checkPayment, .cashDeposit, .cashPayment, .receivedTransfer, .issuedTransfer, .severalDocumentCharges, .receiptsCharges]
    }
    
    public var descriptionKey: String {
        switch self {
        case .checkDeposit:
            return "search_label_depositChecks"
        case .checkPayment:
            return "search_label_payChecks"
        case .cashDeposit:
            return "search_label_depositCash"
        case .cashPayment:
            return "search_label_PayCash"
        case .receivedTransfer:
            return "search_label_receiveTransfer"
        case .issuedTransfer:
            return "search_label_sentTransfer"
        case .severalDocumentCharges:
            return "search_label_documents"
        case .receiptsCharges:
            return "search_label_bill"
        case .all:
            return "search_label_all"
        }
    }
    
    public var trackName: String {
        switch self {
        case .checkDeposit:
            return "ingreso_cheque"
        case .checkPayment:
            return "pago_cheque"
        case .cashDeposit:
            return "ingreso_efectivo"
        case .cashPayment:
            return "pago_efectivo"
        case .receivedTransfer:
            return "transf_recibidas"
        case .issuedTransfer:
            return "historico_transf"
        case .severalDocumentCharges:
            return "cargo_docu_varios"
        case .receiptsCharges:
            return "cargo_recibos"
        case .all:
            return "todos"
        }
    }
    
    public var identifier: String {
        switch self {
        case .checkDeposit:
            return "search_label_checkDeposit"
        case .checkPayment:
            return "search_label_checkPayment"
        case .cashDeposit:
            return "search_label_cashDeposit"
        case .cashPayment:
            return "search_label_cashPayment"
        case .receivedTransfer:
            return "search_label_receivedTransfer"
        case .issuedTransfer:
            return "search_label_issuedTransfer"
        case .severalDocumentCharges:
            return "search_label_severalDocumentCharges"
        case .receiptsCharges:
            return "search_label_receiptsCharges"
        case .all:
            return "search_label_all"
        }
    }

}

public struct DateInterval: Equatable {
    public let fromDate: Date?
    public let toDate: Date?
    public init(initialDate: Date?, finalDate: Date?) {
        self.fromDate = initialDate
        self.toDate = finalDate
    }
    
    func keys() -> String {
        return "search_text_sinceUntilDate"
    }
}

/**
 Create filters to apply over an transactions within an account
 
 Using a fluent api you can chain filters criteria. Keep in mind that when searching by text criteria others filters are ignored
 
 Example:
 
 let initialDate = timeManager.fromString(input: "26-12-2019", inputFormat: .dd_MM_yyyy)
 let finalDate = timeManager.fromString(input: "01-02-2020", inputFormat: .dd_MM_yyyy)
 let dateCriteria = DateFilterEntity(from: initialDate, to: finalDate)
 
 let filters = AccountFiltersEntity()
 .addDateFilter(dateCriteria)
 .addDateFilter(initialDate, toDate: finalDate)
 */
public final class TransactionFiltersEntity {
    public var fromAmount: Decimal?
    public var toAmount: Decimal?
    /**
     Selected date group
     
        0 - last 7 days
        1 - last 30 days
        2 - last 90 days
        3 -  month
     */
    private var selectedDateRangeGroupIndex: Int?
    private var transactionType: TransactionOperationTypeEntity = .all {
        willSet {
            self.filters.append(.byTransactionType(newValue) )
        }
    }
    private var movementType: TransactionConceptType = .all {
        willSet {
            self.filters.append(.byConceptType(newValue) )
        }
    }
    private var cardOperationType: CardOperationType = .all {
        willSet {
            self.filters.append(.byCardOperationType(newValue))
        }
    }
    private var dateRange: DateInterval? {
        willSet {
            guard let optionalNewValue = newValue else {
                return
            }
            self.filters.append(.byDateRange(optionalNewValue))
        }
    }
    private var transactionDescription: String? {
        willSet {
            self.filters.removeAll()
            self.filters.append(.byDescriptions(newValue ?? ""))
            self.transactionDescription = newValue
        }
    }

    public var filters: [ActiveFilters] = [ActiveFilters]()
    
    public var cardFilters: [CardTransactionFilterType] = [] {
        didSet {
            filters = cardFilters.map { $0.toActiveFilter() }
        }
    }
    
    public init() {}
    
    // MARK: - Filters retrievals
    
    public var fromAmountDecimal: Decimal? {
        return self.fromAmount
    }
    
    public var toAmountDecimal: Decimal? {
        return self.toAmount
    }
    
    public func getMovementType() -> TransactionConceptType {
        return self.movementType
    }
    
    public func getMovementTypeCode() -> String {
        return self.movementType.code
    }
    
    public func getTransactionOperationType() -> TransactionOperationTypeEntity {
        return self.transactionType
    }
    
    public func getTransactionDescription() -> String? {
        return self.transactionDescription
    }
    
    public func getCardOperationType() -> CardOperationType {
        return self.cardOperationType
    }

    public func getDateRange() -> DateInterval? {
        return self.dateRange
    }
    
    public func actives() -> [ActiveFilters] {
        return self.filters
    }
    
    public func getSelectedDateRangeGroupIndex() -> Int {
        return self.selectedDateRangeGroupIndex ?? -1
    }
    
    // MARK: - Filters additions
    @discardableResult public func addTransactionTypeFilter(_ transactionType: TransactionOperationTypeEntity) -> TransactionFiltersEntity {
        self.transactionType = transactionType
        return self
    }
    
    @discardableResult public func addMovementFilter(_ movementType: TransactionConceptType) -> TransactionFiltersEntity {
        self.movementType = movementType
        return self
    }
    
    @discardableResult public func addCardOperationFilter(_ cardOperationType: CardOperationType) -> TransactionFiltersEntity {
        self.cardOperationType = cardOperationType
        return self
    }
    
    @discardableResult public func addDateFilter(_ fromDate: Date?, toDate: Date?) -> TransactionFiltersEntity {
        let dateInterval = DateInterval(initialDate: fromDate, finalDate: toDate)
        self.dateRange = dateInterval
        return self
    }
    
    @discardableResult public func addDateRangeGroupIndex(_ index: Int) -> TransactionFiltersEntity {
        self.selectedDateRangeGroupIndex = index
        return self
    }
    
    /// Setting this filters cause remove all others because search by text are mutually exclusive with others
    /// - Parameter accountDescription: search term
    @discardableResult public func addDescriptionFilter(_ accountDescription: String) -> TransactionFiltersEntity {
        self.transactionDescription = accountDescription
        return self
    }
    
    public func addCustome(_ customOption: CustomActiveFilterProtocol) -> TransactionFiltersEntity {
        self.filters.removeAll()
        self.filters.append(.custome(customOption))
        return self
    }
    
    public func hasCustome() -> Bool {
        self.filters.contains(
            where: { filter in
                guard case .custome = filter else { return false }
                return true
            }
        )
    }
    
    public func getCustome() -> ActiveFilters? {
        return self.filters.first(
            where: { filter in
                guard case .custome = filter else { return false }
                return true
            }
        )
    }
    
    // MARK: - Filters removal
    
    public func removeFilter(_ activeFilter: ActiveFilters) {
        
        self.filters.removeAll(where: { $0 == activeFilter })
        let tempFilters = self.filters
        switch activeFilter {
        case .byConceptType:
            self.movementType = .all
        case .byCardOperationType:
            self.cardOperationType = .all
        case .byAmount:
            self.fromAmount = nil
            self.toAmount = nil
        case .byDescriptions:
            self.transactionDescription = ""
        case .byTransactionType:
            self.transactionType = .all
        case .byDateRange:
            self.dateRange = nil
            self.selectedDateRangeGroupIndex = -1
        case .custome:
            break
        }
        self.cardFilters.remove(filter: activeFilter)
        self.filters = tempFilters
    }
    
    public func containsDescriptionFilter() -> Bool {
        let filterDescription = self.filters.filter { (activeFilter) -> Bool in
            switch activeFilter {
            case .byDescriptions:
                return true
            default:
                return false
            }
        }
        return filterDescription.count > 0
    }
    
    public func removeAllFilters() {
        self.filters.removeAll()
    }
}

extension TransactionFiltersEntity: TransactionFiltersDisposal {}

extension TransactionFiltersEntity: TransactionFiltersRepresentable {
    public var dateInterval: Foundation.DateInterval? {
        guard let dateRange = self.getDateRange(), let fromDate = dateRange.fromDate, let toDate = dateRange.toDate else {
            return Foundation.DateInterval(start: Date().getDate(component: .year(-1)), end: Date())
        }
        return Foundation.DateInterval(start: fromDate, end: toDate)
    }
}

public protocol TransactionFiltersDisposal {
    func removeFilter(_ activeFilter: ActiveFilters)
}
