//
//  SortCriteria.swift
//  Commons
//
//  Created by Tania Castellano Brasero on 22/04/2020.
//

import Foundation

final public class SortingCriteria {
    // MARK: - Sorting auxiliary methods
    public static func datesAreDifferent(dateA: Date?, dateB: Date?) -> Bool {
        let firstDate = dateA ?? Date()
        let secondDate = dateB ?? Date()
        return firstDate != secondDate
    }
    
    public static func sortByDate(dateA: Date?, dateB: Date?, order: ComparisonResult) -> Bool {
        let firstDate = dateA ?? Date()
        let secondDate = dateB ?? Date()
        return firstDate.compare(secondDate) == order
    }
    
    public static func ibanNumbersAreDifferent(firstAccount: AccountEntity, secondAccount: AccountEntity) -> Bool {
        let firstIban = firstAccount.getIban()?.ibanString ?? firstAccount.getIBANShort
        let secondIban = secondAccount.getIban()?.ibanString ?? secondAccount.getIBANShort
        return firstIban != secondIban
    }
    
    public static func panNumbersAreDifferent(panA: String, panB: String) -> Bool {
        return panA != panB
    }
    
    public static func sortByPAN(panA: String, panB: String) -> Bool {
        return panA < panB
    }
        
    public static func sortByIBAN(firstAccount: AccountEntity, secondAccount: AccountEntity) -> Bool {
        let firstIban = firstAccount.getIban()?.ibanString ?? firstAccount.getIBANShort
        let secondIban = secondAccount.getIban()?.ibanString ?? secondAccount.getIBANShort
        return firstIban < secondIban
    }
    
    public static func sortByAmount(firstAmount: Decimal?, secondAmount: Decimal?) -> Bool {
        let firstDecimal = firstAmount ?? 0.0
        let secondDecimal = secondAmount ?? 0.0
        return firstDecimal > secondDecimal
    }
    
    public static func order<T, Value: Comparable>(elems: [T], by keyPath: KeyPath<T, Value>, limit: Int) -> [T] {
        return Array(elems.sorted {
            $0[keyPath: keyPath] > $1[keyPath: keyPath]
        }.prefix(limit))
    }
}
