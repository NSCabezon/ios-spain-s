//
//  SendMoneyGetFeesUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 7/3/22.
//

import CoreFoundationLib
import TransferOperatives
import SANSpainLibrary

final class SPSendMoneyGetFeesUseCase: UseCase<Void, Data?, StringErrorOutput>, SendMoneyGetFeesUseCaseProtocol {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Data?, StringErrorOutput> {
        let transferRepository: SpainTransfersRepository = self.dependenciesResolver.resolve()
        let result = try transferRepository.getNoSepaFees()
        switch result {
        case .success(let data):
            return .ok(data)
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}
