//
//  GetRecentTransferDetailUseCaseTest.swift
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

class GetRecentTransferDetailUseCaseTest: XCTestCase {
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var sut: GetRecentTransferDetailUseCase!
    private var globalPositionMock: GlobalPositionRepresentable!
    private var transferRepositoryMock: MockTransfersRepository!
    
    override func setUp() {
        self.defaultRegistration()
        self.setupDependencies()
        self.sut = GetRecentTransferDetailUseCase(dependenciesResolver: self.dependenciesResolver)
        self.globalPositionMock = self.getGlobalPositionMock()
        self.transferRepositoryMock = MockTransfersRepository(mockDataInjector: self.mockDataInjector)
    }
    
    func test_outputUseCase_with_transfer_should_showDetailTransfer() {
        let accounts = globalPositionMock.accounts.map { $0.representable }
        guard let transfers = try? transferRepositoryMock.getAllTransfers(accounts: accounts).get(),
              let transfer = transfers.first,
              let output = try? self.sut.executeUseCase(requestValues:
                                                            GetRecentTransferDetailUseCaseInput(transfer:  transfer)).getOkResult() else {
            return XCTFail()
        }
        XCTAssert(output.transfer.typeOfTransfer != nil)
    }
}

extension GetRecentTransferDetailUseCaseTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        self.mockDataInjector.register(
            for: \.transferData.loadEmittedTransfers,
            filename: "TransferEmittedListDTOMock"
        )
        self.mockDataInjector.register(
            for: \.transferData.getEmittedTransferDetail,
            filename: "TransferEmittedDetailDTOMock"
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
