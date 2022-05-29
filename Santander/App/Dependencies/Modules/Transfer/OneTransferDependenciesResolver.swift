//
//  OneTransferHomeExternalDependenciesResolver.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 24/12/21.
//

import CoreFoundationLib
import CoreDomain
import Transfer
import UI

extension ModuleDependencies: TransferExternalDependenciesResolver {
    func resolve() -> FaqsRepositoryProtocol {
        oldResolver.resolve()
    }
    
    func resolve() -> TransfersRepository {
        oldResolver.resolve()
    }
    
    func resolve() -> GetSendMoneyActionsUseCase {
        return SpainGetSendMoneyActionsUseCase(candidateOfferUseCase: resolve())
    }
    
    func resolve() -> GetAllTransfersReactiveUseCase {
        return SPGetAllTransfersReactiveUseCase(dependencies: self)
    }
    
    func resolveCustomSendMoneyActionCoordinator() -> BindableCoordinator {
        return SpainOneTransferHomeActionsCoordinator(dependencies: resolve())
    }
    
    func resolve() -> GlobalPositionRepresentable {
        return oldResolver.resolve()
    }
}
