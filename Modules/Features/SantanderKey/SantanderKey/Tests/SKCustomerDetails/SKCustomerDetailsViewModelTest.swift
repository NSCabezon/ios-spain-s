//
//  SKCustomerDetailsViewModelTest.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 18/4/22.
//

import UnitTestCommons
import XCTest
import CoreTestData

@testable import SantanderKey

class SKCustomerDetailsViewModelTest: XCTestCase {
    
    lazy var external: TestSKCustomerDetailsExternalDependencies = {
        return TestSKCustomerDetailsExternalDependencies(injector: mockDataInjector)
    }()

    lazy var dependencies: TestSKCustomerDetailsDependencies = {
        return TestSKCustomerDetailsDependencies(external: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.faqs.getFaqsList,
               filename: "getFaqsList")
        return injector
    }()
    
    private var sut: SKCustomerDetailsViewModel!
    
    override func setUp() {
        setDataBinding()
        self.sut = SKCustomerDetailsViewModel(dependencies: dependencies)
    }
    
    func test_Given_viewDidLoad_When_faqsLoadedStateIsCalled_Then_faqsIsNotNil() throws {
        let publisher = sut.state
            .case(SKCustomerDetailsState.faqsLoaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.faqs)
    }
    
    func test_Given_viewDidLoad_When_faqsLoadedStateIsCalled_Then_faqsIsNotZero() throws {
        let publisher = sut.state
            .case(SKCustomerDetailsState.faqsLoaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssert(result.faqs.count > 0)
    }
    
    func test_Given_viewDidLoad_When_detailResultStateIsCalled_Then_resultIsNotError() throws {
        let publisher = sut.state
            .case(SKCustomerDetailsState.didReceiveDetailResult)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssert(result.accessInfoTitleKey != SKCustomerDetailsDeviceInfoType.error.accessInfoTitleKey)
    }
}

extension SKCustomerDetailsViewModelTest {
    func setDataBinding() {
        
    }
}
