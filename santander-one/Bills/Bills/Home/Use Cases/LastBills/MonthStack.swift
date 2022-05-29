//
//  MonthStack.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/18/20.
//

import Foundation

final class MonthStack {
    var monthsArray: [Int]

    init(months: Int) {
        self.monthsArray = Array(repeating: 2, count: months / 2)
        guard (months % 2) != 0 else { return }
        self.monthsArray.append(1)
        self.monthsArray.reverse()
    }

    var isEmpty: Bool {
        return self.monthsArray.isEmpty
    }

    var nextMonths: Int {
        return self.monthsArray.popLast() ?? -1
    }
}
