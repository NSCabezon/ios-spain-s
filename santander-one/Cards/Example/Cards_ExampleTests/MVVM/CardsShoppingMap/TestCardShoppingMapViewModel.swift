//
//  TestCardShoppingMapViewModel.swift
//  Cards_ExampleTests
//
//  Created by Hernán Villamil on 25/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import UnitTestCommons
import CoreFoundationLib
import CoreTestData
@testable import Cards

final class TestCardShoppingMapViewModel: XCTestCase {
    lazy var dependencies: TestCardShoppingMapDependencies = {
        setupDependencies()
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestCardShoppingMapDependencies(injector: self.mockDataInjector,
                                               externalDependencies: external)
    }()
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal")
        injector.register(
            for: \.cardsData.getCardMovementLocationListDTO,
               filename: "getCardMovementLocationListMock"
        )
        return injector
    }()
    private let mockCard = MockCard()
}

extension TestCardShoppingMapViewModel {
    func test_get_multiple_card_movements_locations_for_shopping_map_use_case() throws {
        let sut = CardShoppingMapViewModel(dependencies: dependencies)
        let configuration = CardMapConfiguration(type: .multiple,
                                                 card: mockCard)
        dependencies.dataBinding.set(configuration)
        sut.viewDidLoad()
        let publisher = sut.state
            .case { CardShoppingMapState.locationsLoaded }
        let locations = try publisher.sinkAwait()
        XCTAssertFalse(locations.isEmpty)
        XCTAssertTrue(locations.count == 6)
        XCTAssertTrue(locations.first?.alias == "test card")
        XCTAssertTrue(locations.first?.name == "MASSIMO DUTTI")
        XCTAssertTrue(locations.first?.latitude == 41.6484937)
        XCTAssertTrue(locations.first?.longitude == -4.7293842)
        XCTAssertTrue(locations.first?.amountValue == 69.95)
    }
    
    func test_get_dated_card_movements_locations_for_shopping_map_use_case() throws {
        let sut = CardShoppingMapViewModel(dependencies: dependencies)
        let configuration = CardMapConfiguration(type: .date(startDate: Date(), endDate: Date()),
                                                 card: mockCard)
        dependencies.dataBinding.set(configuration)
        sut.viewDidLoad()
        let publisher = sut.state
            .case { CardShoppingMapState.locationsLoaded }
        let locations = try publisher.sinkAwait()
        XCTAssertFalse(locations.isEmpty)
        XCTAssertTrue(locations.count == 3)
        XCTAssertTrue(locations.last?.alias == "test card")
        XCTAssertTrue(locations.last?.name == "LA LONJA DE TORDESILLAS")
        XCTAssertTrue(locations.last?.latitude == 41.5026436)
        XCTAssertTrue(locations.last?.longitude == -4.9965524)
        XCTAssertTrue(locations.last?.amountValue == 69.88)
    }
    
    func test_get_one_card_movement_location_for_shopping_map_use_case() throws {
        let sut = CardShoppingMapViewModel(dependencies: dependencies)
        let amount = AmountEntity(value: 69.95)
        let location = CardMapItem(date: Date(),
                                            name: "MASSIMO DUTTI",
                                            alias: nil,
                                            amount: amount,
                                            address: "Calle de Santiago",
                                            postalCode: "47001",
                                            location: "Valladolid",
                                            latitude: 41.6484937,
                                            longitude: -4.7293842,
                                            amountValue: 69.95,
                                            totalValues: 1)
        let configuration = CardMapConfiguration(type: .one(location: location),
                                                 card: mockCard)
        dependencies.dataBinding.set(configuration)
        sut.viewDidLoad()
        let publisher = sut.state
            .case { CardShoppingMapState.locationsLoaded }
        let locations = try publisher.sinkAwait()
        XCTAssertFalse(locations.isEmpty)
        XCTAssertTrue(locations.count == 1)
        XCTAssertTrue(locations.first?.name == "MASSIMO DUTTI")
        XCTAssertTrue(locations.first?.latitude == 41.6484937)
        XCTAssertTrue(locations.first?.longitude == -4.7293842)
        XCTAssertTrue(locations.first?.amountValue == 69.95)
        
    }
}

extension TestCardShoppingMapViewModel: RegisterCommonDependenciesProtocol {
    var dependenciesResolver: DependenciesDefault {
        DependenciesDefault()
    }
}
