//
//  GetAllTypesOfTransfersUseCaseTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by David Gálvez Alonso on 30/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreTestData
import CoreDomain

@testable import TransferOperatives

class GetAllTypesOfTransfersUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: GetAllTypesOfTransfersUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    
    override func setUp() {
        self.defaultRegistration()
        self.sut = GetAllTypesOfTransfersUseCase(dependenciesResolver: self.dependenciesResolver)
        self.setupDependencies()
        self.globalPositionMock = self.getGlobalPositionMock()
    }
    
    func test_outputUseCase_should_showOneEmitted() {
        let allAccounts = globalPositionMock.accounts.map({ $0.representable })
        guard let output = try? self.sut.executeUseCase(requestValues: GetAllTypesOfTransfersUseCaseInput(accounts: allAccounts)) else {
            return XCTFail()
        }
        XCTAssert(try output.getOkResult().transfers.first?.typeOfTransfer == .emitted)
    }
}

extension GetAllTypesOfTransfersUseCaseTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        self.mockDataInjector.register(
            for: \.transferData.getEmittedTransfers,
            filename: "TransferEmittedListDTODictMock"
        )
        self.mockDataInjector.register(
            for: \.transferData.loadEmittedTransfers,
            filename: "TransferEmittedListDTOMock"
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
