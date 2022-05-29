//
//  GetLoanDetailConfigUseCaseTest.swift
//  ExampleAppTests
//
//  Created by Juan Jose Acosta González on 28/2/22.
//  Copyright © 2022 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreTestData
import XCTest
@testable import Loans

class GetLoanDetailConfigUseCaseTest: XCTestCase {
    lazy var dependencies: TestLoanDetailDependencies = {
        let external = TestLoanDetailExternalDependencies(injector: mockDataInjector)
        return TestLoanDetailDependencies(injector: mockDataInjector, externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_Given_DefaultUseCase_When_FetchConfiguration_Then_AliasIsNeededIsEnabled() throws {
        let sut = DefaultGetLoanDetailConfigUseCase(dependencies: dependencies)
        
        let config = try sut.fetchConfiguration().sinkAwait()
        XCTAssert(config.aliasIsNeeded == true)
    }
    
    func test_Given_DefaultUseCase_When_FetchConfiguration_Then_LastOperationDateIsDisabled() throws {
        let sut = DefaultGetLoanDetailConfigUseCase(dependencies: dependencies)
        
        let config = try sut.fetchConfiguration().sinkAwait()
        XCTAssert(config.isEnabledLastOperationDate == false)
    }
}
