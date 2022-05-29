//
//  GetAllTypesOfTransfersUseCase.swift
//  TransferOperatives
//
//  Created by Juan Diego Vázquez Moreno on 6/10/21.
//

import CoreFoundationLib
import CoreDomain

public protocol GetAllTypesOfTransfersUseCaseProtocol: UseCase<GetAllTypesOfTransfersUseCaseInput, GetAllTypesOfTransfersUseCaseOutput, StringErrorOutput> {}

final class GetAllTypesOfTransfersUseCase: UseCase<GetAllTypesOfTransfersUseCaseInput, GetAllTypesOfTransfersUseCaseOutput, StringErrorOutput>, GetAllTypesOfTransfersUseCaseProtocol {
    private var dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override func executeUseCase(requestValues: GetAllTypesOfTransfersUseCaseInput) throws -> UseCaseResponse<GetAllTypesOfTransfersUseCaseOutput, StringErrorOutput> {
        let manager: TransfersRepository = self.dependenciesResolver.resolve()
        let response = try manager.getAllTransfers(accounts: requestValues.accounts)
        switch response {
        case .success(let data):
            let emittedTransfersOnly = data.filter { $0.typeOfTransfer == .emitted }
            return .ok(GetAllTypesOfTransfersUseCaseOutput(transfers: emittedTransfersOnly))
        case .failure(let error):
            let nsError = error as NSError
            return .error(StringErrorOutput(nsError.localizedDescription))
        }
    }
}

public struct GetAllTypesOfTransfersUseCaseInput {
    public let accounts: [AccountRepresentable]
}

public struct GetAllTypesOfTransfersUseCaseOutput {
    let transfers: [TransferRepresentable]
    
    public init(transfers: [TransferRepresentable]) {
        self.transfers = transfers
    }
}
