//
//  AtmSheetContentBuilderTest.swift
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

@testable import CoreFoundationLib
@testable import UI
@testable import Menu

class AtmSheetContentBuilderTest: XCTestCase {
    var depependenciesEngine = DependenciesDefault()
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
        self.depependenciesEngine.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        self.depependenciesEngine.register(for: GetNearestAtmsUseCase.self) { resolver in
            return GetNearestAtmsUseCase(dependenciesResolver: resolver)
        }
        self.depependenciesEngine.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.depependenciesEngine.register(for: AppConfigRepositoryProtocol.self) { resolver in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
    }
    
    func test_add_atm_detail_sheetView_views() throws {
        let nearAtms = try? getNearAtmsMock()
        let entity = try XCTUnwrap(nearAtms?.first)
        let viewModel = AtmViewModel(entity)
        let builder = AtmSheetContentBuilder(viewModel: viewModel)
        let subviews = builder.build().stackView.subviews
        let atmMachineView = subviews.first { $0 is AtmMachineView }
    
        XCTAssertNotNil(atmMachineView)
    }
    
    func test_add_atm_detail_sheetView_views_without_atmEnrichedInfo() throws {
        let nearAtms = try? getNearAtmsMock()
        let atmDto = try XCTUnwrap(nearAtms?.first?.dto)
        let entity = AtmEntity(dto: atmDto, enrichedDto: nil)
        let viewModel = AtmViewModel(entity)
        let builder = AtmSheetContentBuilder(viewModel: viewModel)
        let subviews = builder.build().stackView.subviews
        let atmMachineView = subviews.first { $0 is AtmMachineView }
        let serviceView = subviews.first { $0 is AtmServicesView }
        let atmCashTypeView = subviews.first { $0 is AtmCashType }
        XCTAssertNotNil(atmMachineView)
        XCTAssertNil(atmCashTypeView)
        XCTAssertNil(serviceView)
    }
}

//MOCKS
extension AtmSheetContentBuilderTest {
    func getNearAtmsMock() throws -> [AtmEntity] {
        return try GetNearestAtmsUseCase(dependenciesResolver: self.depependenciesEngine)
            .executeUseCase(requestValues: .init(latitude: 0.0, longitude: 0.0))
            .getOkResult()
            .nearetsAtms
    }
}
