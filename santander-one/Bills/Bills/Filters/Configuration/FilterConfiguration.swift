//
//  FilterConfiguration.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation

final class FilterConfiguration {
    let filter: BillFilter?
    
    init(filter: BillFilter?) {
        self.filter = filter
    }
}
