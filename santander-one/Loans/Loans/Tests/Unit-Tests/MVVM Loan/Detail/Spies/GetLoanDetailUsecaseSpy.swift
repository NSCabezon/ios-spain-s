//
//  GetLoanDetailDetailsUsecaseSpy.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 25/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//
import OpenCombine
import Loans
import CoreDomain

class GetLoanDetailUseCaseSpy: GetLoanDetailUsecase {

    var getLoanDetailUseCaseCalled: Bool = false
    
    func fechDetailPublisher(loan: LoanRepresentable) -> AnyPublisher<LoanDetailRepresentable, Error> {
        getLoanDetailUseCaseCalled = true
        return Just(MockLoanDetail()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

}
