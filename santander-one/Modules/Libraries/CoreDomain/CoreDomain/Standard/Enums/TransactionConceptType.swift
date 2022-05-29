//
//  TransactionConceptType.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 26/4/22.
//

public enum TransactionConceptType: Int, Codable, CaseIterable {
    case all = 0
    case expenses
    case income

    init?(_ type: Int) {
        self.init(rawValue: type)
    }

    public var code: String {
        switch self {
        case .all:
            return ""
        case .expenses:
            return "D"
        case .income:
            return "H"
        }
    }
    
    public static var allTypes: [TransactionConceptType] {
           return [.all, .expenses, .income]
    }
    
    public var descriptionKey: String {
        switch self {
        case .all:
            return "search_tab_all"
        case .expenses:
            return "search_tab_expenses"
        case .income:
            return "search_tab_deposit"
        }
    }
    
    public var trackName: String {
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
