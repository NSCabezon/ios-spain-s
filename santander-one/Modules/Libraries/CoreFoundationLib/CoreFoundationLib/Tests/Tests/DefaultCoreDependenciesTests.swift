//
//  DefaultCoreDependenciesTests.swift
//  CoreFoundationLib-Unit-CoreFoundationLibTests
//
//  Created by José Carlos Estela Anguita on 24/12/21.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import CoreTestData

class DefaultCoreDependenciesTests: XCTestCase {
    
    var repository: ReactivePullOffersRepository!
    var dependencies: Dependencies!
    var coreDependencies: CoreDependencies!
    var mockDataInjector: MockDataInjector!
    
    override func setUpWithError() throws {
        coreDependencies = DefaultCoreDependencies()
        mockDataInjector = MockDataInjector()
        dependencies = Dependencies(coreDependencies: coreDependencies,
                                    mockDataInjector: mockDataInjector)
        repository = dependencies.resolve()
    }

    override func tearDownWithError() throws {
        coreDependencies = nil
        dependencies = nil
        repository = nil
    }

    func test_defaultCoreDependencies_shouldReturnThePreviousDependencyMarkedAsShared_insteadOfTheNewOne() {
        let new = MockPullOffersRespository(mockDataInjector: mockDataInjector)
        let dependency = coreDependencies.asShared { new }
        XCTAssert(dependency !== new)
        XCTAssert(dependency === repository)
    }
}

extension DefaultCoreDependenciesTests {
    struct Dependencies: OffersDependenciesResolver {
        let coreDependencies: CoreDependencies
        let mockDataInjector: MockDataInjector
        
        func resolve() -> CoreDependencies {
            return coreDependencies
        }
        
        func resolve() -> TrackerManager {
            fatalError()
        }
        
        func resolve() -> GlobalPositionRepresentable {
            fatalError()
        }
        
        func resolve() -> GlobalPositionDataRepository {
            asShared {
                MockGlobalPositionDataRepository(mockDataInjector
                        .mockDataProvider
                        .gpData.getGlobalPositionMock)
            }
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
        
        func resolve() -> ReactivePullOffersRepository {
            asShared {
                MockPullOffersRespository(mockDataInjector: mockDataInjector)
            }
        }
    }
}
