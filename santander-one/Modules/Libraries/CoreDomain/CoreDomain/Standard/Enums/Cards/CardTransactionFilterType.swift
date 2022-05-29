//
//  CardTransactionFilterType.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 28/4/22.
//

public enum CardTransactionFilterType {
    public enum Amount {
        case from(Decimal)
        case limit(Decimal)
        case range(from: Decimal, limit: Decimal)
    }
    case byAmount(Amount)
    case byTypeOfMovement(CardOperationType)
    case byConcept(String)
    case byDate(CardTransactionFilterDate)
    case byExpenses(TransactionConceptType)
}


public extension CardTransactionFilterType {
    
    var isByAmount: Bool {
        switch self {
        case .byAmount: return true
        default: return false
        }
    }
    
    var isByTypeOfMovement: Bool {
        switch self {
        case .byTypeOfMovement: return true
        default: return false
        }
    }
    
    var isByConcept: Bool {
        switch self {
        case .byConcept: return true
        default: return false
        }
    }
    
    var isByDate: Bool {
        switch self {
        case .byDate: return true
        default: return false
        }
    }
}
