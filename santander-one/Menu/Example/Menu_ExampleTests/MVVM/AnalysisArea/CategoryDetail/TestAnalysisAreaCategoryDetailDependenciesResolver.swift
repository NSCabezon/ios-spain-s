//
//  TestAnalysisAreaCategoryDeatilDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Miguel Bragado Sánchez on 7/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import CoreFoundationLib
import Foundation
import CoreTestData
@testable import Menu

struct TestAnalysisAreaCategoryDetailDependenciesResolver: AnalysisAreaCategoryDetailDependenciesResolver {
    var external: AnalysisAreaCategoryDetailExternalDependenciesResolver
    let injector: MockDataInjector
    
    init(injector: MockDataInjector, externalDependencies: TestAnalysisAreaCategoryDetailExternalDependenciesResolver) {
        self.injector = injector
        self.external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> AnalysisAreaCategoryDetailCoordinator {
        fatalError()
    }
    
    func resolve() -> GetAnalysisAreaCategoryDetailInfoUseCase {
        return DefaultGetAnalysisAreaCategoryUseCase(dependencies: self)
    }
    
    func resolve() -> GetAnalysisAreaTransactionsUseCase {
        return DefaultGetAnalysisAreaTransactionsUseCase(dependencies: self)
    }
}
