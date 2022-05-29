//
//  ConfigurationModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class DefaultConfigurationModuleCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(external: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: PersonalAreaConfigurationExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    lazy var laguageSelectorCoordinator: LanguageSelectorModuleCoordinator = {
        LanguageSelectorModuleCoordinator(dependenciesResolver: legacyDependenciesEngine,
                                          navigationController: navigationController)
    }()
    
    lazy var photoThemeSelectorCoordinator: PhotoThemeSelectorCoordinator = {
        PhotoThemeSelectorCoordinator(dependenciesResolver: legacyDependenciesEngine,
                                      navigationController: navigationController)
    }()
    
    lazy var gpPersonalizationCoordinator: Coordinator = {
        externalDependencies.personalAreaPGPersonalizationCoordinator()
    }()
    
    lazy var gpCustomizationCoordinator: GPCustomizationCoordinator = {
        GPCustomizationCoordinator(dependenciesResolver: legacyDependenciesEngine,
                                           navigationController: navigationController)
    }()
    
    lazy var appInfoCoordinator: AppInfoModuleCoordinator = {
        AppInfoModuleCoordinator(dependenciesResolver: legacyDependenciesEngine,
                                 navigationController: navigationController)
    }()
    
    lazy var appPermissions: Coordinator = {
        externalDependencies.personalAreaAppPermissionsCoordinator()
    }()
    
    init(dependenciesResolver: PersonalAreaConfigurationExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    public func start() {
        let confView = legacyDependenciesEngine.resolve(for: ConfigurationViewProtocol.self)
        self.navigationController?.blockingPushViewController(confView, animated: true)
    }
    
    public func startInGPCustomization() {
        goToGPCustomization()
    }
    
    public func startInGPProductsCustomization() {
        goToGPProductsCustomization()
    }
    
    private func setupDependencies() {
        self.legacyDependenciesEngine.register(for: ConfigurationPresenterProtocol.self) { dependenciesResolver in
            let presenter = ConfigurationModulePresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinatorNavigator = self.legacyDependenciesEngine.resolve(for: PersonalAreaMainModuleNavigator.self)
            presenter.moduleCoordinator = self
            presenter.dataManager = self.legacyDependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            return presenter
        }
        
        self.legacyDependenciesEngine.register(for: ConfigurationViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: ConfigurationPresenterProtocol.self)
            let view = ConfigurationModuleViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}

extension DefaultConfigurationModuleCoordinator: PersonalAreaConfigurationCoordinator {}

private extension DefaultConfigurationModuleCoordinator {
    struct Dependency: PersonalAreaConfigurationDependenciesResolver {
        let external: PersonalAreaConfigurationExternalDependenciesResolver
    }
}

extension DefaultConfigurationModuleCoordinator: ConfigurationModuleNavigator {
    func end() { navigationController?.popViewController(animated: true) }
    func goToLanguageSelection() { laguageSelectorCoordinator.start() }
    func goToGPCustomization() { gpPersonalizationCoordinator.start() }
    func goToFontSizeSelection() {}
    func goToPhotoThemeSelector() { photoThemeSelectorCoordinator.start() }
    func goToAlertConfiguration() {}
    func goToAppPermissions() { appPermissions.start() }
    func goToAppInfo() { appInfoCoordinator.start() }
    func goToGPProductsCustomization() { gpCustomizationCoordinator.start() }
}

protocol ConfigurationModuleNavigator: AnyObject {
    func end()
    func goToLanguageSelection()
    func goToGPCustomization()
    func goToFontSizeSelection()
    func goToPhotoThemeSelector()
    func goToAlertConfiguration()
    func goToAppPermissions()
    func goToAppInfo()
    func goToGPProductsCustomization()
}
