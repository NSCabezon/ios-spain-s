//
//  SpainGetAllTypesOfTransfersUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 10/11/21.
//

import TransferOperatives
import CoreFoundationLib
import SANLegacyLibrary
import Transfer
import CoreDomain

final class SpainGetAllTypesOfTransfersUseCase: UseCase<GetAllTypesOfTransfersUseCaseInput, GetAllTypesOfTransfersUseCaseOutput, StringErrorOutput> {
    
    let dependencies: DependenciesResolver
    var emittedTransfers: EmittedResult?
    var receivedTransfers: ReceivedResult?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAllTypesOfTransfersUseCaseInput) throws -> UseCaseResponse<GetAllTypesOfTransfersUseCaseOutput, StringErrorOutput> {
        guard let accounts = requestValues.accounts as? [AccountDTO] else { return .error(StringErrorOutput(nil))}
        let entities = accounts.map { AccountEntity($0) }
        var emitted: [TransferRepresentable] = []
        let input = GetAllTransfersUseCaseInput(accounts: entities)
        let result = self.retrieveAllTransfers(requestValues: input)
        result.emitted.forEach { key, value in
            let transfers: [TransferEmittedDTO] = value.map { transferEntity in
                var dto = transferEntity.dto
                dto.ibanString = key.getIban()?.ibanString
                return dto
            }
            emitted.append(contentsOf: transfers)
        }
        return .ok(GetAllTypesOfTransfersUseCaseOutput(transfers: emitted))
    }
}

extension SpainGetAllTypesOfTransfersUseCase: GetAllTypesOfTransfersUseCaseProtocol { }
extension SpainGetAllTypesOfTransfersUseCase: AllTransfersRetrieverProtocol { }
