//
//  TestAnalysisAreaDeleteOtherBankConnectionDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 24/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreTestData
@testable import Menu

struct TestAnalysisAreaDeleteOtherBankConnectionDependenciesResolver: DeleteOtherBankConnectionDependenciesResolver {
    let injector: MockDataInjector
    let external: DeleteOtherBankConnectionExternalDependenciesResolver
    let deleteOtherBankConnectionUseCase: DeleteOtherBankConnectionUseCaseSpy
    
    init(injector: MockDataInjector, externalDependencies: TestExternalDependencies) {
        self.injector = injector
        self.external = externalDependencies
        self.deleteOtherBankConnectionUseCase = DeleteOtherBankConnectionUseCaseSpy()
    }
    
    func resolve() -> DataBinding {
        DataBindingObject()
    }
    
    func resolve() -> DeleteOtherBankConnectionCoordinator {
        fatalError()
    }
    
    func resolve() -> DeleteOtherBankConnectionUseCase {
        self.deleteOtherBankConnectionUseCase
    }
}
