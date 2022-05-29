//
//  GetUserCommercialSegmentUseCaseTest.swift
//  Menu_ExampleTests
//
//  Created by alvola on 24/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Menu

class GetUserCommercialSegmentUseCaseTest: XCTestCase {

    private lazy var dependencies: TestPublicMenuDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestPublicMenuDependenciesResolver(externalDependencies: external)
    }()

    private lazy var mockDataInjector: MockDataInjector = {
        return MockDataInjector()
    }()
    
    private lazy var menuRepository: PublicMenuRepository = {
        return PublicMenuRepositoryMock()
    }()
    
    func test_When_ThereAreNotCommercialSegmentInfo_Expect_commertialSegmentOptionRemoved() throws {
        dependencies.external = TestExternalDependencies(injector: self.mockDataInjector)
        self.mockDataInjector.register(for: \.commercialSegment,
                                       element: MockSegmentedUserRepository(mockDataInjector: self.mockDataInjector))
        let sut = DefaultGetUserCommercialSegmentUseCase(dependencies: dependencies)
        let elems = try menuRepository.getPublicMenuConfiguration().sinkAwait()
        
        let newElems = try sut.filterUserCommercialSegmentElem(elems).sinkAwait()
        let containsCommercialSegment = newElems.contains { conf in
            conf.contains { $0.top?.kindOfNode == .commercialSegment || $0.bottom?.kindOfNode == .commercialSegment }
        }
        XCTAssert(containsCommercialSegment == false)
    }
    
    func test_When_ThereAreCommercialSegmentInfo_Expect_commertialSegmentOptionAppears() throws {
        dependencies.external = TestExternalDependencies(injector: self.mockDataInjector)
        self.mockDataInjector.register(for: \.commercialSegment,
                                       element: MockSegmentedUserRepository(mockDataInjector: self.mockDataInjector,
                                                                            .fraudNumbers(phones: ["987654321"])))
        let sut = DefaultGetUserCommercialSegmentUseCase(dependencies: dependencies)
        let elems = try menuRepository.getPublicMenuConfiguration().sinkAwait()
        
        let newElems = try sut.filterUserCommercialSegmentElem(elems).sinkAwait()
        let containsCommercialSegment = newElems.contains { conf in
            conf.contains { $0.top?.kindOfNode == .commercialSegment || $0.bottom?.kindOfNode == .commercialSegment }
        }
        XCTAssert(containsCommercialSegment == true)
    }
}
