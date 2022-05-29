//
//  InternalTransferConfirmationUseCaseTest.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Cristobal Ramos Laina on 15/3/22.
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

class InternalTransferConfirmationUseCaseTest: XCTestCase {
    var dependencies: InternalTransferConfirmationExternalDependenciesResolver!
    private var mockDataInjector = MockDataInjector()
    private var sut: DefaultInternalTransferConfirmationUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    
    override func setUp() {
        self.registrationManyAccounts()
        globalPositionMock = self.getGlobalPositionMock()
        dependencies = TestInternalTransferConfirmationExternalDependenciesResolver(mockDataInjector: mockDataInjector)
        self.sut = DefaultInternalTransferConfirmationUseCase(dependencies: dependencies)
    }
    
    func test_Given_AnyAccount_Then_Success() throws {
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }
        let value = try self.sut.fetchConfirmation(
            input: InternalTransferConfirmationUseCaseInput(
                originAccount: accounts[0],
                destinationAccount: accounts[1],
                name: nil,
                alias: nil,
                debitAmount: AmountRepresented(value: 5, currencyRepresentable: CurrencyRepresented(currencyName: nil, currencyCode: "")),
                creditAmount: AmountRepresented(value: 5, currencyRepresentable: CurrencyRepresented(currencyName: nil, currencyCode: "")),
                concept: nil,
                type: .national,
                time: nil
            )
        ).sinkAwait()
        XCTAssertTrue(value == .success)
    }
}

private extension InternalTransferConfirmationUseCaseTest {
    func registrationManyAccounts() {
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
}

