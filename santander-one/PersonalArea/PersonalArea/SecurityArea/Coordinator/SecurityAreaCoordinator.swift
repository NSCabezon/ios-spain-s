//
//  SecurityAreaCoordinator.swift
//  Account
//
//  Created by Carlos Monfort Gómez on 21/01/2020.
//

import Foundation
import CoreFoundationLib
import UI
import Operative
import CoreDomain

protocol SecurityAreaCoordinatorProtocol {
    func goToSecureDevice()
    func didSelectTravel()
    func goToOperabilityChange()
    func showToast()
}

public protocol SecurityAreaCoordinatorDelegate: AnyObject {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectCallPhoneNumber(_ phoneNumber: String)
    func didSelectAction(_ action: SecurityActionType)
    func didSelectPermission()
    func didSelectProtection()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers, closeButtonEnabled: Bool)
}

final class SecurityAreaCoordinator: NSObject, ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let personalAreaDataManager: PersonalAreaDataManagerProtocol
    lazy var tripListCoordinator: TripListCoordinator = {
        return TripListCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigationController
        )
    }()
    
    lazy var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate = {
        return self.dependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.personalAreaDataManager = self.dependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
        super.init()
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: SecurityAreaViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: SecurityAreaCoordinator.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: LastAccessInfoManagerProtocol.self) { _ in
            return LastAccessInfoManager(dependenciesEngine: self.dependenciesEngine)
        }
        self.dependenciesEngine.register(for: SecurityAreaPresenterProtocol.self) { dependenciesResolver in
            return SecurityAreaPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetSecurityTipsUseCase.self) { dependenciesResolver in
            return GetSecurityTipsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SecurityAreaCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetValidatedDeviceUseCase.self) { dependenciesResolver in
            return GetValidatedDeviceUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetContactPhonesUseCaseProtocol.self) { dependenciesResolver in
            return GetContactPhonesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPersonalBasicInfoUseCaseProtocol.self) { dependenciesResolver in
            return GetPersonalBasicInfoUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: LocationPermission.self) { dependenciesResolver in
            return LocationPermission(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetTripModeEnabledUseCase.self) { dependenciesResolver in
            return GetTripModeEnabledUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetOtpPushEnabledUseCase.self) { dependenciesResolver in
            return GetOtpPushEnabledUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetHasOneProductsUseCase.self) { dependenciesResolver in
            return GetHasOneProductsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SecurityAreaViewController.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SecurityAreaPresenterProtocol.self)
            let view = SecurityAreaViewController(dependenciesResolver: dependenciesResolver,
                                                  presenter: presenter)
            presenter.view = view
            return view
        }
        self.dependenciesEngine.register(for: GlobalSecurityViewContainerProtocol.self) { resolver in
            return GlobalSecurityViewContainer(dependencies: resolver)
        }
    }
}

extension SecurityAreaCoordinator: SecurityAreaCoordinatorProtocol {
    
    // Move to device manager or something like that
    func goToSecureDevice() {
        self.personalAreaCoordinator.showLoading(completion: { [weak self] in
            self?.personalAreaDataManager.getOTPPushDevice({ (device) in
                self?.personalAreaCoordinator.hideLoading(completion: {
                    self?.goToSecureDevice(device)
                })
            }, failure: { (error) in
                self?.personalAreaCoordinator.hideLoading(completion: {
                    self?.personalAreaCoordinator.showAlertDialog(
                        acceptTitle: localized("generic_button_accept"),
                        cancelTitle: nil,
                        title: nil,
                        body: localized(error),
                        acceptAction: nil, cancelAction: nil)
                })
            })
        })
    }
    
    func didSelectTravel() {
        self.tripListCoordinator.start()
    }
    
    func showToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    private func goToSecureDevice(_ device: OTPPushDeviceEntity?) {
        guard let device = device else {
            self.gotoDeviceTutorial()
            return
        }
        self.dependenciesEngine.register(for: SecureDeviceAliasConfiguration.self) { _ in
            return SecureDeviceAliasConfiguration(secureDevice: device)
        }
        self.gotoDeviceAlias()
    }
    
    private func gotoDeviceAlias() {
        SecureDeviceAliasCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigationController
        ).start()
    }
    
    private func gotoDeviceTutorial() {
        SecureDeviceTutorialCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigationController
        ).start()
    }
}

extension SecurityAreaCoordinator: OperabilityChangeLauncher {
    func goToOperabilityChange() {
        goToOperabilityChange(handler: self)
    }
}

extension SecurityAreaCoordinator: OperativeLauncherHandler {
    
    public var dependenciesResolver: DependenciesResolver {
        return self.dependenciesEngine
    }
    
    public var operativeNavigationController: UINavigationController? {
        return navigationController
    }
    
    public func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let delegate = self.dependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        delegate.showAlertDialog(acceptTitle: localized("generic_button_accept"),
                                 cancelTitle: nil,
                                 title: localized(keyTitle ?? ""),
                                 body: localized(keyDesc ?? ""),
                                 acceptAction: nil,
                                 cancelAction: nil)
        completion?()
    }
}
