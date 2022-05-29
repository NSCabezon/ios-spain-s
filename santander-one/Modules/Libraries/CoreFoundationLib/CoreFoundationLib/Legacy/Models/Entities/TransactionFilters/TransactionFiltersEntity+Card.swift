//
//  TransactionFiltersEntity+Card.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 20/4/22.
//

import Foundation
import CoreDomain

#warning("This should be removed once the new cards home in mvvm has been developed")

/// This is a bridge between the new CardTransactionFiltersRepresentable and the current TransactionFiltersEntity.
extension TransactionFiltersEntity: CardTransactionFiltersRepresentable {}

extension CardTransactionFilterType {
    
    func toActiveFilter() -> ActiveFilters {
        switch self {
        case .byAmount(let amount):
            switch amount {
            case .from(let from):
                return .byAmount(from: stringRepresentation(for: from), limit: nil)
            case .limit(let limit):
                return .byAmount(from: nil, limit: stringRepresentation(for: limit))
            case .range(let from, let limit):
                return .byAmount(from: stringRepresentation(for: from), limit: stringRepresentation(for: limit))
            }
        case .byDate(let date):
            return .byDateRange(DateInterval(initialDate: date.startDate, finalDate: date.endDate))
        case .byConcept(let term):
            return .byDescriptions(term)
        case .byTypeOfMovement(let type):
            switch type {
            case .all:
                return .byCardOperationType(.all)
            case .payment:
                return .byCardOperationType(.payment)
            case .charge:
                return .byCardOperationType(.charge)
        }
        case .byExpenses(let expenses):
            switch expenses {
            case .all:
                return .byConceptType(.all)
            case .expenses:
                return .byConceptType(.expenses)
            case .income:
                return .byConceptType(.income)
            }
        }
    }
    
    func stringRepresentation(for amount: Decimal) -> String? {
        return formatterForRepresentation(.transactionFilters).string(from: NSDecimalNumber(decimal: amount))
    }
}

extension Array where Element == CardTransactionFilterType {
    
    public mutating func remove(filter: ActiveFilters) {
        removeAll(where: {
            switch filter {
            case .byAmount:
                return $0.isByAmount
            case .byCardOperationType:
                return $0.isByTypeOfMovement
            case .byDateRange:
                return $0.isByDate
            case .byDescriptions:
                return $0.isByConcept
            case .custome, .byTransactionType, .byConceptType:
                return false
            }
        })
    }
}

extension CardTransactionFiltersRepresentable {
    
    public func toEntity() -> TransactionFiltersEntity {
        let entity = TransactionFiltersEntity()
        cardFilters.forEach { filter in
            switch filter {
            case .byAmount(let amount):
                switch amount {
                case .from(let from):
                    entity.fromAmount = from
                case .limit(let limit):
                    entity.toAmount = limit
                case .range(from: let from, limit: let limit):
                    entity.fromAmount = from
                    entity.toAmount = limit
                }
            case .byDate(let date):
                entity.addDateFilter(date.startDate, toDate: date.endDate)
                entity.addDateRangeGroupIndex(date.indexRange)
            case .byTypeOfMovement(let movement):
                entity.addCardOperationFilter(movement)
            case .byConcept(let term):
                entity.addDescriptionFilter(term)
            case .byExpenses(let expenses):
                entity.addMovementFilter(expenses)
            }
        }
        
        entity.cardFilters = []
        entity.cardFilters = cardFilters
        
        return entity
    }
}
