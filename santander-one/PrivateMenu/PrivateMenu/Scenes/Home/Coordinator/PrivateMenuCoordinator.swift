//
//  PrivateMenuCoordinator.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 17/12/21.
//

import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

protocol PrivateMenuCoordinator: BindableCoordinator {
    func gotoSecurity()
    func gotoBranchLocator()
    func gotoHelpCenter()
    func gotoMyManager()
    func gotoPersonalArea()
    func gotoPG()
    func logout()
    func gotoSantanderBoots()
    func gotoMyMoneyManager()
    func gotoProductsAndOffers()
    func gotoImportantInformation()
    func gotoSendMoney()
    func gotoHomeEco()
    func toggleSideMenu()
    func gotoSubmenu(_ privateSubMenuOptionType: PrivateSubMenuOptionType)
    func gotoBlik()
    func gotoMobileAuthorization()
    func gotoBecomeClient()
    func gotoCurrencyExchange()
    func gotoServices()
    func gotoMemberGetMember()
    func gotoFinancing()
    func gotoBillAndTaxes()
    func gotoAnalysisArea()
    func gotoTopUps()
    func goToContractView()
    func goToWebConfiguration(_ config: WebViewConfiguration)
    func closeSideMenu()
    func goToOffer(_ offer: OfferRepresentable)
    func gotoOpinator()
    func goToComingSoon()
}

final class DefaultPrivateMenuCoordinator: PrivateMenuCoordinator {
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private lazy var dependencies: Dependency = {
        Dependency(externalDependency: externalDependencies, coordinator: self)
    }()
    private let externalDependencies: PrivateMenuExternalDependenciesResolver

    public init(dependencies: PrivateMenuExternalDependenciesResolver) {
        self.externalDependencies = dependencies
    }
}

extension DefaultPrivateMenuCoordinator {
    func start() {
        self.navigationController = UINavigationController(rootViewController: dependencies.resolve())
    }

    func gotoSecurity() {
        let coordinator = dependencies.external.securityCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoBranchLocator() {
        let coordinator = dependencies.external.branchLocatorCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoHelpCenter() {
        let coordinator = dependencies.external.helpCenterCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoMyManager() {
        let coordinator = dependencies.external.myManagerCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func logout() {
        let coordinator = dependencies.external.logoutCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoPersonalArea() {
        let coordinator = dependencies.external.personalAreaCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoPG() {
        closeSideMenu()
        let navigationController: UINavigationController = dependencies.external.resolve()
        navigationController.popToRootViewController(animated: true)
    }
    
    func closeSideMenu() {
        let outsider: PrivateMenuToggleOutsider = dependencies.external.resolve()
        outsider.closeSideMenu()
    }
    
    func gotoSantanderBoots() {
        let coordinator = dependencies.external.santanderBootsCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoMyMoneyManager() {
        let coordinator = dependencies.external.myManagerCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoProductsAndOffers() {
        let coordinator = dependencies.external.productsAndOffersCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoImportantInformation() {
        let coordinator = dependencies.external.importantInformationCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoSendMoney() {
        let coordinator = dependencies.external.sendMoneyHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoHomeEco() {
        let coordinator = dependencies.external.homeEcoCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func toggleSideMenu() {
        let outsider: PrivateMenuToggleOutsider = dependencies.external.resolve()
        outsider.toggleSideMenu()
    }
    
    func gotoSubmenu(_ privateSubMenuOptionType: PrivateSubMenuOptionType) {
        let coordinator = dependencies.external.privateSubMenuCoordinator()
            .set(privateSubMenuOptionType)
        gotoCoordinator(coordinator, dismissMenu: false)
    }
    
    func gotoBlik() {
        let coordinator = dependencies.external.blikCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoMobileAuthorization() {
        let coordinator = dependencies.external.mobileAuthorizationCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoBecomeClient() {
        let coordinator = dependencies.external.becomeClientCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoCurrencyExchange() {
        let coordinator = dependencies.external.currencyExchangeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoServices() {
        let coordinator = dependencies.external.servicesCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoMemberGetMember() {
        let coordinator = dependencies.external.memberGetMemberCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoFinancing() {
        let coordinator = dependencies.external.financingHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoBillAndTaxes() {
        let coordinator = dependencies.external.billAndTaxesHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoAnalysisArea() {
        let coordinator = dependencies.external.analysisAreaHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func gotoTopUps() {
        let coordinator = dependencies.external.topUpsCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToContractView() {
        let coordinator = dependencies.external.privateMenuContractViewCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToWebConfiguration(_ config: WebViewConfiguration) {
        let coordinator = dependencies.external.privateMenuWebConfigurationCoordinator()
            .set(config)
        gotoCoordinator(coordinator)
    }
    
    func goToOffer(_ offer: OfferRepresentable) {
        let coordinator = dependencies.external.resolveOfferCoordinator()
        coordinator
            .set(offer)
        gotoCoordinator(coordinator)
    }
    
    func goToComingSoon() {
        let coordinator = ToastCoordinator("generic_alert_notAvailableOperation")
        gotoCoordinator(coordinator)
    }
    
    func gotoOpinator() {
        let coordinator = dependencies.external.privateMenuOpinatorCoordinator()
        gotoCoordinator(coordinator)
    }
}

private extension DefaultPrivateMenuCoordinator {
    class Dependency: PrivateMenuDependenciesResolver {
        let coordinator: DefaultPrivateMenuCoordinator
        let dataBinding = DataBindingObject()
        let dependencies: PrivateMenuExternalDependenciesResolver
        
        var external: PrivateMenuExternalDependenciesResolver {
            return dependencies
        }
        
        init(externalDependency: PrivateMenuExternalDependenciesResolver, coordinator: DefaultPrivateMenuCoordinator) {
            self.dependencies = externalDependency
            self.coordinator = coordinator
        }
    
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> PrivateMenuCoordinator {
            return coordinator
        }
    }
    
    func gotoCoordinator(_ coordinator: BindableCoordinator, dismissMenu: Bool = true) {
        if dismissMenu {
            toggleSideMenu()
        }
        coordinator.start()
        append(child: coordinator)
    }
}
