 //
//  CardTransactionDetailExternalDependenciesResolver.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

 import UI
 import Foundation
 import OpenCombine
 import CoreDomain
 import CoreFoundationLib

public protocol CardTransactionDetailExternalDependenciesResolver: NavigationBarExternalDependenciesResolver, OffersDependenciesResolver {
    func resolve() -> TimeManager
    func resolve() -> UINavigationController
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> CardRepository
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> LocalAppConfig
    func resolve() -> CardTransactionDetailUseCase
    func resolve() -> GetCardDetailDataUseCase
    func resolve() -> GetCardTransactionConfigUseCase
    func resolve() -> GetContractMovementUseCase
    func resolve() -> GetFeesEasypayUseCase
    func resolve() -> GetMinEasyPayAmountUseCase
    func resolve() -> GetSingleCardMovementLocationUseCase
    func resolve() -> GetTransactionDetailEasyPayUseCase
    func resolve() -> GetCardTransactionDetailDataUseCase
    func resolve() -> GetCardTransactionDetailViewConfigurationUseCase
    func resolve() -> FirstFeeInfoEasyPayReactiveUseCase
    func resolve() -> GetCardTransactionDetailActionsUseCase
    func cardExternalDependenciesResolver() -> CardExternalDependenciesResolver
    func cardTransactionDetailCoordinator() -> BindableCoordinator
    func shoppingMapCoordinator() -> BindableCoordinator
}

public extension CardTransactionDetailExternalDependenciesResolver {
    func cardTransactionDetailCoordinator() -> BindableCoordinator {
        return DefaultCardTransactionDetailCoordinator(dependencies: self,
                                                       navigationController: resolve())
    }
    
    func resolve() -> CardTransactionDetailUseCase {
        return DefaultCardTransactionDetailUseCase(dependencies: self)
    }
    
    func resolve() -> GetCardDetailDataUseCase {
        return DefaultGetCardDetailDataUseCase(dependencies: self)
    }
    
    func resolve() -> GetCardTransactionConfigUseCase {
        return DefaultGetCardTransactionConfigUseCase(dependencies: self)
    }
    
    func resolve() -> GetContractMovementUseCase {
        return DefaultGetContractMovementUseCase(dependencies: self)
    }
    
    func resolve() -> GetFeesEasypayUseCase {
        return DefaultGetFeesEasypayUseCase(dependencies: self)
    }
    
    func resolve() -> GetMinEasyPayAmountUseCase {
        return DefaultGetMinEasyPayAmountUseCase()
    }
    
    func resolve() -> GetSingleCardMovementLocationUseCase {
        return DefaultGetSingleCardMovementLocationUseCase(dependencies: self)
    }
    
    func resolve() -> GetTransactionDetailEasyPayUseCase {
        return DefaultGetTransactionDetailEasyPayUseCase(dependencies: self)
    }
    
    func resolve() -> GetCardTransactionDetailDataUseCase {
        return DefaultGetCardTransactionDetailDataUseCase(dependencies: self)
    }
    
    func resolve() -> GetCardTransactionDetailViewConfigurationUseCase {
        return DefaultGetCardTransactionDetailViewConfigurationUseCase()
    }
    
    func resolve() -> GetCardTransactionDetailActionsUseCase {
        return DefaultGetCardTransactionDetailActionsUseCase(dependencies: self)
    }
    
    func resolve() -> FirstFeeInfoEasyPayReactiveUseCase {
        return DefaultFirstFeeInfoEasyPayReactiveUseCase(repository: resolve())
    }
}
