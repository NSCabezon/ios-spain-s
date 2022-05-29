//
//  TestInternalTransferConfirmationExternalDependenciesResolver.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 16/3/22.
//

import TransferOperatives
import CoreFoundationLib
import CoreTestData
import CoreDomain

struct TestInternalTransferConfirmationExternalDependenciesResolver: InternalTransferConfirmationExternalDependenciesResolver {
    private let mockDataInjector: MockDataInjector
    
    init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func resolve() -> TrackerManager {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> TransfersRepository {
        return MockTransfersRepository(mockDataInjector: mockDataInjector)
    }
    
    func resolve() -> InternalTransferConfirmationUseCase {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        fatalError()
    }
    
    func resolve() -> CurrencyFormatterProvider {
        fatalError()
    }
    
    func resolve() -> InternalTransferConfirmationModifierProtocol {
        fatalError()
    }
}
