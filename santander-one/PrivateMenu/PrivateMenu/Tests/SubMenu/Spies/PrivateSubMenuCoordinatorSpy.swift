//
//  PrivateSubMenuCoordinatorSpy.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreFoundationLib
@testable import PrivateMenu
import UI

final class PrivateSubMenuCoordinatorSpy: PrivateSubMenuCoordinator {
    var dataBinding: DataBinding
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var gotoSecurityCalled: Bool = false
    var gotoBranchLocatorCalled: Bool = false
    var gotoHelpCenterCalled: Bool = false
    var gotoMyManagerCalled: Bool = false
    var toggleSideMenuCalled: Bool = false
    var goToPrivateOfferCalled: Bool = false
    var goToAccountsCalled: Bool = false
    var goToCardsCalled: Bool = false
    var goToSavingProductsCalled: Bool = false
    var goToStocksCalled: Bool = false
    var goToDepositsCalled: Bool = false
    var goToLoansCalled: Bool = false
    var goToPensionsCalled: Bool = false
    var goToFundsCalled: Bool = false
    var goToManagedPortfoliosCalled: Bool = false
    var goToNotManagedPortfoliosCalled: Bool = false
    var goToManagedRVPortfoliosCalled: Bool = false
    var goToNotManagedRVPortfoliosCalled: Bool = false
    var goToInsuranceSavingsCalled: Bool = false
    var goToInsuranceProtectionCalled: Bool = false
    var goToProductProfileFundCalled: Bool = false
    var goToProductProfilePlansCalled: Bool = false
    var goToProductProfileVariableIncomeNotManagedCalled: Bool = false
    var goToProductProfileVariableIncomeManagedCalled: Bool = false
    var goToProductProfileTransactionCalled: Bool = false
    var goToImpositionsHomeCalled: Bool = false
    var goToImpositionTransactionDetailCalled: Bool = false
    var goToImpositionCalled: Bool = false
    var goToPortfolioProductDetailCalled: Bool = false
    var goToPortfolioProductTransactionDetailCalled: Bool = false
    var goToLiquidationCalled: Bool = false
    var goToLiquidationDetailCalled: Bool = false
    var goToOrdersCalled: Bool = false
    var goToCardDispensationCalled: Bool = false
    var goToCardsPendingCalled: Bool = false
    var goToBillCalled: Bool = false
    var goToSofiaInvestmentsCalled: Bool = false
    var showOldDialogCalledCalled: Bool = false
    var goToVariableIncomeCalled: Bool = false
    var goToStockholdersCalled: Bool = false
    var goToComingSoonCalled: Bool = false
    var gotoOpinatorCalled: Bool = false
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
    
    func toggleSideMenu() {
        toggleSideMenuCalled = true
    }
    
    func goToPrivateOffer(offer: OfferRepresentable) {
        goToPrivateOfferCalled = true
    }
    
    func goToAccounts() {
        goToAccountsCalled = true
    }
    
    func goToCards() {
        goToCardsCalled = true
    }
    
    func goToSavingProducts() {
        goToSavingProductsCalled = true
    }
    
    func goToStocks() {
        goToStocksCalled = true
    }
    
    func goToDeposits() {
        goToDepositsCalled = true
    }
    
    func goToLoans() {
        goToLoansCalled = true
    }
    
    func goToPensions() {
        goToPensionsCalled = true
    }
    
    func goToFunds() {
        goToFundsCalled = true
    }
    
    func goToManagedPortfolios() {
        goToManagedPortfoliosCalled = true
    }
    
    func goToNotManagedPortfolios() {
        goToNotManagedPortfoliosCalled = true
    }
    
    func goToManagedRVPortfolios() {
        goToManagedRVPortfoliosCalled = true
    }
    
    func goToNotManagedRVPortfolios() {
        goToNotManagedPortfoliosCalled = true
    }
    
    func goToInsuranceSavings() {
        goToInsuranceSavingsCalled = true
    }
    
    func goToInsuranceProtection() {
        goToInsuranceProtectionCalled = true
    }
    
    func goToProductProfileFund() {
        goToProductProfileFundCalled = true
    }
    
    func goToProductProfilePlans() {
        goToProductProfilePlansCalled = true
    }
    
    func goToProductProfileVariableIncomeNotManaged() {
        goToProductProfileVariableIncomeNotManagedCalled = true
    }
    
    func goToProductProfileVariableIncomeManaged() {
        goToProductProfileVariableIncomeManagedCalled = true
    }
    
    func goToProductProfileTransaction() {
        goToProductProfileTransactionCalled = true
    }
    
    func goToImpositionsHome() {
        goToImpositionsHomeCalled = true
    }
    
    func goToImpositionTransactionDetail() {
        goToImpositionTransactionDetailCalled = true
    }
    
    func goToImposition() {
        goToImpositionCalled = true
    }
    
    func goToPortfolioProductDetail() {
        goToPortfolioProductDetailCalled = true
    }
    
    func goToPortfolioProductTransactionDetail() {
        goToPortfolioProductTransactionDetailCalled = true
    }
    
    func goToLiquidation() {
        goToLiquidationCalled = true
    }
    
    func goToLiquidationDetail() {
        goToLiquidationDetailCalled = true
    }
    
    func goToOrders() {
        goToOrdersCalled = true
    }
    
    func goToCardDispensation() {
        goToCardDispensationCalled = true
    }
    
    func goToCardsPending() {
        goToCardsPendingCalled = true
    }
    
    func goToBill() {
        goToBillCalled = true
    }
    
    func goToSofiaInvestments() {
        goToSofiaInvestmentsCalled = true
    }
    
    func showOldDialog(_ message: String) {
        showOldDialogCalledCalled = true
    }
    
    func goToVariableIncome() {
        goToVariableIncomeCalled = true
    }
    
    func goToStockholders() {
        goToStockholdersCalled = true
    }
    
    func goToComingSoon() {
        goToComingSoonCalled = true
    }
    
    func gotoOpinator() {
        gotoOpinatorCalled = true
    }
    
    func start() {
        startCalled = true
    }
}

