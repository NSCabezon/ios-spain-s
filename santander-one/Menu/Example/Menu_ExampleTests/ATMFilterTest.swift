//
//  ATMFilterTest.swift
//  Menu_ExampleTests
//
//  Created by Juan Carlos López Robles on 11/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import QuickSetup
import CoreTestData
import SANLegacyLibrary

@testable import Menu_Example
@testable import Menu

class ATMFilterTest: XCTestCase {
    var dependenciesEngine = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    
    override func setUp() {
        mockDataInjector.register(
           for: \.appConfigLocalData.getAppConfigLocalData,
           filename: "app_config_v2"
        )
        mockDataInjector.register(
            for: \.branchLocator.getNearATMs,
            filename: "branchLocatorATMDTO"
        )
        self.dependenciesEngine.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        self.dependenciesEngine.register(for: GetNearestAtmsUseCase.self) { resolver in
            return GetNearestAtmsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependenciesEngine.register(for: AppConfigRepositoryProtocol.self) { resolver in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
      
    }
    
    func test_maping_atm_enrichedInfo_service_filters() throws {
        let filters: Set<AtmFilterView.AtmFilter> = [.contactless, .barcode]
        let nearAtms = try? getNearAtmsMock()
        let entity = try XCTUnwrap(nearAtms?.first)
        let viewModel = AtmViewModel(entity)
        let serviceFilters = AtmServiceFilterAdapter(viewModel: viewModel)
        XCTAssertTrue(Array(serviceFilters).count == 0)
        XCTAssertTrue(Set(serviceFilters).isSubset(of: filters))
    }
}

//MDCKS
extension ATMFilterTest {
    func getNearAtmsMock() throws -> [AtmEntity] {
        return try GetNearestAtmsUseCase(dependenciesResolver: self.dependenciesEngine)
            .executeUseCase(requestValues: .init(latitude: 0.0, longitude: 0.0))
            .getOkResult()
            .nearetsAtms
    }
}
