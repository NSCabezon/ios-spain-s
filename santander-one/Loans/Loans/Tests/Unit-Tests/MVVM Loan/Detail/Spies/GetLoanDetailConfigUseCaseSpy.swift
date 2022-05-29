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

class GetLoanDetailConfigUseCaseSpy: GetLoanDetailConfigUseCase {
    var getLoanDetailConfigUseCaseCalled: Bool = false
    
    func fetchConfiguration() -> AnyPublisher<LoanDetailConfigRepresentable, Never> {
        getLoanDetailConfigUseCaseCalled = true
        return Just(MockLoanDetailConfig()).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}
