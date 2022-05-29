//
//  TestAnalysisAreaProductsConfigurationDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 21/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreTestData
import CoreDomain
@testable import Menu

struct TestAnalysisAreaProductsConfigurationDependenciesResolver: AnalysisAreaProductsConfigurationDependenciesResolver, AnalysisAreaCommonExternalDependenciesResolver {
    func resolve() -> GetCandidateOfferUseCase {
        fatalError()
    }
    
    func resolve() -> AnalysisAreaProductsConfigurationCoordinator {
        fatalError()
    }
    
    func resolve() -> FinancialHealthRepository {
        fatalError()
    }
    
    func otpCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    let injector: MockDataInjector
    let external: AnalysisAreaProductsConfigurationExternalDependenciesResolver
    let setPreferencesUseCaseSpy = SetAnalysisAreaPreferencesUseCaseSpy()
//    let productsConfigurationCoordinatorSpy = AnalysisAreaProductsConfigurationSpy()
    
    init(injector: MockDataInjector, externalDependencies: TestAnalysisAreaProductsConfigurationExternalDependenciesResolver) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
//    func resolve() -> AnalysisAreaProductsConfigurationCoordinator {
//        productsConfigurationCoordinatorSpy
//    }
    
    func resolve() -> GetAnalysisAreaOffersUseCase {
        DefaultGetAnalysisAreaOffersUseCase(dependencies: self)
    }
    
    func resolve() -> SetAnalysisAreaPreferencesUseCase {
        setPreferencesUseCaseSpy
    }
}
