//
//  CheckOnlyOneAccountUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by David Gálvez Alonso on 29/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreTestData

@testable import TransferOperatives

class CheckOnlyOneAccountUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: CheckOnlyOneAccountUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    
    override func setUp() {
        self.defaultRegistration()
        self.sut = CheckOnlyOneAccountUseCase()
        self.globalPositionMock = self.getGlobalPositionMock()
    }
    
    func test_outputUseCase_with_visible_account_should_showOK() {
        guard let account = globalPositionMock.accounts.first?.representable,
              let output = try? self.sut.executeUseCase(requestValues: CheckOnlyAccountUseCaseInput(accountVisibles: [account],
                                                                                                    accountNotVisibles: [])).getOkResult() else {
            return XCTFail()
        }
        XCTAssert(output.getIBANShort == account.getIBANShort)
    }
    
    func test_outputUseCase_with_not_visible_account_should_showOK() {
        guard let account = globalPositionMock.accounts.first?.representable,
              let output = try? self.sut.executeUseCase(requestValues: CheckOnlyAccountUseCaseInput(accountVisibles: [],
                                                                                                    accountNotVisibles: [account])).getOkResult() else {
            return XCTFail()
        }
        XCTAssert(output.getIBANShort == account.getIBANShort)
    }
    
    func test_outputUseCase_with_more_than_one_account_should_showOKwithNilValue() {
        guard let account = globalPositionMock.accounts.first?.representable,
              let lastAccount = globalPositionMock.accounts.last?.representable,
              let output = try? self.sut.executeUseCase(requestValues: CheckOnlyAccountUseCaseInput(accountVisibles: [account],
                                                                                                    accountNotVisibles: [lastAccount])) else {
            return XCTFail()
        }
        let okResult = try? output.getOkResult()
        XCTAssert(output.isOkResult && okResult == nil)
    }
}

extension CheckOnlyOneAccountUseCaseTest {
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
}
