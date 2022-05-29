//
//  DeleteOtherBankConnectionSpies.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 25/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Menu
import CoreDomain
import OpenCombine

final class DeleteOtherBankConnectionUseCaseSpy: DeleteOtherBankConnectionUseCase {
    var deleteOtherBankConnectionUseCaseCalled: Bool = false
    
    func fetchFinancialDeleteBankPublisher(bankCode: String) -> AnyPublisher<Void, Error> {
        deleteOtherBankConnectionUseCaseCalled = true
        
        if bankCode.isEmpty {
            return Fail(error: SomeError())
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
}
