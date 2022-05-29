//
//  TestAnalysisAreaHomeExternalDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Luis Escámez Sánchez on 20/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import QuickSetup
import CoreTestData
@testable import Menu

struct TestAnalysisAreaHomeExternalDependencies: AnalysisAreaHomeExternalDependenciesResolver, AnalysisAreaCommonExternalDependenciesResolver {
    func offersCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        fatalError()
    }
    
    func otpCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    let injector: MockDataInjector
    let companiesUseCaseSpy = GetAnalysisAreaCompaniesWithProductsUseCaseSpy()
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func timeSelectorCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func productsConfigurationCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func categoryDetailCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "")
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
    
    func resolve() -> UserSessionFinancialHealthRepository {
        MockUserSessionFinancialHealthRepository(mockDataInjector: self.injector)
    }
    
    func resolve() -> FinancialHealthRepository {
        MockFinancialHealthRepository(mockDataInjector: self.injector)
    }
    
    func resolve() -> GetAnalysisAreaCompaniesWithProductsUseCase {
        companiesUseCaseSpy
    }
}
