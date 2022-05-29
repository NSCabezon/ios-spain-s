//
//  GetRecentTransferDetailUseCase.swift
//  TransferOperatives
//

import CoreFoundationLib
import CoreDomain

public protocol GetRecentTransferDetailUseCaseProtocol: UseCase<GetRecentTransferDetailUseCaseInput, GetRecentTransferDetailUseCaseOutput, DestinationAccountSendMoneyUseCaseErrorOutput> {}

final class GetRecentTransferDetailUseCase: UseCase<GetRecentTransferDetailUseCaseInput, GetRecentTransferDetailUseCaseOutput, DestinationAccountSendMoneyUseCaseErrorOutput>, GetRecentTransferDetailUseCaseProtocol {
    private var dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override func executeUseCase(requestValues: GetRecentTransferDetailUseCaseInput) throws -> UseCaseResponse<GetRecentTransferDetailUseCaseOutput, DestinationAccountSendMoneyUseCaseErrorOutput> {
        let manager: TransfersRepository = self.dependenciesResolver.resolve()
        let response = try manager.getTransferDetail(transfer: requestValues.transfer)
        switch response {
        case .success(let data):
            return .ok(GetRecentTransferDetailUseCaseOutput(transfer: data))
        case .failure(let error):
            let nsError = error as NSError
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.serviceError(errorDesc: nsError.localizedDescription)))
        }
    }
}

public struct GetRecentTransferDetailUseCaseInput {
    public let transfer: TransferRepresentable
}

public struct GetRecentTransferDetailUseCaseOutput {
    public let transfer: TransferRepresentable
}
