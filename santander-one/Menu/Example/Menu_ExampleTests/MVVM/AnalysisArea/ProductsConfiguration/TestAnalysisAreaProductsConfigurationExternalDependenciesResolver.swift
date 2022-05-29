//
//  TestAnalysisAreaProductsConfigurationExternalDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 21/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import QuickSetup
import CoreTestData
import SANLegacyLibrary
@testable import Menu

struct TestAnalysisAreaProductsConfigurationExternalDependenciesResolver: AnalysisAreaProductsConfigurationExternalDependenciesResolver, AnalysisAreaCommonExternalDependenciesResolver {
    func otpCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    let injector: MockDataInjector
    let companiesUseCase = GetAnalysisAreaCompaniesWithProductsUseCaseSpy()
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func offersCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func deleteOtherBankConnectionCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        BaseURLProvider(baseURL: "")
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        DefaultGetCandidateOfferUseCase(dependenciesResolver: Dependencies())
    }
    
    func resolve() -> FinancialHealthRepository {
        MockFinancialHealthRepository(mockDataInjector: self.injector)
    }
    
    func resolve() -> GetAnalysisAreaCompaniesWithProductsUseCase {
        companiesUseCase
    }
}

extension TestAnalysisAreaProductsConfigurationExternalDependenciesResolver {
    struct Dependencies: OffersDependenciesResolver, GlobalPositionDependenciesResolver {
        func resolve() -> AppRepositoryProtocol {
            fatalError()
        }
        
        func resolve() -> BSANManagersProvider {
            fatalError()
        }
        
        func resolve() -> CoreDependencies {
            DefaultCoreDependencies()
        }
        
        func resolve() -> TrackerManager {
            fatalError()
        }
        
        func resolve() -> GlobalPositionRepresentable {
            fatalError()
        }
        
        func resolve() -> GlobalPositionDataRepository {
            DefaultGlobalPositionDataRepository(dependencies: self)
        }
        
        func resolve() -> PullOffersConfigRepositoryProtocol {
            fatalError()
        }
        
        func resolve() -> PullOffersInterpreter {
            fatalError()
        }
        
        func resolve() -> ReactivePullOffersInterpreter {
            fatalError()
        }
        
        func resolve() -> EngineInterface {
            fatalError()
        }
    }
}
