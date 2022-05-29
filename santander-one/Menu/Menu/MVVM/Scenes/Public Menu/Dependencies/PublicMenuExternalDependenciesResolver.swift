import Foundation
import CoreFoundationLib
import UI
import CoreDomain

public protocol PublicMenuSceneExternalDependenciesResolver: ShareDependenciesResolver {
    func resolve() -> PublicMenuRepository
    func resolve() -> PublicMenuActionsRepository
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> SegmentedUserRepository
    func resolve() -> HomeTipsRepository
    func resolve() -> ReactivePullOffersConfigRepository
    func resolve() -> BaseURLProvider
    func resolve() -> ReactivePullOffersInterpreter
    func resolve() -> PublicMenuToggleOutsider
    func resolve() -> TrackerManager
    func resolveSideMenuNavigationController() -> UINavigationController
    func publicMenuATMLocatorCoordinator() -> BindableCoordinator
    func publicMenuATMHomeCoordinator() -> Coordinator
    func publicMenuStockholdersCoordinator() -> Coordinator
    func publicMenuOurProductsCoordinator() -> Coordinator
    func publicMenuHomeTipsCoordinator() -> Coordinator
    func publicMenuSceneCoordinator() -> Coordinator
    func publicMenuCustomCoordinatorForAction() -> BindableCoordinator
    func resolveOfferCoordinator() -> BindableCoordinator
}

public extension PublicMenuSceneExternalDependenciesResolver {
    func publicMenuSceneCoordinator() -> Coordinator {
        return DefaultPublicMenuCoordinator(dependencies: self, navigationController: resolveSideMenuNavigationController())
    }
    
    func publicMenuCustomCoordinatorForAction() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
}
