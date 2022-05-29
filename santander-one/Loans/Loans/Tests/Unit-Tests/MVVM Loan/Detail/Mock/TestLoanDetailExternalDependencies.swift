//
//  TestLoanDetailExternalDependencies.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 24/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreTestData
import CoreFoundationLib
import UI
import CoreDomain
@testable import Loans

struct TestLoanDetailExternalDependencies: LoanDetailExternalDependenciesResolver {
    let injector: MockDataInjector
    let getLoanDetailUseCaseSpy = GetLoanDetailUseCaseSpy()
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func resolve() -> TimeManager {
        fatalError()
    }
    
    func resolve() -> LoanReactiveRepository {
        MockLoanRepository(mockDataInjector: injector)
    }
    
    func resolve() -> GetLoanDetailUsecase {
        return self.getLoanDetailUseCaseSpy
    }
    
    func resolve() -> StringLoader {
        return StringLoaderMock()
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
}
