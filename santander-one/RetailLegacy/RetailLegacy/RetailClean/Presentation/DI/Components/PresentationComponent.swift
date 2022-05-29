import CoreFoundationLib
import Localization

public struct PresentationComponent {
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    let useCaseProvider: UseCaseProvider
    let useCaseHandler: UseCaseHandler
    let secondaryUseCaseHandler: UseCaseHandler
    let stringLoader: StringLoader
    let imageLoader: ImageLoader
    let timeManager: TimeManager
    let localeManager: LocaleManager
    let stylesManager: StylesManager
    let navigatorProvider: NavigatorProvider
    // let pfmController: PfmControllerProtocol
    let locationManager: LocationManager
    let pullOfferActionsManager: PullOfferActionsManager
    let inbentaManager: InbentaManager
    let managerWallManager: ManagerWallManager
    let deepLinkManager: DeepLinkManager
    let trackerManager: TrackerManager
    let siriIntentsManager: SiriIntentsManager
    let publicFilesManager: PublicFilesManagerProtocol
    let globalPositionReloadEngine: GlobalPositionReloadEngine
    let contactsManager: ContactsStoreManager
    let localAppConfig: LocalAppConfig
    let localAuthentication: LocalAuthenticationPermissionsManagerProtocol
}
