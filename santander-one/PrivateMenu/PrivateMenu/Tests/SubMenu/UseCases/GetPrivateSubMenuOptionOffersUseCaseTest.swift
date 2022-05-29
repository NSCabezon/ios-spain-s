//
//  GetPrivateSubMenuOptionOffersUseCaseTest.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreTestData
@testable import PrivateMenu
import XCTest

class GetPrivateSubMenuOptionOffersUseCaseTest: XCTestCase {
    lazy var dependencies: TestPrivateSubmenuDependencies = {
        let external = TestPrivateSubMenuExternalDependencies(injector: mockDataInjector)
        return TestPrivateSubmenuDependencies(injector: mockDataInjector, externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
        return injector
    }()
    
    func test_When_fetchInsuranceDetailEnabled_Then_insuranceDetailEnabledReturned() throws {
        let sut = DefaultPrivateSubMenuOptionOffersUseCase(dependencies: dependencies)
        
        let offers = try sut.fetchOffersFor(.myProducts).sinkAwait()
        XCTAssertNotNil(offers)
    }
}
