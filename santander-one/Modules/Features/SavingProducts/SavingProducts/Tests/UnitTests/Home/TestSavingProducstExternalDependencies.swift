//
//  TestSavingProductsExternalDependencies.swift
//  SavingProducts-Unit-Tests
//
//  Created by Adrian Escriche Martin on 4/4/22.
//

import UI
import Foundation
import CoreDomain
import CoreTestData
import CoreFoundationLib
import OpenCombine
@testable import SavingProducts

struct TestSavingProductsExternalDependencies: SavingsHomeExternalDependenciesResolver {
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    
    init(injector: MockDataInjector){
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    
    func resolve() -> GlobalPositionDataRepository {
        globalPositionRepository
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> SavingTransactionsRepository {
        MockSavingTransactionsRepository(getSavingProductTransactions: injector.mockDataProvider.savingProductsData.getSavingProductTransactions)
    }
    
    func resolve() -> GetSavingProductComplementaryDataUseCase {
        MockGetSavingProductComplementaryDataUseCase()
    }
    
    func resolve() -> GetSavingProductOptionsUseCase {
        MockGetSavingProductOptionsUseCase()
    }
    
    func resolve() -> TimeManager {
        MockTimeManager()
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        ToastCoordinator()
    }

    func resolve() -> StringLoader {
        return StringLoaderMock()
    }

    func resolveSavingsShowPDFCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }

    func savingDetailCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
}
