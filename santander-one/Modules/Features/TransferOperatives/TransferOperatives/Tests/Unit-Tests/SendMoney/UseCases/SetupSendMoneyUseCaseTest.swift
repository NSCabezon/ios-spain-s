//
//  SetupSendMoneyUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by David Gálvez Alonso on 29/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreFoundationLib
import UI
import SANLegacyLibrary

@testable import TransferOperatives

class SetupSendMoneyUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: SetupSendMoneyUseCase!
    
    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
        self.sut = SetupSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    func test_outputUseCase_should_show_OkResult() {
        guard let output = try? self.sut.executeUseCase(requestValues: Void()) else {
            return XCTFail()
        }
        XCTAssert(output.isOkResult)
    }
}

private extension SetupSendMoneyUseCaseTest {
    
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }

    func setupDependencies() {
        self.dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        self.dependenciesResolver.register(for: BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        self.dependenciesResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: resolver.resolve(), saveUserPreferences: false)
        }
        self.dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependenciesResolver.register(for: AppConfigRepositoryProtocol.self) { _ in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
    }
}
