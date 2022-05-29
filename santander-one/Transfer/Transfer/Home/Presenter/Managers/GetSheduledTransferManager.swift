//
//  GetScheduledTransfersManager.swift
//  Transfer
//
//  Created by Alvaro Royo on 20/5/21.
//

import CoreFoundationLib
import SANLegacyLibrary

public protocol GetScheduledTransferUseCaseProtocol: UseCase<GetScheduledTransferUseCaseInput,
                                                             ScheduledTransferDetailEntity,
                                                             StringErrorOutput> {}

final class GetScheduledTransfersManager {

    private let dependenciesResolver: DependenciesResolver
    
    private var getScheduledTransferUseCase: GetScheduledTransferUseCaseProtocol? {
        dependenciesResolver.resolve(forOptionalType: GetScheduledTransferUseCaseProtocol.self)
    }
    
    private lazy var getScheduledTransferUseCaseNational: GetScheduledTransferDetailUseCase = {
        GetScheduledTransferDetailUseCase(dependenciesResolver: self.dependenciesResolver)
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func getScheduledTransferDetail(input: GetScheduledTransferDetailUseCaseInput, _ completion: @escaping (ScheduledTransferDetailEntity?, StringErrorOutput?) -> Void) {
        if getScheduledTransferUseCase != nil,
           let identifier = input.scheduledTransferId {
            return executeOtherCountryUseCase(input: GetScheduledTransferUseCaseInput(transferId: identifier,
                                                                                      accountId: input.account.getIban()?.ibanString ?? ""),
                                              completion)
        } else {
            return executeNationalUseCase(input: input, completion)
        }
    }
}

private extension GetScheduledTransfersManager {
    func executeNationalUseCase(input: GetScheduledTransferDetailUseCaseInput, _ completion: @escaping (ScheduledTransferDetailEntity?, StringErrorOutput?) -> Void) {
        Scenario(useCase: getScheduledTransferUseCaseNational, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { result in
                completion(result.scheduledTransferDetail, nil)
            }
            .onError { error in
                completion(nil, StringErrorOutput(error.getErrorDesc()))
            }
    }
    
    func executeOtherCountryUseCase(input: GetScheduledTransferUseCaseInput, _ completion: @escaping (ScheduledTransferDetailEntity?, StringErrorOutput?) -> Void) {
        guard let getScheduledTransferUseCase = getScheduledTransferUseCase
        else { return completion(nil, nil) }
        Scenario(useCase: getScheduledTransferUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { result in
                completion(result, nil)
            }
            .onError { error in
                completion(nil, StringErrorOutput(error.getErrorDesc()))
            }
    }
}
