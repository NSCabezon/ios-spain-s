import UI
import CoreFoundationLib
import SANLegacyLibrary

public class PersonalAreaModuleCoordinator: ModuleSectionedCoordinator {
    
    public weak var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesResolver & DependenciesInjector
    let userPreferencesDependencies: UserPreferencesDependenciesResolver
    
    lazy var personalAreaDataManager: PersonalAreaDataManager = {
        PersonalAreaDataManager(dependenciesEngine: dependenciesEngine,
                                userPreferencesDependencies: userPreferencesDependencies)
    }()
    
    lazy var mainCoordinator: PersonalAreaMainModuleCoordinator = {
        PersonalAreaMainModuleCoordinator(dependenciesResolver: dependenciesEngine,
                                          navigationController: navigationController)
    }()
    
    lazy var securityAreaCoordinator: SecurityAreaCoordinator = {
        SecurityAreaCoordinator(dependenciesResolver: dependenciesEngine,
                                navigationController: navigationController)
    }()
    
//    lazy var gpPersonalizationCoordinator: PGPersonalizationModuleCoordinator = {
//        PGPersonalizationModuleCoordinator(dependenciesResolver: dependenciesEngine,
//                                           navigationController: navigationController)
//    }()
    
    public enum PersonalAreaSection: CaseIterable {
        case main
        case userBasicInfo
        case configuration
        case digitalProfile
        case security
        case secureDeviceOperative
        case securityArea
        case customizeGP
        case productsCustomization
    }

    public init(dependenciesResolver: DependenciesResolver & DependenciesInjector,
                navigationController: UINavigationController?,
                userPreferencesDependencies: UserPreferencesDependenciesResolver
    ) {
        self.navigationController = navigationController
        self.dependenciesEngine = dependenciesResolver
        self.userPreferencesDependencies = userPreferencesDependencies
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: PersonalAreaMainModuleNavigator.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: PersonalAreaDataManagerProtocol.self) { _ in
            return self.personalAreaDataManager
        }
        
        self.dependenciesEngine.register(for: GetOTPPushDeviceUseCase.self) { dependenciesResolver in
            return GetOTPPushDeviceUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: UserPrefWrapper.self) { dependenciesResolver in
            let personalAreaDataManager = dependenciesResolver.resolve(for: PersonalAreaDataManagerProtocol.self)
            return personalAreaDataManager.getUserPreference()
        }
        
        self.dependenciesEngine.register(for: LastAccessInfoManagerProtocol.self) { dependenciesResolver in
            return LastAccessInfoManager(dependenciesEngine: dependenciesResolver)
        }
    }
    
    private func goToGPPersonalization() { }
    
    public func goToGPProductsCustomization() { }
    
    public func start(_ section: PersonalAreaSection) {
        if let globalPositionVC = navigationController?.viewControllers.first {
            navigationController?.setViewControllers([globalPositionVC], animated: true)
        }
        switch section {
        case .main:
            mainCoordinator.start()
        case .userBasicInfo:
            goToUserDataSection()
        case .configuration:
            goToConfigurationSection()
        case .digitalProfile:
            goToDigitalProfile()
        case .security:
            goToSecuritySection()
        case .secureDeviceOperative:
            goToSecureDeviceOperative()
        case .securityArea:
            securityAreaCoordinator.start()
        case .customizeGP:
            goToGPPersonalization()
        case .productsCustomization:
            goToGPProductsCustomization()
        }
    }
}

extension PersonalAreaModuleCoordinator: PersonalAreaMainModuleNavigator {
    public func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public func goToUserDataSection() {

    }
    
    public func goToDigitalProfile() {

    }
    
    public func goToConfigurationSection() {
        
    }
    
    public func goToSecuritySection() {
        
    }
    
    public func goToSecureDevice(device: OTPPushDeviceEntity?) {

    }
    
    public func goToSecureDeviceOperative() {
        let personalAreaCoordinator = dependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        personalAreaCoordinator.showSecureDeviceOperative()
    }
    
    public func goToPGCustomization() {
        
    }

    public func goToAppPermissions() {
        
    }
}

public protocol PersonalAreaMainModuleNavigator: AnyObject {
    func dismiss()
    func goToUserDataSection()
    func goToDigitalProfile()
    func goToConfigurationSection()
    func goToSecuritySection()
    func goToSecureDevice(device: OTPPushDeviceEntity?)
    func goToSecureDeviceOperative()
    func goToPGCustomization()
}
