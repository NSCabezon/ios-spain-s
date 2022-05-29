//
//  DetailFilter.swift
//  Menu
//
//  Created by David Gálvez Alonso on 07/07/2021.
//

import Foundation
import CoreFoundationLib

final class DetailFilter {
    private var subcategory: String?
    private var timeFilter: TimePeriodTotalAmountFilterViewModel?
    private var filters: [ActiveFilters] = [ActiveFilters]()
    private var fromAmount: Decimal?
    private var toAmount: Decimal?
    
    init() { }
    
    init(cloning detailFilter: DetailFilter) {
        self.subcategory = detailFilter.subcategory
        self.filters = detailFilter.filters
        self.fromAmount = detailFilter.fromAmount
        self.toAmount = detailFilter.toAmount
        self.movementType = detailFilter.getMovementType()
        self.transactionDescription = detailFilter.getTransactionDescription()
    }
    
    private var transactionDescription: String? {
        willSet {
            self.filters.removeAll()
            self.filters.append(.byDescriptions(newValue ?? ""))
            self.transactionDescription = newValue
        }
    }
    private var movementType: DetailFilterConceptType = .all {
        willSet {
            self.filters.append(.byConceptType(newValue) )
        }
    }
    
    func getTransactionDescription() -> String? {
        return self.transactionDescription
    }
    
    func getMovementType() -> DetailFilterConceptType {
        return self.movementType
    }
    
    func getSubcategory() -> String? {
        return self.subcategory
    }
    
    func setSubcategory(_ subcategory: String?) {
        self.subcategory = subcategory
    }
    
    func getTimeFilter() -> TimePeriodTotalAmountFilterViewModel? {
        return self.timeFilter
    }
    
    func setTimeFilter(_ filter: TimePeriodTotalAmountFilterViewModel) {
        self.timeFilter = filter
    }
    
    var fromAmountDecimal: Decimal? {
        return self.fromAmount
    }
    
    var toAmountDecimal: Decimal? {
        return self.toAmount
    }
    
    func addDescriptionFilter(_ accountDescription: String) {
        self.transactionDescription = accountDescription
    }
    
    func addMovementFilter(_ movementType: DetailFilterConceptType) {
        self.movementType = movementType
    }
    
    func addAmountFilter(_ fromAmount: Decimal?, toAmount: Decimal?) {
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        var fromAmountString: String?
        var toAmountString: String?
        if let famount = self.fromAmount, let fromAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: famount)) {
            fromAmountString = fromAmountStr
        }
        if let tamount = self.toAmount, let toAmountStr = formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: tamount)) {
            toAmountString = toAmountStr
        }
        self.filters.append(.byAmount(from: fromAmountString, limit: toAmountString))
    }
    
    func actives() -> [ActiveFilters] {
        return self.filters
    }
    
    func removeFilter(_ filter: ActiveFilters) {
        self.filters.removeAll(where: { $0 == filter })
        let temp = self.filters
        switch filter {
        case .byAmount:
            self.fromAmount = 0
            self.toAmount = 0
        case .byDescriptions:
            self.transactionDescription = nil
        case .byConceptType:
            self.movementType = .all
        }
        self.filters = temp
    }
}

extension ActiveFilters: Equatable {
    public static func == (lhs: ActiveFilters, rhs: ActiveFilters) -> Bool {
        switch (lhs, rhs) {
        case (.byAmount(let fromLhs, let limitLhs), byAmount(let fromRhs, let limitRhs)):
            return fromLhs == fromRhs && limitLhs == limitRhs
        case (.byConceptType(let lhs), .byConceptType(let rhs)):
            return lhs == rhs
        case (.byDescriptions(let lhs), .byDescriptions(let rhs)):
            return lhs == rhs
        default: return false
        }
    }
}

enum DetailFilterConceptType: Int, CaseIterable {
    case all = 0
    case expenses
    case income
    
    var descriptionKey: String {
        switch self {
        case .all:
            return "search_tab_all"
        case .expenses:
            return "search_tab_expenses"
        case .income:
            return "search_tab_deposit"
        }
    }
    
    var trackName: String {
        switch self {
        case .all:
            return "todos"
        case .expenses:
            return "gastos"
        case .income:
            return "ingresos"
        }
    }
}

enum ActiveFilters {
    case byAmount(from: String?, limit: String?)
    case byConceptType(DetailFilterConceptType)
    case byDescriptions(String)
    
    func literal() -> String {
        switch self {
        case .byAmount(let from, let limit):
            if from != nil && limit != nil {
                return "search_text_sinceUntilAmount"
            } else if from != nil && limit == nil {
                return "search_text_sinceAmount"
            }
            return "search_text_untilAmount"
        case .byConceptType(let conceptType):
            return conceptType.descriptionKey
        case .byDescriptions(let descr):
            return descr
        }
    }
    
    func accessibilityIdentifier() -> String {
        switch self {
        case .byAmount:
            return "btnValueRange"
        case .byConceptType(let conceptType):
            return conceptType.descriptionKey
        case .byDescriptions(let descr):
            return descr
        }
    }
}
