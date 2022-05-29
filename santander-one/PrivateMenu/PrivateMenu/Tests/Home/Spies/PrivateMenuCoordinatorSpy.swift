//
//  PrivateMenuCoordinatorSpy.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreFoundationLib
@testable import PrivateMenu
import UI

final class PrivateMenuCoordinatorSpy: PrivateMenuCoordinator {
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var gotoSecurityCalled: Bool = false
    var gotoBranchLocatorCalled: Bool = false
    var gotoHelpCenterCalled: Bool = false
    var gotoMyManagerCalled: Bool = false
    var gotoPersonalAreaCalled: Bool = false
    var gotoPGCalled: Bool = false
    var logoutCalled: Bool = false
    var gotoSantanderBootsCalled: Bool = false
    var gotoMyMoneyManagerCalled: Bool = false
    var gotoProductsAndOffersCalled: Bool = false
    var gotoImportantInformationCalled: Bool = false
    var gotoSendMoneyCalled: Bool = false
    var gotoHomeEcoCalled: Bool = false
    var toggleSideMenuCalled: Bool = false
    var gotoSubmenuCalled: Bool = false
    var gotoBlikCalledCalled: Bool = false
    var gotoMobileAuthorizationCalledCalled: Bool = false
    var gotoBecomeClientCalled: Bool = false
    var gotoCurrencyExchangeCalled: Bool = false
    var gotoServicesCalled: Bool = false
    var gotoMemberGetMemberCalled: Bool = false
    var gotoFinancingCalled: Bool = false
    var gotoBillAndTaxesCalled: Bool = false
    var gotoAnalysisAreaCalled: Bool = false
    var gotoTopUpsCalled: Bool = false
    var goToContractViewCalled: Bool = false
    var goToWebConfigurationCalled: Bool = false
    var closeSideMenuCalled: Bool = false
    var goToOfferCalled: Bool = false
    var gotoOpinatorCalled: Bool = false
    var goToComingSoonCalled: Bool = false
    var startCalled: Bool = false

    init() {
        dataBinding = DataBindingObject()
        childCoordinators = []
    }
    
    func gotoSecurity() {
        gotoSecurityCalled = true
    }
    
    func gotoBranchLocator() {
        gotoBranchLocatorCalled = true
    }
    
    func gotoHelpCenter() {
        gotoHelpCenterCalled = true
    }
    
    func gotoMyManager() {
        gotoMyManagerCalled = true
    }
    
    func gotoPersonalArea() {
        gotoPersonalAreaCalled = true
    }
    
    func gotoPG() {
        gotoPGCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
    
    func gotoSantanderBoots() {
        gotoSantanderBootsCalled = true
    }
    
    func gotoMyMoneyManager() {
        gotoMyMoneyManagerCalled = true
    }
    
    func gotoProductsAndOffers() {
        gotoProductsAndOffersCalled = true
    }
    
    func gotoImportantInformation() {
        gotoImportantInformationCalled = true
    }
    
    func gotoSendMoney() {
        gotoSendMoneyCalled = true
    }
    
    func gotoHomeEco() {
        gotoHomeEcoCalled = true
    }
    
    func toggleSideMenu() {
        toggleSideMenuCalled = true
    }
    
    func gotoSubmenu(_ privateSubMenuOptionType: PrivateSubMenuOptionType) {
        gotoSubmenuCalled = true
    }
    
    func gotoBlik() {
        gotoBlikCalledCalled = true
    }
    
    func gotoMobileAuthorization() {
        gotoMobileAuthorizationCalledCalled = true
    }
    
    func gotoBecomeClient() {
        gotoBecomeClientCalled = true
    }
    
    func gotoCurrencyExchange() {
        gotoCurrencyExchangeCalled = true
    }
    
    func gotoServices() {
        gotoServicesCalled = true
    }
    
    func gotoMemberGetMember() {
        gotoMemberGetMemberCalled = true
    }
    
    func gotoFinancing() {
        gotoFinancingCalled = true
    }
    
    func gotoBillAndTaxes() {
        gotoBillAndTaxesCalled = true
    }
    
    func gotoAnalysisArea() {
        gotoAnalysisAreaCalled = true
    }
    
    func gotoTopUps() {
        gotoTopUpsCalled = true
    }
    
    func goToContractView() {
        goToContractViewCalled = true
    }
    
    func goToWebConfiguration(_ config: WebViewConfiguration) {
        goToWebConfigurationCalled = true
    }
    
    func closeSideMenu() {
        closeSideMenuCalled = true
    }
    
    func goToOffer(_ offer: OfferRepresentable) {
        goToOfferCalled = true
    }
    
    func gotoOpinator() {
        gotoOpinatorCalled = true
    }
    
    func goToComingSoon() {
        goToComingSoonCalled = true
    }
    
    func start() {
        startCalled = true
    }
}
