//
//  PiggyBankAccountTest.swift
//  ExampleAppTests
//
//  Created by Ignacio González Miró on 4/12/20.
//  Copyright © 2020 Jose Carlos Estela Anguita. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import CoreTestData
import SANLegacyLibrary
@testable import GlobalPosition

final class PiggyBankAccountTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let mockDataInjector = MockDataInjector()
    private var globalPosition: GlobalPositionRepresentable?

    override func setUp() {
        self.setupTest()
    }
    
    override func tearDown() {
    }

    func test_accountsInPgs_withUserWithPiggyBankAccounts_shouldLoadsPiggyBankAccountsInPgs() {
        guard let globalPosition = self.globalPosition else {
            return XCTFail("Error: Couldn't load GlobalPosition")
        }
        let piggyBankAccounts = globalPosition.accounts.filter({ $0.isPiggyBankAccount })
        XCTAssertTrue(!piggyBankAccounts.isEmpty, "Error: Global position doesn't contains accounts with PiggyBank Type")
    }
}

private extension PiggyBankAccountTest {
    func setupTest() {
        dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            self.mockDataInjector.register(
                for: \.gpData.getGlobalPositionMock,
                filename: "obtenerPosGlobal"
            )
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        self.setGlobalPosition()
    }

    func setGlobalPosition() {
        self.globalPosition = dependencies.resolve(for: GlobalPositionRepresentable.self)
    }
}
