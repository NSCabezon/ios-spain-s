//
//  PreSetupSendMoneyUseCaseTest.swift
//  Transfer_ExampleTests
//
//  Created by David Gálvez Alonso on 2/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import QuickSetup
import UI
import CoreTestData
import SANLegacyLibrary

@testable import TransferOperatives
@testable import Transfer

class PreSetupSendMoneyUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: PreSetupSendMoneyUseCase!
    
    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
        self.sut = PreSetupSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    func test_outputUseCase_should_showErrorToNotVisibleAccounts() {
        guard let output = try? self.sut.executeUseCase(requestValues: Void()),
              let error = try? output.getErrorResult() else {
            return XCTFail()
        }
        XCTAssert(error.getErrorDesc() == StringErrorOutput(nil).getErrorDesc())
    }
}

private extension PreSetupSendMoneyUseCaseTest {
    
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
        self.dependenciesResolver.register(for: FaqsRepositoryProtocol.self) { _ in
            return FaqsRepository()
        }
        self.dependenciesResolver.register(for: SepaInfoRepositoryProtocol.self) { _ in
            return MockSepaInfoRepository(mockDataInjector: self.mockDataInjector)
        }
    }
}
