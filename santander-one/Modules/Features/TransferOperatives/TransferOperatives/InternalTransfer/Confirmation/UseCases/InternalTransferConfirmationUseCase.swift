//
//  InternalTransferConfirmationUseCase.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 2/3/22.
//

import Foundation
import OpenCombine
import CoreDomain
import SANLegacyLibrary
import CoreFoundationLib
import Operative

public protocol InternalTransferConfirmationUseCase {
    
    func fetchConfirmation(input: InternalTransferConfirmationUseCaseInput) -> AnyPublisher<ConditionState, Error>
}

struct DefaultInternalTransferConfirmationUseCase {
    let transferRepository: TransfersRepository
    
    init(dependencies: InternalTransferConfirmationExternalDependenciesResolver) {
        self.transferRepository = dependencies.resolve()
    }
}

extension DefaultInternalTransferConfirmationUseCase: InternalTransferConfirmationUseCase {
    func fetchConfirmation(input: InternalTransferConfirmationUseCaseInput) -> AnyPublisher<ConditionState, Error> {
        return Just(ConditionState.success).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

public struct InternalTransferConfirmationUseCaseInput {
    public let originAccount: AccountRepresentable
    public let destinationAccount: AccountRepresentable
    public let name: String?
    public let alias: String?
    public let debitAmount: AmountRepresentable
    public let creditAmount: AmountRepresentable
    public let concept: String?
    public let type: OnePayTransferType
    public let time: Date?
}
