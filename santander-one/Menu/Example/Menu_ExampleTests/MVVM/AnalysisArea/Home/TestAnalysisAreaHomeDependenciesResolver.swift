//
//  TestAnalysisAreaHomeDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Luis Escámez Sánchez on 20/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import Menu

struct TestAnalysisAreaHomeDependenciesResolver: AnalysisAreaHomeDependenciesResolver {
    let injector: MockDataInjector
    let external: AnalysisAreaHomeExternalDependenciesResolver
    let summaryUseCaseSpy = GetAnalysisAreaSummaryUseCaseSpy()
//    let productsStatusUseCaseSpy = GetAnalysisAreaProductsStatusUseCaseSpy()
    let homeCoordinatorSpy = AnalysisAreaHomeCoordinatorSpy()

    init(injector: MockDataInjector, externalDependencies: TestAnalysisAreaHomeExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> GetAnalysisAreaSummaryUseCase {
        return self.summaryUseCaseSpy
    }
    
//    func resolve() -> GetAnalysisAreaProductsStatusUseCase {
//        return self.productsStatusUseCaseSpy
//    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> AnalysisAreaCoordinator {
        homeCoordinatorSpy
    }
}
