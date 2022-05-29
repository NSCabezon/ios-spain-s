//
//  InternalTransferDestinationAccountViewModelTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by Juan Sánchez Marín on 28/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import OpenCombine
import CoreFoundationLib
import CoreTestData
import CoreDomain
import UnitTestCommons

@testable import TransferOperatives

class InternalTransferDestinationAccountViewModelTest: XCTestCase {
    var dependencies: InternalTransferDestinationAccountDependenciesResolver!
    var externalDependencies: InternalTransferDestinationAccountExternalDependenciesResolver!
    private var mockDataInjector = MockDataInjector()
    private var globalPositionMock: GlobalPositionRepresentable!
    private var sut: InternalTransferDestinationAccountViewModel!
    
    override func setUp() {
        defaultRegistration()
        globalPositionMock = self.getGlobalPositionMock()
        externalDependencies = TestInternalTransferDestinationAccountExternalDependencies(accounts: filterAccounts())
        dependencies = TestInternalTransferDestinationAccountDependencies(externalDependencies: externalDependencies)
        sut = InternalTransferDestinationAccountViewModel(dependencies: dependencies)
        setDataBinding()
    }
    
    override func tearDownWithError() throws {
        dependencies = nil
    }
    
    func test_InternalTransferDestinationAccountViewModel_originAccount() throws {
        let publisher = sut.state
            .case(InternalTransferDestinationAccountState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.originAccount)
    }
    
    func test_InternalTransferDestinationAccountViewModel_accounts_load() throws {
        let publisher = sut.state
            .case(InternalTransferDestinationAccountState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssert(result.visibleAccounts.isNotEmpty)
    }
    
    func test_InternalTransferDestinationAccountViewModel_accounts_not_filtered_BecauseCoreDoesntFilterAccounts() throws {
        let publisher = sut.state
            .case(InternalTransferDestinationAccountState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssert(result.visibleAccounts.isNotEmpty)
        XCTAssertFalse(result.showFilteredAccountsMessage)
    }
}

extension InternalTransferDestinationAccountViewModelTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
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
    
    func setDataBinding() {
        let dataBinding: DataBinding = dependencies.resolve()
        let operativeData = InternalTransferOperativeData()
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }
        operativeData.originAccount = accounts[0]
        operativeData.destinationAccountsVisibles = accounts
        dataBinding.set(operativeData)
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
