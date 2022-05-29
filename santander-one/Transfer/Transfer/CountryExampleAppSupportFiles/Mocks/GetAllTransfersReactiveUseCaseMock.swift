//
//  GetAllTransfersReactiveUseCaseMock.swift
//  Transfer
//
//  Created by Francisco del Real Escudero on 25/1/22.
//

import CoreTestData
import OpenCombine
import CoreDomain

public struct GetAllTransfersReactiveUseCaseMock {
    private let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
}

extension GetAllTransfersReactiveUseCaseMock: GetAllTransfersReactiveUseCase {
    public func fetchTransfers() -> AnyPublisher<GetAllTransfersReactiveUseCaseOutput, Never> {
        return Just(GetAllTransfersReactiveUseCaseOutput(
            emitted: mockDataInjector.mockDataProvider.transferData.loadEmittedTransfers.transactionDTOs,
            received: mockDataInjector.mockDataProvider.transferData.getAccountTransactions.transactionDTOs
        ))
            .eraseToAnyPublisher()
    }
}
