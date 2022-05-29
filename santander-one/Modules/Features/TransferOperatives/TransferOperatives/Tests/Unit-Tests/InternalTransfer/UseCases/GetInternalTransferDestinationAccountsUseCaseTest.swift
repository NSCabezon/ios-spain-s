//
//  GetInternalTransferDestinationAccountsUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by Carlos Monfort Gómez on 1/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreDomain
import CoreFoundationLib
import UnitTestCommons
@testable import TransferOperatives

class GetInternalTransferDestinationAccountsUseCaseTest: XCTestCase {
    private var mockDataInjector: MockDataInjector!
    private var globalPositionMock: GlobalPositionRepresentable!
    private var useCase: DefaultGetInternalTransferDestinationAccountsUseCase!

    override func setUp() {
        mockDataInjector = MockDataInjector()
        useCase = DefaultGetInternalTransferDestinationAccountsUseCase()
    }

    func test_Given_ThereIsAnOriginAccount_When_FilterInputVisibleAccounts_Then_VisibleAccountsDontHaveThisAccount() throws {
        // Given
        let visibleAccounts = getVisibleAccounts()
        let notVisibleAccounts = getNotVisibleAccounts()
        let originAccount = getOriginAccount(from: visibleAccounts)
        
        // When
        let input = GetInternalTransferDestinationAccountsInput(visibleAccounts: visibleAccounts,
                                                                notVisibleAccounts: notVisibleAccounts,
                                                                originAccount: originAccount)
        let output = try useCase.fetchAccounts(input: input).sinkAwait()
        
        // Then
        let isOriginAccountInVisible = output.visibleAccounts.contains { $0.equalsTo(other: originAccount) }
        XCTAssertFalse(isOriginAccountInVisible)
    }
    
    func test_Given_ThereIsAnOriginAccount_When_FilterInputNotVisibleAccounts_Then_NotVisibleAccountsDontHaveThisAccount() throws {
        // Given
        let visibleAccounts = getVisibleAccounts()
        let notVisibleAccounts = getNotVisibleAccounts()
        let originAccount = getOriginAccount(from: notVisibleAccounts)
        
        // When
        let input = GetInternalTransferDestinationAccountsInput(visibleAccounts: visibleAccounts,
                                                                notVisibleAccounts: notVisibleAccounts,
                                                                originAccount: originAccount)
        let output = try useCase.fetchAccounts(input: input).sinkAwait()
        
        // Then
        let isOriginAccountInNotVisible = output.notVisibleAccounts.contains { $0.equalsTo(other: originAccount) }
        XCTAssertFalse(isOriginAccountInNotVisible)
    }
}

private extension GetInternalTransferDestinationAccountsUseCaseTest {
    func registerVisibleAccounts() {
        self.mockDataInjector.register(
            for: \.accountData.getAllAccountsMock,
            filename: "getVisibleAccounts"
        )
    }
    
    func registerNotVisibleAccounts() {
        self.mockDataInjector.register(
            for: \.accountData.getAllAccountsMock,
            filename: "getNotVisibleAccounts"
        )
    }
    
    func getVisibleAccounts() -> [AccountRepresentable] {
        registerVisibleAccounts()
        let accounts: [AccountRepresentable] = mockDataInjector.mockDataProvider.accountData.getAllAccountsMock.map {
            AccountEntity($0).representable
        }
        return accounts
    }
    
    func getNotVisibleAccounts() -> [AccountRepresentable] {
        registerNotVisibleAccounts()
        let accounts: [AccountRepresentable] = mockDataInjector.mockDataProvider.accountData.getAllAccountsMock.map {
            AccountEntity($0).representable
        }
        return accounts
    }
    
    func getOriginAccount(from accounts: [AccountRepresentable]) -> AccountRepresentable {
        return accounts.randomElement()!
    }
}
