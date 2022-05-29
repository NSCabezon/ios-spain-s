//
//  DestinationTypeSendMoneyTransferUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by David Gálvez Alonso on 29/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreTestData
import CoreDomain

@testable import TransferOperatives

class DestinationTypeSendMoneyTransferUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: DestinationTypeSendMoneyTransferUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    private var sepaInfoMock: MockSepaInfoRepository!
    
    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
        self.sut = DestinationTypeSendMoneyTransferUseCase(dependenciesResolver: self.dependenciesResolver)
        self.globalPositionMock = self.getGlobalPositionMock()
        self.sepaInfoMock = MockSepaInfoRepository(mockDataInjector: self.mockDataInjector)
    }
    
    func test_outputUseCase_withAmount_shoul_showOK() {
        self.mockDataInjector.register(
            for: \.transferData.transferType,
            filename: "TransfersTypeMock"
        )
        let allAccounts = globalPositionMock.accounts.map({ $0.representable })
        let sepaInfo = sepaInfoMock.getSepaList()
        guard let account = allAccounts.first,
              let currency = sepaInfo?.allCurrenciesRepresentable.first,
              let country = sepaInfo?.allCountriesRepresentable.first
        else {
            return XCTFail()
        }
        let zeroAmount = AmountRepresented(value: Decimal(2.0),
                                           currencyRepresentable: CurrencyRepresented(currencyCode: currency.code))
        let input = DestinationTypeSendMoneyTransferUseCaseInput(amount: zeroAmount, currencyInfo: currency, countryInfo: country, account: account)
        
        guard let output = try? self.sut.executeUseCase(requestValues: input) else {
            return XCTFail()
        }
        
        XCTAssert(output.isOkResult)
    }
}

extension DestinationTypeSendMoneyTransferUseCaseTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        self.mockDataInjector.register(
            for: \.sepaInfo.getSepaList,
            filename: "getSepaList"
        )
    }
    
    func setupDependencies() {
        self.dependenciesResolver.register(for: TransfersRepository.self) { _ in
            return MockTransfersRepository(mockDataInjector: self.mockDataInjector)
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
