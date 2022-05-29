//
//  AnalysisAreaDeleteOtherBankConnectionViewModelTests.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 24/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import Menu

final class AnalysisAreaDeleteOtherBankConnectionViewModelTests: XCTestCase {
    private lazy var dependencies: TestAnalysisAreaDeleteOtherBankConnectionDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestAnalysisAreaDeleteOtherBankConnectionDependenciesResolver(injector: self.mockDataInjector, externalDependencies: external)
    }()
    private lazy var mockDataInjector: MockDataInjector = {
        MockDataInjector()
    }()
    
    private var mockDeleteBankInput = "0049"
    
    func test_When_didTapDeleteOtherBankConnection_Then_DeleteOtherBankConnectionIsCalled() throws {
        let sut = DeleteOtherBankConnectionViewModel(dependencies: dependencies)
        
        let trigger = {
            sut.viewDidLoad()
            sut.didTapDeleteOtherBankConnection(self.mockDeleteBankInput)
        }
        
        _ = try sut.state
            .case(DeleteOtherBankConnectionState.isDeleteStatus)
            .sinkAwait(beforeWait: trigger)
        
        XCTAssertTrue(self.dependencies.deleteOtherBankConnectionUseCase.deleteOtherBankConnectionUseCaseCalled)
    }
}
