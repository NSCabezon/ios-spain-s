//
//  GetAllTransfersUseCase.swift
//  Transfer
//
//  Created by alvola on 18/05/2020.
//

import SANLegacyLibrary
import CoreFoundationLib
import TransferOperatives
import Transfer

final class GetAllTransfersUseCase: UseCase<GetAllTransfersUseCaseInput, (EmittedResult, ReceivedResult), StringErrorOutput> {
    
    let dependencies: DependenciesResolver
    var emittedTransfers: EmittedResult?
    var receivedTransfers: ReceivedResult?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAllTransfersUseCaseInput) throws -> UseCaseResponse<(EmittedResult, ReceivedResult), StringErrorOutput> {
        let allTransfers = self.retrieveAllTransfers(requestValues: requestValues)
        return .ok(allTransfers)
    }
}

extension GetAllTransfersUseCase: GetAllTransfersUseCaseProtocol { }
extension GetAllTransfersUseCase: AllTransfersRetrieverProtocol { }
