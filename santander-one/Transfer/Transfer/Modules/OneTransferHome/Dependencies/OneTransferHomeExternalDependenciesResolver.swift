//
//  SceneExternalDependenciesResolver.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 3/12/21.
//

import CoreFoundationLib
import CoreDomain
import UI
import TransferOperatives

public protocol OneTransferHomeExternalDependenciesResolver: GetReactiveContactsUseCaseDependenciesResolver, OffersDependenciesResolver, InternalTransferOperativeExternalDependenciesResolver, DefaultGetAllTransfersReactiveUseCaseDependenciesResolver, FaqsDependenciesResolver {
    func resolve() -> BooleanFeatureFlag
    func resolve() -> TransfersRepository
    func resolve() -> DependenciesInjector
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolve() -> PullOffersInterpreter
    func resolve() -> OneTransferHomeVisibilityModifier
    func resolve() -> GetSendMoneyActionsUseCase
    func resolve() -> GetAllTransfersReactiveUseCase
    func resolve() -> FaqsRepositoryProtocol
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> OneFavouritesListExternalDependenciesResolver
    func comingSoonCoordinator() -> Coordinator
    func privateMenuCoordinator() -> Coordinator
    func globalSearchCoordinator() -> Coordinator
    func oneTransferHomeCoordinator() -> BindableCoordinator
    func contactDetail() -> BindableCoordinator
    func contactList() -> BindableCoordinator
    func transferHomeTooltip() -> BindableCoordinator
    func newContact() -> BindableCoordinator
    func newTransfer() -> TransferHomeModuleCoordinator
    func historicalEmitters() -> BindableCoordinator
    func transferDetail() -> BindableCoordinator
    func resolveCustomSendMoneyActionCoordinator() -> BindableCoordinator
    func resolveOfferCoordinator() -> BindableCoordinator
    func resolveTransferBetweenAccountsCoordinator() -> BindableCoordinator
    func resolveAtmCoordinator() -> BindableCoordinator
    func resolveReuseCoordinator() -> BindableCoordinator
    func resolveScheduledTransfersCoordinator() -> BindableCoordinator
    func virtualAssistant() -> BindableCoordinator
    func trackerManager() -> TrackerManager
    func emmaTrackEventListProtocol() -> EmmaTrackEventListProtocol
}

public extension OneTransferHomeExternalDependenciesResolver {    
    func resolve() -> TransfersRepository {
        return resolve().resolve(for: TransfersRepository.self)
    }
    
    func resolve() -> GetReactiveContactsUseCase {
        return DefaultGetReactiveContactsUseCase(dependencies: self)
    }
    
    func resolve() -> GetSendMoneyActionsUseCase {
        return DefaultGetSendMoneyActionsUseCase()
    }
    
    func resolve() -> OneTransferHomeVisibilityModifier {
        return DefaultOneTransferHomeVisibilityModifier()
    }
    
    func comingSoonCoordinator() -> Coordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }

    func oneTransferHomeCoordinator() -> BindableCoordinator {
        return DefaultOneTransferHomeCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func contactDetail() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func contactList() -> BindableCoordinator {
        return DefaultOneFavouritesListCoordinator(dependencies: resolve(), navigationController: resolve())
    }
    
    func transferHomeTooltip() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func newContact() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func newTransfer() -> TransferHomeModuleCoordinator {
        return TransferHomeModuleCoordinator(transferExternalDependencies: self, navigationController: resolve())
    }
    
    func resolve() -> InternalTransferOperativeCoordinator {
        return DefaultInternalTransferOperativeCoordinator(dependencies: self)
    }
    
    func historicalEmitters() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func transferDetail() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func resolveCustomSendMoneyActionCoordinator() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func resolveTransferBetweenAccountsCoordinator() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func resolveAtmCoordinator() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func resolveReuseCoordinator() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func resolveScheduledTransfersCoordinator() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func virtualAssistant() -> BindableCoordinator {
        return ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func trackerManager() -> TrackerManager {
        return resolve().resolve()
    }
    
    func emmaTrackEventListProtocol() -> EmmaTrackEventListProtocol {
        return resolve().resolve()
    }
    
    func resolve() -> GetAllTransfersReactiveUseCase {
        return DefaultGetAllTransfersReactiveUseCase(dependencies: self)
    }
}
