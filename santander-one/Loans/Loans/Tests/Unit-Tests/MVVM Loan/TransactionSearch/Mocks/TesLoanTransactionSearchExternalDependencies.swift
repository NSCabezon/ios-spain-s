//
//  TestLoanTransactionSearchExternalDependencies.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta on 21/3/23.
//
import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import Loans

struct TestLoanTransactionSearchExternalDependencies: LoanTransactionSearchExternalDependenciesResolver {
    
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    let getLoanTransactionSearchConfigUseCaseSpy = GetLoanTransactionSearchConfigUseCaseSpy()

    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    
    func globalSearchCoordinator() -> Coordinator {
        ToastCoordinator()
    }

    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> StringLoader {
        return StringLoaderMock()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> GetLoanTransactionSearchConfigUseCase {
        return getLoanTransactionSearchConfigUseCaseSpy
    }
}
