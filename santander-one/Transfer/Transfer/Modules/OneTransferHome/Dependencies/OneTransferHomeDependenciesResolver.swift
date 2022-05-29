//
//  SceneDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 3/12/21.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI

protocol OneTransferHomeDependenciesResolver {
    var external: OneTransferHomeExternalDependenciesResolver { get }
    func resolve() -> OneTransferHomeViewController
    func resolve() -> OneTransferHomeCoordinator
    func resolve() -> DataBinding
    func resolve() -> OneTransferHomeViewModel
    func resolve() -> GetOneFaqsUseCase
    func resolve() -> GetCandidateOfferUseCase
}

extension OneTransferHomeDependenciesResolver {
    func resolve() -> OneTransferHomeViewController {
        return OneTransferHomeViewController(dependencies: self)
    }
    
    func resolve() -> OneTransferHomeViewModel {
        return OneTransferHomeViewModel(dependencies: self)
    }
    
    func resolve() -> GetOneFaqsUseCase {
        return external.resolve()
    }

    func resolve() -> GetCandidateOfferUseCase {
        return external.resolve()
    }
}
