//
//  CardOperationType.swift
//  CoreDomain
//
//  Created by Gloria Cano López on 28/4/22.
//

import Foundation

public enum CardOperationType: Int, Codable, CaseIterable {
    case all = 0
    case payment
    case charge
    
    init?(_ type: Int) {
        self.init(rawValue: type)
    }
    
    public static var allTypes: [CardOperationType] {
        return [.all, .payment, .charge]
    }
    
    public var descriptionKey: String {
        switch self {
        case .all:
            return "search_tab_all"
        case .payment:
            return "search_label_amount"
        case .charge:
            return "search_label_payment"
        }
    }
    
    public var trackName: String {
        switch self {
        case .all:
            return "todos"
        case .payment:
            return "abono"
        case .charge:
            return "cargo"
        }
    }
}
