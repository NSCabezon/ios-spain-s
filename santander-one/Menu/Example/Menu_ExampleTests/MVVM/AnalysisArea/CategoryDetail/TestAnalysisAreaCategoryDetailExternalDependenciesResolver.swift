//
//  TestAnalysisAreaCategoryDetailExternalDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Miguel Bragado Sánchez on 7/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import QuickSetup
import CoreTestData
@testable import Menu

struct TestAnalysisAreaCategoryDetailExternalDependenciesResolver: AnalysisAreaCategoryDetailExternalDependenciesResolver {
    func resolve() -> BaseURLProvider {
        fatalError()
    }
    
    func movementsFilterCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        fatalError()
    }
    
    func otpCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    let injector: MockDataInjector
    init (injector: MockDataInjector) {
        self.injector = injector
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> FinancialHealthRepository {
        MockFinancialHealthRepository(mockDataInjector: self.injector)
    }
}
