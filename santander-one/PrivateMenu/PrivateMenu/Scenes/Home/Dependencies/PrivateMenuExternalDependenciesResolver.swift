import UI
import CoreDomain
import CoreFoundationLib

public protocol PrivateMenuExternalDependenciesResolver {
    func resolve() -> GetPrivateMenuFooterOptionsUseCase
    func resolve() -> GetDigitalProfilePercentageUseCase
    func resolve() -> GetCandidateOfferUseCase
    func resolve() -> GetNameUseCase
    func resolve() -> GetAvatarImageUseCase
    func resolve() -> DependenciesResolver
    func resolve() -> MenuRepository
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> UINavigationController
    func resolve() -> GetPrivateMenuOptionsUseCase
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> SegmentedUserRepository
    func resolve() -> LocalAppConfig
    func resolve() -> UserPreferencesRepository
    func resolve() -> GetFeaturedOptionsUseCase
    func resolve() -> PersonalManagerReactiveRepository
    func resolve() -> PersonalManagerNotificationReactiveRepository
    func resolve() -> GetPersonalManagerUseCase
    func resolve() -> GetPrivateMenuOptionEnabledUseCase
    func resolve() -> GetMyProductsUseCase
    func resolve() -> GetPrivateMenuConfigUseCase
    func resolve() -> PrivateMenuToggleOutsider
    func resolve() -> PrivateMenuEventsRepository
    func resolve() -> GetGlobalPositionBoxesUseCase
    func resolve() -> GetSanflixUseCase
    func resolve() -> GetMarketplaceWebViewConfigurationUseCase
    func resolve() -> AppRepositoryProtocol
    func resolve() -> PersonalAreaRepository
    func resolve() -> GetManagerImageUseCase
    func resolve() -> DisplayManagerPrivateMenuUseCase
    func resolve() -> LocationPermissionsManagerProtocol
    func privateMenuCoordinator() -> BindableCoordinator
    func privateSubMenuCoordinator() -> BindableCoordinator
    func personalAreaCoordinator() -> BindableCoordinator
    func securityCoordinator() -> BindableCoordinator
    func branchLocatorCoordinator() -> BindableCoordinator
    func helpCenterCoordinator() -> BindableCoordinator
    func myManagerCoordinator() -> BindableCoordinator
    func logoutCoordinator() -> BindableCoordinator
    func santanderBootsCoordinator() -> BindableCoordinator
    func myMoneyManagerCoordinator() -> BindableCoordinator
    func productsAndOffersCoordinator() -> BindableCoordinator
    func importantInformationCoordinator() -> BindableCoordinator
    func sendMoneyHomeCoordinator() -> BindableCoordinator
    func homeEcoCoordinator() -> BindableCoordinator
    func blikCoordinator() -> BindableCoordinator
    func mobileAuthorizationCoordinator() -> BindableCoordinator
    func becomeClientCoordinator() -> BindableCoordinator
    func currencyExchangeCoordinator() -> BindableCoordinator
    func servicesCoordinator() -> BindableCoordinator
    func memberGetMemberCoordinator() -> BindableCoordinator
    func financingHomeCoordinator() -> BindableCoordinator
    func billAndTaxesHomeCoordinator() -> BindableCoordinator
    func analysisAreaHomeCoordinator() -> BindableCoordinator
    func topUpsCoordinator() -> BindableCoordinator
    func privateMenuContractViewCoordinator() -> BindableCoordinator
    func privateMenuWebConfigurationCoordinator() -> BindableCoordinator
    func resolveOfferCoordinator() -> BindableCoordinator
    func privateMenuOpinatorCoordinator() -> BindableCoordinator
}

public extension PrivateMenuExternalDependenciesResolver {
    func privateMenuCoordinator() -> BindableCoordinator {
        return DefaultPrivateMenuCoordinator(dependencies: self)
    }
    
    func resolve() -> GetPrivateMenuFooterOptionsUseCase {
        return DefaultMenuFooterOptionsUseCase()
    }
    
    func resolve() -> GetPrivateMenuOptionsUseCase {
        return DefaultPrivateMenuOptionsUseCase()
    }
    
    func resolve() -> GetDigitalProfilePercentageUseCase {
        return DefaultGetDigitalProfilePercentageUseCase(dependencies: self)
    }
    
    func resolve() -> GetNameUseCase {
        return DefaultGetNameUseCase(dependencies: self)
    }
    
    func resolve() -> GetAvatarImageUseCase {
        return DefaultGetAvatarImageUseCase(dependencies: self)
    }
    
    func resolve() -> GetFeaturedOptionsUseCase {
        return DefaultGetFeaturedOptionsUseCase(dependencies: self)
    }
    
    func resolve() -> MenuRepository {
        return DefaultPrivateMenuRepository()
    }
    
    func resolve() -> GetPersonalManagerUseCase {
        return DefaultGetPersonalManagerUseCase()
    }
    
    func resolve() -> GetPrivateMenuOptionEnabledUseCase {
        return DefaultGetPrivateMenuOptionEnabledUseCase(dependencies: self)
    }
    
    func resolve() -> GetMyProductsUseCase {
        return DefaultGetMyProductsUseCase(dependencies: self)
    }
    
    func resolve() -> GetPrivateMenuConfigUseCase {
        return DefaultGetPrivateMenuConfigUseCase(dependencies: self)
    }
    
    func resolve() -> GetGlobalPositionBoxesUseCase {
        return DefaultGlobalPositionBoxesUseCase(dependencies: self)
    }
    
    func resolve() -> GetSanflixUseCase {
        return DefaultGetSanflixUseCase(dependencies: self)
    }
    
    func resolve() -> GetMarketplaceWebViewConfigurationUseCase {
        return DefaultGetMarketplaceWebViewConfigurationUseCase(dependencies: self)
    }
    
    func resolve() -> GetManagerImageUseCase {
        return DefaultGetManagerImageUseCase(dependencies: self)
    }
    
    func resolve() -> DisplayManagerPrivateMenuUseCase {
        return DefaultDisplayManagerPrivateMenuUseCase()
    }
    
    func santanderBootsCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func myMoneyManagerCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func productsAndOffersCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func importantInformationCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func homeEcoCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func blikCoordinator() -> BindableCoordinator {
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func mobileAuthorizationCoordinator() -> BindableCoordinator{
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func becomeClientCoordinator() -> BindableCoordinator{
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func currencyExchangeCoordinator() -> BindableCoordinator{
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func servicesCoordinator() -> BindableCoordinator{
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
    
    func memberGetMemberCoordinator() -> BindableCoordinator{
        ToastCoordinator("generic_alert_notAvailableOperation")
    }
}
