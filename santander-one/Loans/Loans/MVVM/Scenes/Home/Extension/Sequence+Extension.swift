//
//  Sequence+Extension.swift
//  Account
//
//  Created by Juan Carlos López Robles on 11/2/21.
//

import Foundation

extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        return Dictionary(grouping: self, by: key)
    }
}

extension Dictionary {
    func sort(by sortType: LoanTransactionsSortOrder) -> [(key: Key, value: Value)] where Key: Comparable {
        switch sortType {
        case .mostRecent:
            return self.sorted(by: { $0.key > $1.key })
        case .lessRecent:
            return self.sorted(by: { $0.key < $1.key })
        }
    }
}
