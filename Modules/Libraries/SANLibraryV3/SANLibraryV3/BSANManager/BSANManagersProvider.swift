import SANLegacyLibrary

public class BSANManagersProvider: SANLegacyLibrary.BSANManagersProvider {
    private var bsanAccountsManager: BSANAccountsManager?
    private var bsanAuthManager: BSANAuthManager?
    private var bsanCardsManager: BSANCardsManager?
    private var bsanDepositsManager: BSANDepositsManager?
    private var bsanEnvironmentsManager: BSANEnvironmentsManager?
    private var bsanFundsManager: BSANFundsManager?
    private var bsanInsurancesManager: BSANInsurancesManager?
    private var bsanLoansManager: BSANLoansManager?
    private var bsanManagersManager: BSANManagersManager?
    private var bsanMobileRechargeManager: BSANMobileRechargeManager?
    private var bsanPensionsManager: BSANPensionsManager?
    private var bsanPersonDataManager: BSANPersonDataManager?
    private var bsanPGManager: BSANPGManager?
    private var bsanPortfoliosPBManager: BSANPortfoliosPBManager?
    private var bsanPullOffersManager: BSANPullOffersManager?
    private var bsanSendMoneyManager: BSANSendMoneyManager?
    private var bsanSessionManager: BSANSessionManager?
    private var bsanSignatureManager: BSANSignatureManager?
    private var bsanSociusManager: BSANSociusManager?
    private var bsanStocksManager: BSANStocksManager?
    private var bsanBillTaxesManager: BSANBillTaxesManager?
    private var bsanTouchIdManager: BSANTouchIdManager?
    private var bsanTransfersManager: BSANTransfersManager?
    private var bsanUserSegmentManager: BSANUserSegmentManager?
    private var bsanCashWithdrawalManager: BSANCashWithdrawalManager?
    private var bsanCesManager: BSANCesManager?
    private var bsanMifidManager: BSANMifidManager?
    private var bsanOTPPushManager: BSANOTPPushManager?
    private var serviceLanguage = ServiceNameLanguage()
    private var bsanScaManager: BSANScaManager?
    private var bsanPendingSolicitudesManager: BSANPendingSolicitudesManager?
    private var bsanLoanSimulatorManager: BSANLoanSimulatorManager?
    private var timelineMovementsManager: BSANTimeLineManager?
    private var bsanOnePlanManager: BSANOnePlanManager?
    private var lastLogonManager: BSANLastLogonManager?
    private var financialAgregatorManager: BSANFinancialAgregatorManager?
    private var bsanBizumManager: BSANBizumManager?
    private var managerNotificationsManager: BSANManagerNotificationsManager?
    private var recoveryNoticesManager: BSANRecoveryNoticesManager?
    private var bsanFavouriteTransfersManager: BSANFavouriteTransfersManager?
    private var bsanAviosManager: BSANAviosManager?
    private var bsanBranchLocatorManager: BSANBranchLocatorManager?
    private var bsanEcommerceManager: BSANEcommerceManager?
    private var bsanPredefineSCAManager: BSANPredefineSCAManager?
    private var bsanFintechManager: BSANFintechManager?
    private var bsanSignBasicOperationManager: BSANSignBasicOperationManager?
    private var bsanSubscriptionManager: BSANSubscriptionManager?

    public init(){
        BSANBaseManager.serviceNameLanguage = serviceLanguage
    }

    public func setServiceLanguage(_ serviceNames: [String]) {
        serviceLanguage.setSpecialLanguageServiceNames(serviceNames)
    }
    
    public func getBsanAuthManager() -> SANLegacyLibrary.BSANAuthManager {
        if let bsanAuthManager = self.bsanAuthManager {
            return bsanAuthManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBSANAuthManager(bsanAuthManager: SANLegacyLibrary.BSANAuthManager) -> BSANManagersProvider {
        self.bsanAuthManager = bsanAuthManager
        return self
    }

    public func getBsanPGManager() -> BSANPGManager {
        if let bsanPGManager = self.bsanPGManager {
            return bsanPGManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBSANPGManager(bsanPGManager: BSANPGManager) -> BSANManagersProvider {
        self.bsanPGManager = bsanPGManager
        return self
    }
    
    public func getBsanDepositsManager() -> BSANDepositsManager {
        if let bsanDepositsManager = self.bsanDepositsManager {
            return bsanDepositsManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBSANDepositsManager(bsanDepositsManager: BSANDepositsManager) -> BSANManagersProvider {
        self.bsanDepositsManager = bsanDepositsManager
        return self
    }

    public func getBsanEnvironmentsManager() -> BSANEnvironmentsManager {
        if let bsanEnvironmentsManager = self.bsanEnvironmentsManager {
            return bsanEnvironmentsManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBSANEnvironmentsManager(bsanEnvironmentsManager: BSANEnvironmentsManager) -> BSANManagersProvider {
        self.bsanEnvironmentsManager = bsanEnvironmentsManager
        return self
    }

    public func getBsanSessionManager() -> BSANSessionManager {
        if let bsanSessionManager = self.bsanSessionManager {
            return bsanSessionManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBSANSessionManager(bsanSessionManager: BSANSessionManager) -> BSANManagersProvider {
        self.bsanSessionManager = bsanSessionManager
        return self
    }
    
    public func getBsanInsurancesManager() -> BSANInsurancesManager {
        if let bsanInsurancesManager = self.bsanInsurancesManager {
            return bsanInsurancesManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanInsurancesManager(bsanInsurancesManager: BSANInsurancesManager) -> BSANManagersProvider {
        self.bsanInsurancesManager = bsanInsurancesManager
        return self
    }

    public func getBsanCardsManager() -> BSANCardsManager {
        if let bsanCardsManager = self.bsanCardsManager {
            return bsanCardsManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanCardsManager(bsanCardsManager: BSANCardsManager) -> BSANManagersProvider {
        self.bsanCardsManager = bsanCardsManager
        return self
    }

    public func getBsanUserSegmentManager() -> BSANUserSegmentManager {
        if let bsanUserSegmentManager = self.bsanUserSegmentManager {
            return bsanUserSegmentManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanUserSegmentManager(bsanUserSegmentManager: BSANUserSegmentManager) -> BSANManagersProvider {
        self.bsanUserSegmentManager = bsanUserSegmentManager
        return self
    }

    public func getBsanPortfoliosPBManager() -> BSANPortfoliosPBManager {
        if let bsanPortfoliosPBManager = self.bsanPortfoliosPBManager {
            return bsanPortfoliosPBManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanPortfoliosPBManager(bsanPortfoliosPBManager: BSANPortfoliosPBManager) -> BSANManagersProvider {
        self.bsanPortfoliosPBManager = bsanPortfoliosPBManager
        return self
    }

    public func getBsanAccountsManager() -> SANLegacyLibrary.BSANAccountsManager {
        if let bsanAccountsManager = self.bsanAccountsManager {
            return bsanAccountsManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanAccountsManager(bsanAccountsManager: SANLegacyLibrary.BSANAccountsManager) -> BSANManagersProvider {
        self.bsanAccountsManager = bsanAccountsManager
        return self
    }
    
    public func getBsanManagersManager() -> BSANManagersManager {
        if let bsanManagersManager = self.bsanManagersManager {
            return bsanManagersManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanManagersManager(bsanManagersManager: BSANManagersManager) -> BSANManagersProvider {
        self.bsanManagersManager = bsanManagersManager
        return self
    }

    public func getBsanSociusManager() -> BSANSociusManager {
        if let bsanSociusManager = self.bsanSociusManager {
            return bsanSociusManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanSociusManager(bsanSociusManager: BSANSociusManager) -> BSANManagersProvider {
        self.bsanSociusManager = bsanSociusManager
        return self
    }

    public func getBsanTransfersManager() -> BSANTransfersManager {
        if let bsanTransfersManager = self.bsanTransfersManager {
            return bsanTransfersManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanTransfersManager(bsanTransfersManager: BSANTransfersManager) -> BSANManagersProvider {
        self.bsanTransfersManager = bsanTransfersManager
        return self
    }

    public func getBsanSendMoneyManager() -> BSANSendMoneyManager {
        if let bsanSendMoneyManager = self.bsanSendMoneyManager {
            return bsanSendMoneyManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanSendMoneyManager(bsanSendMoneyManager: BSANSendMoneyManager) -> BSANManagersProvider {
        self.bsanSendMoneyManager = bsanSendMoneyManager
        return self
    }
    
    public func getBsanMobileRechargeManager() -> BSANMobileRechargeManager {
        if let bsanMobileRechargeManager = self.bsanMobileRechargeManager {
            return bsanMobileRechargeManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanMobileRechargeManager(bsanMobileRechargeManager: BSANMobileRechargeManager) -> BSANManagersProvider {
        self.bsanMobileRechargeManager = bsanMobileRechargeManager
        return self
    }
    
    public func getBsanStocksManager() -> BSANStocksManager {
        if let bsanStocksManager = self.bsanStocksManager {
            return bsanStocksManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanStocksManager(bsanStocksManager: BSANStocksManager) -> BSANManagersProvider {
        self.bsanStocksManager = bsanStocksManager
        return self
    }

    public func getBsanPullOffersManager() -> BSANPullOffersManager {
        if let bsanPullOffersManager = self.bsanPullOffersManager {
            return bsanPullOffersManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanBillTaxesManager(bsanBillTaxesManager: SANLegacyLibrary.BSANBillTaxesManager) -> BSANManagersProvider {
        self.bsanBillTaxesManager = bsanBillTaxesManager
        return self
    }
    
    public func getBsanBillTaxesManager() -> SANLegacyLibrary.BSANBillTaxesManager {
        if let bsanBillTaxesManager = self.bsanBillTaxesManager {
            return bsanBillTaxesManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanPullOffersManager(bsanPullOffersManager: BSANPullOffersManager) -> BSANManagersProvider {
        self.bsanPullOffersManager = bsanPullOffersManager
        return self
    }

    public func getBsanSignatureManager() -> BSANSignatureManager {
        if let bsanSignatureManager = self.bsanSignatureManager {
            return bsanSignatureManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanSignatureManager(bsanSignatureManager: BSANSignatureManager) -> BSANManagersProvider {
        self.bsanSignatureManager = bsanSignatureManager
        return self
    }

    public func getBsanPersonDataManager() -> BSANPersonDataManager {
        if let bsanPersonDataManager = self.bsanPersonDataManager {
            return bsanPersonDataManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanPersonDataManager(bsanPersonDataManager: BSANPersonDataManager) -> BSANManagersProvider {
        self.bsanPersonDataManager = bsanPersonDataManager
        return self
    }
    
    public func getBsanTouchIdManager() -> BSANTouchIdManager {
        if let bsanTouchIdManager = self.bsanTouchIdManager {
            return bsanTouchIdManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanTouchIdManager(bsanTouchIdManager: BSANTouchIdManager) -> BSANManagersProvider {
        self.bsanTouchIdManager = bsanTouchIdManager
        return self
    }

    public func getBsanLoansManager() -> BSANLoansManager {
        if let bsanLoansManager = self.bsanLoansManager {
            return bsanLoansManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanLoansManager(bsanLoansManager: BSANLoansManager) -> BSANManagersProvider {
        self.bsanLoansManager = bsanLoansManager
        return self
    }

    public func getBsanFundsManager() -> BSANFundsManager {
        if let bsanFundsManager = self.bsanFundsManager {
            return bsanFundsManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanFundsManager(bsanFundsManager: BSANFundsManager) -> BSANManagersProvider {
        self.bsanFundsManager = bsanFundsManager
        return self
    }

    public func getBsanPensionsManager() -> BSANPensionsManager {
        if let bsanPensionsManager = self.bsanPensionsManager {
            return bsanPensionsManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanPensionsManager(bsanPensionsManager: BSANPensionsManager) -> BSANManagersProvider {
        self.bsanPensionsManager = bsanPensionsManager
        return self
    }
    
    public func getBsanCashWithdrawalManager() -> BSANCashWithdrawalManager {
        if let bsanCashWithdrawalManager = self.bsanCashWithdrawalManager {
            return bsanCashWithdrawalManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanCashWithdrawalManager(bsanCashWithdrawalManager: BSANCashWithdrawalManager) -> BSANManagersProvider {
        self.bsanCashWithdrawalManager = bsanCashWithdrawalManager
        return self
    }
    
    public func getBsanCesManager() -> BSANCesManager {
        if let bsanCesManager = self.bsanCesManager {
            return bsanCesManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanCesManager(bsanCesManager: BSANCesManager) -> BSANManagersProvider {
        self.bsanCesManager = bsanCesManager
        return self
    }
    
    public func getBsanMifidManager() -> BSANMifidManager {
        if let bsanMifidManager = self.bsanMifidManager {
            return bsanMifidManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setBsanMifidManager(bsanMifidManager: BSANMifidManager) -> BSANManagersProvider {
        self.bsanMifidManager = bsanMifidManager
        return self
    }
    
    public func setBsanOTPPushManager(bsanOTPPushManager: BSANOTPPushManager) -> BSANManagersProvider {
        self.bsanOTPPushManager = bsanOTPPushManager
        return self
    }
    
    public func getBsanOTPPushManager() -> BSANOTPPushManager {
        guard let bsanOTPPushManager = bsanOTPPushManager else {
            fatalError("\(#function) nil")
        }
        return bsanOTPPushManager
    }
    
    public func setBsanScaManager(bsanScaManager: BSANScaManager) -> BSANManagersProvider {
        self.bsanScaManager = bsanScaManager
        return self
    }
    
    public func getBsanScaManager() -> BSANScaManager {
        guard let bsanScaManager = bsanScaManager else {
            fatalError("\(#function) nil")
        }
        return bsanScaManager
    }
    
    public func getBsanPendingSolicitudesManager() -> BSANPendingSolicitudesManager {
        if let bsanPendingSolicitudesManager = self.bsanPendingSolicitudesManager {
            return bsanPendingSolicitudesManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func getTimeLineMovementsManager() -> BSANTimeLineManager {
        if let bsanTimeLineMngr = self.timelineMovementsManager {
            return bsanTimeLineMngr
        }
        fatalError("\(#function) nil")
    }
    
    public func setBsanPendingSolicitudesManager(bsanPendingSolicitudesManager: BSANPendingSolicitudesManager) -> BSANManagersProvider {
        self.bsanPendingSolicitudesManager = bsanPendingSolicitudesManager
        return self
    }
    
    public func setBSANLoanSimulatorManager(bsanLoanSimulatorManager: BSANLoanSimulatorManager) -> BSANManagersProvider {
        self.bsanLoanSimulatorManager = bsanLoanSimulatorManager
        return self
    }
    
    public func getBSANLoanSimulatorManager() -> BSANLoanSimulatorManager {
        if let bsanLoanSimulatorManager = self.bsanLoanSimulatorManager {
            return bsanLoanSimulatorManager
        }
        
        fatalError("\(#function) nil")
    }
    
    public func setTimeLineMovementsManager(_ manager: BSANTimeLineManager) -> BSANManagersProvider {
        self.timelineMovementsManager = manager
        return self
    }
    
    public func getBsanOnePlanManager() -> BSANOnePlanManager {
        guard let bsanOnePlanManager = bsanOnePlanManager else { fatalError("\(#function) nil") }
        return bsanOnePlanManager
    }
    
    public func setBSANOnePlanManager(_ manager: BSANOnePlanManager) -> BSANManagersProvider {
        self.bsanOnePlanManager = manager
        return self
    }
    
    public func getLastLogonManager() -> BSANLastLogonManager {
        guard let bsanLastLogonManger = self.lastLogonManager else { fatalError("\(#function) nil") }
        return bsanLastLogonManger
    }
    
    public func setLastLogonManager(_ manager: BSANLastLogonManager) -> BSANManagersProvider {
        self.lastLogonManager = manager
        return self
    }
    
    public func setFinancialAgregatorManager(_ manager: BSANFinancialAgregatorManager) -> BSANManagersProvider {
        self.financialAgregatorManager = manager
        return self
    }
    
    public func getFinancialAgregatorManager() -> BSANFinancialAgregatorManager {
        if let bsanFinancialAgregatorMngr = self.financialAgregatorManager {
            return bsanFinancialAgregatorMngr
        }
        fatalError("\(#function) nil")
	}

    public func getBSANBizumManager() -> BSANBizumManager {
        if let bsanBizumManager = self.bsanBizumManager {
            return bsanBizumManager
        }
        fatalError("\(#function) nil")
    }
    
    public func setBSANBizumManager(_ manager: BSANBizumManager) -> BSANManagersProvider {
        self.bsanBizumManager = manager
        return self
    }
    
    public func getManagerNotificationsManager() -> BSANManagerNotificationsManager {
        guard let bsanManagerNotificationManager = self.managerNotificationsManager else { fatalError("\(#function) nil") }
        return bsanManagerNotificationManager
    }
    
    public func setManagerNotificationsManager(_ manager: BSANManagerNotificationsManager) -> BSANManagersProvider {
        self.managerNotificationsManager = manager
        return self
    }
    
    public func getRecoveryNoticesManager() -> BSANRecoveryNoticesManager {
        guard let recoveryNoticesManager = self.recoveryNoticesManager else { fatalError("\(#function) nil") }
        return recoveryNoticesManager
    }
    
    public func setRecoveryNoticesManager(_ manager: BSANRecoveryNoticesManager) -> BSANManagersProvider {
        self.recoveryNoticesManager = manager
        return self
    }
    
    public func getBsanFavouriteTransfersManager() -> BSANFavouriteTransfersManager {
        guard let bsanFavouriteTransfersManager = self.bsanFavouriteTransfersManager else {
            fatalError("\(#function) nil")
        }
        return bsanFavouriteTransfersManager
    }
    
    public func setBsanFavouriteTransfersManager(_ bsanFavouriteTransfersManager: BSANFavouriteTransfersManager) -> BSANManagersProvider {
        self.bsanFavouriteTransfersManager = bsanFavouriteTransfersManager
        return self
    }
    
    public func getBsanAviosManager() -> SANLegacyLibrary.BSANAviosManager {
        guard let bsanAviosManager = self.bsanAviosManager else {
            fatalError("\(#function) nil")
            
        }
        return bsanAviosManager
    }
    
    public func setBsanAviosManager(_ bsanAviosManager: SANLegacyLibrary.BSANAviosManager) -> BSANManagersProvider {
        self.bsanAviosManager = bsanAviosManager
        return self
    }
    
    public func getBsanBranchLocatorManager() -> BSANBranchLocatorManager {
        guard let branchLocatorManager = self.bsanBranchLocatorManager else {
            fatalError("\(#function) nil")
        }
        return branchLocatorManager
    }
    
    public func setBsanBranchLocatorManager(_ branchLocatorManager: BSANBranchLocatorManager) -> BSANManagersProvider {
        self.bsanBranchLocatorManager = branchLocatorManager
        return self
    }
    
    public func getBsanEcommerceManager() -> BSANEcommerceManager {
        guard let bsanEcommerceManager = self.bsanEcommerceManager else {
            fatalError("\(#function) nil")
        }
        return bsanEcommerceManager
    }
    
    public func setBsanEcommerceManager(_ bsanEcommerceManager: BSANEcommerceManager) -> BSANManagersProvider {
        self.bsanEcommerceManager = bsanEcommerceManager
        return self
    }
    
    public func setBsanPredefineSCAManager(_ bsanPredefineSCAManager: BSANPredefineSCAManager) -> BSANManagersProvider {
        self.bsanPredefineSCAManager = bsanPredefineSCAManager
        return self
    }

    public func setBsanFintechManager(_ bsanFintechManager: BSANFintechManager) -> BSANManagersProvider {
        self.bsanFintechManager = bsanFintechManager
        return self
    }

    public func getBsanFintechManager() -> BSANFintechManager {
        guard let bsanFintechManager = self.bsanFintechManager else {
            fatalError("\(#function) nil")
        }
        return bsanFintechManager
    }

    public func getBsanPredefineSCAManager() -> BSANPredefineSCAManager {
        guard let bsanPredefineSCAManager = self.bsanPredefineSCAManager else {
            fatalError("\(#function) nil")
        }
        return bsanPredefineSCAManager
    }
    
    public func setBsanSignBasicOperationManager(_ bsanSignBasicOperationManager: BSANSignBasicOperationManager) -> BSANManagersProvider {
        self.bsanSignBasicOperationManager = bsanSignBasicOperationManager
        return self
    }
    
    public func getBsanSignBasicOperationManager() -> BSANSignBasicOperationManager {
        guard let bsanSignBasicOperationManager = self.bsanSignBasicOperationManager else {
            fatalError("\(#function) nil")
        }
        return bsanSignBasicOperationManager
    }
    
    public func setBsanSubscriptionManager(_ bsanSubscriptionManager: BSANSubscriptionManager) -> BSANManagersProvider {
        self.bsanSubscriptionManager = bsanSubscriptionManager
        return self
    }
    
    public func getBsanSubscriptionManager() -> BSANSubscriptionManager {
        guard let bsanSubscriptionManager = self.bsanSubscriptionManager else {
            fatalError("\(#function) nil")
        }
        return bsanSubscriptionManager
    }

}

class ServiceNameLanguage {
    private var specialLanguageServiceNames = [String]()
    private let specialLanguage = " io"

    func validLanguageForService(currentService: String, originalLanguage: String) -> String {
        return specialLanguageServiceNames.contains(currentService) ? specialLanguage : originalLanguage
    }
    
    func validLanguageForService(currentService: String, originalLanguage: String, dialectISO: String) -> String {
        if specialLanguageServiceNames.contains(currentService) {
            return specialLanguage + "-" + dialectISO
        } else {
            return originalLanguage
        }
    }
    
    func setSpecialLanguageServiceNames(_ serviceNames: [String]) {
        self.specialLanguageServiceNames = serviceNames
    }
}
