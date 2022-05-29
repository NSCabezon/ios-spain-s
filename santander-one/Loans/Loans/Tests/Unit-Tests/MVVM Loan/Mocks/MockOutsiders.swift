//
//  Outsiders.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 11/6/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//

import Foundation
import Loans
import OpenCombine

struct MockLoanFilterOutsider: LoanFilterOutsider {
    func send(_ filters: LoanFilterRepresentable) {}
    
    var publisher: AnyPublisher<[LoanFilterRepresentable], Never> {
        return Just([]).eraseToAnyPublisher()
    }
    
    func send(_ filters: [LoanFilterRepresentable]) {
    }
}
