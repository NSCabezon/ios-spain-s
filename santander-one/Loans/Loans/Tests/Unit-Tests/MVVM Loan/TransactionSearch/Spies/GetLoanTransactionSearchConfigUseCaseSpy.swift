//
//  GetLoanDetailConfigUseCaseSpy.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 25/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import OpenCombine
import CoreDomain
import Loans

class GetLoanTransactionSearchConfigUseCaseSpy: GetLoanTransactionSearchConfigUseCase {
    var getLoanTransactionSearchConfigUseCaseCalled: Bool = false
    
    func fetchConfiguration() -> AnyPublisher<LoanTransactionSearchConfigRepresentable, Never> {
        getLoanTransactionSearchConfigUseCaseCalled = true
        return Just(MockLoanTransactionSearchConfig()).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}
