//
//  ViewController.swift
//  BiometryValidator
//
//  Created by Ruben Marquez on 05/20/2021.
//  Copyright (c) 2021 Ruben Marquez. All rights reserved.
//

import UIKit
import QuickSetup
import SANLibraryV3
import Operative
import UI
import Contacts
import BiometryValidator
import Ecommerce
import CoreFoundationLib
import ESCommons
import QuickSetupES
import Localization

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var navController = UINavigationController()
    var globalPosition: GlobalPositionRepresentable!
    let reloadEngine = GlobalPositionReloadEngine()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        return QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    private let localAppConfig: LocalAppConfig = LocalAppConfigMock()
    private lazy var getLanguagesSelectionUseCaseMock: GetLanguagesSelectionUseCase = {
        GetLanguagesSelectionUseCaseMock(dependencies: dependencies)
    }()
    internal lazy var dependencies: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: BSANManagersProvider.self) { _ in
            return self.quickSetup.managersProvider
        }
        defaultResolver.register(for: BSANDataProvider.self) { _ in
            return self.quickSetup.bsanDataProvider
        }
        defaultResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        defaultResolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        defaultResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return self.globalPosition
        }
        defaultResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver,
                                                         globalPosition: globalPosition,
                                                         saveUserPreferences: true)
            return merger
        }
        defaultResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        defaultResolver.register(for: TimeManager.self) { _ in
            return self.localeManager
        }
        defaultResolver.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        defaultResolver.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryFake()
        }
        defaultResolver.register(for: GlobalPositionReloadEngine.self, with: { _ in
            return self.reloadEngine
        })
        defaultResolver.register(for: ColorsByNameEngine.self, with: { _ in
            return ColorsByNameEngine()
        })
        defaultResolver.register(for: UseCaseScheduler.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: UseCaseHandler.self)
        }
        defaultResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        defaultResolver.register(for: OperativeContainerCoordinatorDelegate.self) { _ in
            return self
        }
        defaultResolver.register(for: GlobalPositionReloader.self) { _ in
            return self
        }

        defaultResolver.register(for: BaseURLProvider.self, with: { _ in
            return BaseURLProvider(baseURL: nil)
        })
        defaultResolver.register(for: LocalAuthenticationPermissionsManagerProtocol.self) { _ in
            return LocalAuthenticationPermissionsManagerMock()
        }
        defaultResolver.register(for: BiometryValidatorModuleCoordinatorDelegate.self, with: { _ in
            return self
        })
        defaultResolver.register(for: EmptyPurchasesPresenterProtocol.self) { dependenciesResolver in
            let presenter = EmptyPurchasesPresenter(dependenciesResolver: dependenciesResolver)
            return presenter
        }
        defaultResolver.register(for: EmptyPurchasesViewController.self) { dependenciesResolver in
            var presenter: EmptyPurchasesPresenterProtocol = dependenciesResolver.resolve(for: EmptyPurchasesPresenterProtocol.self)
            let viewController = EmptyPurchasesViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        defaultResolver.register(for: EmptyDialogViewController.self) { dependenciesResolver in
            let emptyViewController: EmptyPurchasesViewController = dependenciesResolver.resolve(for: EmptyPurchasesViewController.self)
            let viewController = EmptyDialogViewController(emptyViewController: emptyViewController)
            return viewController
        }
        defaultResolver.register(for: PullOfferCandidatesUseCase.self) { dependenciesResolver in
            return PullOfferCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        defaultResolver.register(for: CoreSessionManager.self) { _ in
            return CoreSessionManagerMock(configuration: defaultResolver.resolve(for: SessionConfiguration.self))
        }
        defaultResolver.register(for: SessionConfiguration.self) { _ in
            return SessionConfiguration(timeToExpireSession: 10000000000000,
                                        timeToRefreshToken: 10000000000000,
                                        sessionStartedActions: [],
                                        sessionFinishedActions: [])}
        defaultResolver.register(for: LocalAppConfig.self) { _ in
            self.localAppConfig
        }
        defaultResolver.register(for: GetLanguagesSelectionUseCaseProtocol.self) { _ in
            self.getLanguagesSelectionUseCaseMock
        }
        defaultResolver.register(for: CompilationProtocol.self) { _ in
            return CompilationMock()
        }
        defaultResolver.register(for: EmptyPurchasesPresenterDelegate.self) { _ in
            return self
        }
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: dependenciesResolver)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadPG()
    }
    
    // MARK: - Actions

    @IBAction func openBiometryValidator() {
        self.navController = UINavigationController()
        navController.modalPresentationStyle = .fullScreen
        self.present(self.navController, animated: true) {
            let coordinator = BiometryValidatorModuleCoordinator(dependenciesResolver: self.dependencies, navigationController: self.navController)
            coordinator.start()
        }
    }
}

private extension ViewController {
    func loadPG() {
        quickSetup.setEnviroment(QuickSetupES.BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
        quickSetup.setDemoAnswers(["consultarDBasicos": 1])
        _ = try? quickSetup.managersProvider.getBsanSignatureManager().loadCMCSignature()
        self.globalPosition = quickSetup.getGlobalPosition()
    }
}

extension ViewController: BiometryValidatorModuleCoordinatorDelegate {
    func getScreen() -> String {
        ""
    }
    
    func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void) {
        onCompletion(true, nil)
    }
    
    func continueSignProcess() { }
    
    func biometryDidSuccessfullyDisappear() { }
    
    func biometryDidDisappear(withError error: String?) { }
    
    func signProcess() { }
    
    func success(deviceToken: String, footprint: String) { }
    
    func cancel() { }
}

extension ViewController: EmptyPurchasesPresenterDelegate {
    func registerSecureDeviceDeepLink() {
        //
    }
    
    func didSelectOffer(_ offer: OfferEntity) {
        //
    }    
}

struct CoreSessionManagerMock: CoreSessionManager {
    var configuration: SessionConfiguration
    var isSessionActive: Bool { true }
    var lastFinishedSessionReason: SessionFinishedReason?
    func setLastFinishedSessionReason(_ reason: SessionFinishedReason) {}
    func sessionStarted(completion: (() -> Void)?) {}
    func finishWithReason(_ reason: SessionFinishedReason) {}
}

