//
//  PredefinedSCASendMoneyUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by David Gálvez Alonso on 29/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreTestData
import SANLegacyLibrary

@testable import TransferOperatives

class PredefinedSCASendMoneyUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: PredefinedSCASendMoneyUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    
    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
        self.sut = PredefinedSCASendMoneyUseCase(dependenciesResolver: self.dependenciesResolver)
        self.globalPositionMock = self.getGlobalPositionMock()
    }
    
    func test_outputUseCase_showOK() {
        guard let output = try? self.sut.executeUseCase(requestValues: Void()) else {
            return XCTFail()
        }
        XCTAssertTrue(output.isOkResult)
    }
}

extension PredefinedSCASendMoneyUseCaseTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }
    
    func setupDependencies() {
        self.dependenciesResolver.register(for: BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
    }
    
    func getGlobalPositionMock() -> GlobalPositionMock {
        return GlobalPositionMock(
            self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
            cardsData: [:],
            temporallyOffCards: [:],
            inactiveCards: [:],
            cardBalances: [:]
            )
    }
}
