//
//  PreSetupInternalTransferUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by Cristobal Ramos Laina on 22/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreFoundationLib
import UI
import SANLegacyLibrary
import OpenCombine
import UnitTestCommons
import CoreDomain

@testable import TransferOperatives

class PreSetupInternalTransferUseCaseTest: XCTestCase {
    var dependencies: InternalTransferOperativeExternalDependenciesResolver!
    private var mockDataInjector = MockDataInjector()
    private var sut: DefaultInternalTransferPreSetupUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    
    override func setUp() {
        self.registrationManyAccounts()
        globalPositionMock = self.getGlobalPositionMock()
        dependencies = TestInternalTransferOperativeExternalDependencies(accounts: filterAccounts())
        self.sut = DefaultInternalTransferPreSetupUseCase(dependencies: dependencies)
    }
    
    func test_Given_NoneAccount_Then_showError() {
        let value = self.sut.isMinimunAccounts(accounts: [])
        XCTAssertFalse(value)
    }
    
    func test_Given_ManyAccounts_Then_success() {
        self.registrationManyAccounts()
        globalPositionMock = self.getGlobalPositionMock()
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }
        let value = self.sut.isMinimunAccounts(accounts: accounts)
        XCTAssertTrue(value)
    }
    
    func test_Given_OneAccount_Then_showError() {
        self.registrationOneAccount()
        globalPositionMock = self.getGlobalPositionMock()
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }
        let value = self.sut.isMinimunAccounts(accounts: accounts)
        XCTAssertFalse(value)
    }
}

private extension PreSetupInternalTransferUseCaseTest {
    
    func registrationManyAccounts() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }
    
    func registrationOneAccount() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobalUnaCuenta"
        )
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
    
    func filterAccounts() -> [AccountRepresentable] {
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }.dropLast()
        var filteredAccounts = [AccountRepresentable]()
        filteredAccounts.append(contentsOf: accounts)
        return filteredAccounts
    }
}

