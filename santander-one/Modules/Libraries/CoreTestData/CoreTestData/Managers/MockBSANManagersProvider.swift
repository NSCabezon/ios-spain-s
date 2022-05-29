import SANLegacyLibrary

public struct MockBSANManagersProvider: BSANManagersProvider {
    private var bsanAccountsManager: BSANAccountsManager!
    private var bsanAuthManager: BSANAuthManager!
    private var bsanCardsManager: BSANCardsManager!
    private var bsanDepositsManager: BSANDepositsManager!
    private var bsanEnvironmentsManager: BSANEnvironmentsManager!
    private var bsanFundsManager: BSANFundsManager!
    private var bsanInsurancesManager: BSANInsurancesManager!
    private var bsanLoansManager: BSANLoansManager!
    private var bsanManagersManager: BSANManagersManager!
    private var bsanMobileRechargeManager: BSANMobileRechargeManager!
    private var bsanPensionsManager: BSANPensionsManager!
    private var bsanPersonDataManager: BSANPersonDataManager!
    private var bsanPGManager: BSANPGManager!
    private var bsanPortfoliosPBManager: BSANPortfoliosPBManager!
    private var bsanPullOffersManager: BSANPullOffersManager!
    private var bsanSendMoneyManager: BSANSendMoneyManager!
    private var bsanSessionManager: BSANSessionManager!
    private var bsanSignatureManager: BSANSignatureManager!
    private var bsanSociusManager: BSANSociusManager!
    private var bsanStocksManager: BSANStocksManager!
    private var bsanBillTaxesManager: BSANBillTaxesManager!
    private var bsanTouchIdManager: BSANTouchIdManager!
    private var bsanTransfersManager: BSANTransfersManager!
    private var bsanUserSegmentManager: BSANUserSegmentManager!
    private var bsanCashWithdrawalManager: BSANCashWithdrawalManager!
    private var bsanCesManager: BSANCesManager!
    private var bsanMifidManager: BSANMifidManager!
    private var bsanOTPPushManager: BSANOTPPushManager!
    private var bsanScaManager: BSANScaManager!
    private var bsanPendingSolicitudesManager: BSANPendingSolicitudesManager!
    private var bsanLoanSimulatorManager: BSANLoanSimulatorManager!
    private var timelineMovementsManager: BSANTimeLineManager!
    private var bsanOnePlanManager: BSANOnePlanManager!
    private var lastLogonManager: BSANLastLogonManager!
    private var financialAgregatorManager: BSANFinancialAgregatorManager!
    private var bsanBizumManager: BSANBizumManager!
    private var managerNotificationsManager: BSANManagerNotificationsManager!
    private var recoveryNoticesManager: BSANRecoveryNoticesManager!
    private var bsanFavouriteTransfersManager: BSANFavouriteTransfersManager!
    private var bsanAviosManager: BSANAviosManager!
    private var bsanBranchLocatorManager: BSANBranchLocatorManager!
    private var bsanEcommerceManager: BSANEcommerceManager!
    private var bsanPredefineSCAManager: BSANPredefineSCAManager!
    private var bsanFintechManager: BSANFintechManager!
    private var bsanSignBasicOperationManager: BSANSignBasicOperationManager!
    private var bsanSubscriptionManager: BSANSubscriptionManager!
    
    public init(
        bsanAccountsManager: BSANAccountsManager? = nil,
        bsanAuthManager: BSANAuthManager? = nil,
        bsanCardsManager: BSANCardsManager? = nil,
        bsanDepositsManager: BSANDepositsManager? = nil,
        bsanEnvironmentsManager: BSANEnvironmentsManager? = nil,
        bsanFundsManager: BSANFundsManager? = nil,
        bsanInsurancesManager: BSANInsurancesManager? = nil,
        bsanLoansManager: BSANLoansManager? = nil,
        bsanManagersManager: BSANManagersManager? = nil,
        bsanMobileRechargeManager: BSANMobileRechargeManager? = nil,
        bsanPensionsManager: BSANPensionsManager? = nil,
        bsanPersonDataManager: BSANPersonDataManager? = nil,
        bsanPGManager: BSANPGManager? = nil,
        bsanPortfoliosPBManager: BSANPortfoliosPBManager? = nil,
        bsanPullOffersManager: BSANPullOffersManager? = nil,
        bsanSendMoneyManager: BSANSendMoneyManager? = nil,
        bsanSessionManager: BSANSessionManager? = nil,
        bsanSignatureManager: BSANSignatureManager? = nil,
        bsanSociusManager: BSANSociusManager? = nil,
        bsanStocksManager: BSANStocksManager? = nil,
        bsanBillTaxesManager: BSANBillTaxesManager? = nil,
        bsanTouchIdManager: BSANTouchIdManager? = nil,
        bsanTransfersManager: BSANTransfersManager? = nil,
        bsanUserSegmentManager: BSANUserSegmentManager? = nil,
        bsanCashWithdrawalManager: BSANCashWithdrawalManager? = nil,
        bsanCesManager: BSANCesManager? = nil,
        bsanMifidManager: BSANMifidManager? = nil,
        bsanOTPPushManager: BSANOTPPushManager? = nil,
        bsanScaManager: BSANScaManager? = nil,
        bsanPendingSolicitudesManager: BSANPendingSolicitudesManager? = nil,
        bsanLoanSimulatorManager: BSANLoanSimulatorManager? = nil,
        timelineMovementsManager: BSANTimeLineManager? = nil,
        bsanOnePlanManager: BSANOnePlanManager? = nil,
        lastLogonManager: BSANLastLogonManager? = nil,
        financialAgregatorManager: BSANFinancialAgregatorManager? = nil,
        bsanBizumManager: BSANBizumManager? = nil,
        managerNotificationsManager: BSANManagerNotificationsManager? = nil,
        recoveryNoticesManager: BSANRecoveryNoticesManager? = nil,
        bsanFavouriteTransfersManager: BSANFavouriteTransfersManager? = nil,
        bsanAviosManager: BSANAviosManager? = nil,
        bsanBranchLocatorManager: BSANBranchLocatorManager? = nil,
        bsanEcommerceManager: BSANEcommerceManager? = nil,
        bsanPredefineSCAManager: BSANPredefineSCAManager? = nil,
        bsanFintechManager: BSANFintechManager? = nil,
        bsanSignBasicOperationManager: BSANSignBasicOperationManager? = nil,
        bsanSubscriptionManager: BSANSubscriptionManager? = nil
    ) {
        self.bsanAccountsManager = bsanAccountsManager
        self.bsanAuthManager = bsanAuthManager
        self.bsanCardsManager = bsanCardsManager
        self.bsanDepositsManager = bsanDepositsManager
        self.bsanEnvironmentsManager = bsanEnvironmentsManager
        self.bsanInsurancesManager = bsanInsurancesManager
        self.bsanLoansManager = bsanLoansManager
        self.bsanManagersManager = bsanManagersManager
        self.bsanMobileRechargeManager = bsanMobileRechargeManager
        self.bsanPensionsManager = bsanPensionsManager
        self.bsanPersonDataManager = bsanPersonDataManager
        self.bsanPGManager = bsanPGManager
        self.bsanPortfoliosPBManager = bsanPortfoliosPBManager
        self.bsanPullOffersManager = bsanPullOffersManager
        self.bsanSendMoneyManager = bsanSendMoneyManager
        self.bsanSessionManager = bsanSessionManager
        self.bsanSignatureManager = bsanSignatureManager
        self.bsanSociusManager = bsanSociusManager
        self.bsanStocksManager = bsanStocksManager
        self.bsanBillTaxesManager = bsanBillTaxesManager
        self.bsanTouchIdManager = bsanTouchIdManager
        self.bsanTransfersManager = bsanTransfersManager
        self.bsanUserSegmentManager = bsanUserSegmentManager
        self.bsanCashWithdrawalManager = bsanCashWithdrawalManager
        self.bsanCesManager = bsanCesManager
        self.bsanMifidManager = bsanMifidManager
        self.bsanOTPPushManager = bsanOTPPushManager
        self.bsanScaManager = bsanScaManager
        self.bsanPendingSolicitudesManager = bsanPendingSolicitudesManager
        self.bsanLoanSimulatorManager = bsanLoanSimulatorManager
        self.timelineMovementsManager = timelineMovementsManager
        self.bsanOnePlanManager = bsanOnePlanManager
        self.lastLogonManager = lastLogonManager
        self.financialAgregatorManager = financialAgregatorManager
        self.bsanBizumManager = bsanBizumManager
        self.managerNotificationsManager = managerNotificationsManager
        self.recoveryNoticesManager = recoveryNoticesManager
        self.bsanFavouriteTransfersManager = bsanFavouriteTransfersManager
        self.bsanAviosManager = bsanAviosManager
        self.bsanBranchLocatorManager = bsanBranchLocatorManager
        self.bsanEcommerceManager = bsanEcommerceManager
        self.bsanPredefineSCAManager = bsanPredefineSCAManager
        self.bsanFintechManager = bsanFintechManager
        self.bsanSignBasicOperationManager = bsanSignBasicOperationManager
        self.bsanSubscriptionManager = bsanSubscriptionManager
    }
    
    public static func build(from mockDataInjector: MockDataInjector) -> MockBSANManagersProvider {
        self.init(
            bsanAccountsManager: MockBSANAccountsManager(mockDataInjector: mockDataInjector),
            bsanAuthManager: MockBSANAuthManager(mockDataInjector: mockDataInjector),
            bsanCardsManager: MockBSANCardsManager(mockDataInjector: mockDataInjector),
            bsanLoansManager: MockBSANLoansManager(mockDataInjector: mockDataInjector),
            bsanPersonDataManager: MockBSANPersonDataManager(mockDataInjector: mockDataInjector),
            bsanPGManager: MockBSANPGManager(mockDataInjector: mockDataInjector),
            bsanPullOffersManager: MockBSANPullOffersManager(mockDataInjector: mockDataInjector),
            bsanSendMoneyManager: MockBSANSendMoneyManager(mockDataInjector: mockDataInjector),
            bsanSessionManager: MockBSANSessionManager(mockDataInjector: mockDataInjector),
            bsanSignatureManager: MockBSANSignatureManager(mockDataInjector: mockDataInjector),
            bsanBillTaxesManager: MockBSANBillTaxesManager(mockDataInjector: mockDataInjector),
            bsanTransfersManager: MockBSANTransfersManager(mockDataInjector: mockDataInjector),
            bsanUserSegmentManager: MockBSANUserSegmentManager(mockInjector: mockDataInjector),
            bsanOTPPushManager: MockBSANOTPPushManager(mockDataInjector: mockDataInjector),
            bsanScaManager: MockBSANScaManager(mockDataInjector: mockDataInjector),
            bsanPendingSolicitudesManager: MockBSANPendingSolicitudesManager(mockDataInjector: mockDataInjector),
            bsanLoanSimulatorManager: MockBSANLoanSimulatorManager(mockDataInjector: mockDataInjector),
            lastLogonManager: MockBSANLastLogonManager(mockDataInjector: mockDataInjector),
            recoveryNoticesManager: MockBSANRecoveryNoticesManager(mockDataInjector: mockDataInjector),
            bsanAviosManager: MockBSANAviosManager(mockDataInjector: mockDataInjector),
            bsanBranchLocatorManager: MockBSANBranchLocatorManager(mockDataInjector: mockDataInjector),
            bsanPredefineSCAManager: MockBSANPredefineSCAManager(mockDataInjector: mockDataInjector),
            bsanSignBasicOperationManager: MockBSANSignBasicOperationManager(mockDataInjector: mockDataInjector),
            bsanSubscriptionManager: MockBSANSubscriptionManager(mockDataInjector: mockDataInjector)
        )
    }
    
    public func getBsanAuthManager() -> BSANAuthManager {
        return self.bsanAuthManager
    }
    
    public func getBsanPGManager() -> BSANPGManager {
        return self.bsanPGManager
    }
    
    public func getBsanDepositsManager() -> BSANDepositsManager {
        return self.bsanDepositsManager
    }
    
    public func getBsanEnvironmentsManager() -> BSANEnvironmentsManager {
        return self.bsanEnvironmentsManager
    }
    
    public func getBsanSessionManager() -> BSANSessionManager {
        return self.bsanSessionManager
    }
    
    public func getBsanInsurancesManager() -> BSANInsurancesManager {
        return self.bsanInsurancesManager
    }
    
    public func getBsanCardsManager() -> BSANCardsManager {
        return self.bsanCardsManager
    }
    
    public func getBsanUserSegmentManager() -> BSANUserSegmentManager {
        return self.bsanUserSegmentManager
    }
    
    public func getBsanPortfoliosPBManager() -> BSANPortfoliosPBManager {
        return self.bsanPortfoliosPBManager
    }
    
    public func getBsanAccountsManager() -> BSANAccountsManager {
        return self.bsanAccountsManager
    }
    
    public func getBsanManagersManager() -> BSANManagersManager {
        return self.bsanManagersManager
    }
    
    public func getBsanSociusManager() -> BSANSociusManager {
        return self.bsanSociusManager
    }
    
    public func getBsanTransfersManager() -> BSANTransfersManager {
        return self.bsanTransfersManager
    }
    
    public func getBsanSendMoneyManager() -> BSANSendMoneyManager {
        return self.bsanSendMoneyManager
    }
    
    public func getBsanMobileRechargeManager() -> BSANMobileRechargeManager {
        return self.bsanMobileRechargeManager
    }
    
    public func getBsanStocksManager() -> BSANStocksManager {
        return self.bsanStocksManager
    }
    
    public func getBsanPullOffersManager() -> BSANPullOffersManager {
        return self.bsanPullOffersManager
    }
    
    public func getBsanBillTaxesManager() -> BSANBillTaxesManager {
        return self.bsanBillTaxesManager
    }
    
    public func getBsanSignatureManager() -> BSANSignatureManager {
        return self.bsanSignatureManager
    }
    
    public func getBsanPersonDataManager() -> BSANPersonDataManager {
        return self.bsanPersonDataManager
    }
    
    public func getBsanTouchIdManager() -> BSANTouchIdManager {
        return self.bsanTouchIdManager
    }
    
    public func getBsanLoansManager() -> BSANLoansManager {
        return self.bsanLoansManager
    }
    
    public func getBsanFundsManager() -> BSANFundsManager {
        return self.bsanFundsManager
    }
    
    public func getBsanPensionsManager() -> BSANPensionsManager {
        return self.bsanPensionsManager
    }
    
    public func getBsanCashWithdrawalManager() -> BSANCashWithdrawalManager {
        return self.bsanCashWithdrawalManager
    }
    
    public func getBsanCesManager() -> BSANCesManager {
        return self.bsanCesManager
    }
    
    public func getBsanMifidManager() -> BSANMifidManager {
        return self.bsanMifidManager
    }
    
    public func getBsanOTPPushManager() -> BSANOTPPushManager {
        return self.bsanOTPPushManager
    }
    
    public func getBsanScaManager() -> BSANScaManager {
        return self.bsanScaManager
    }
    
    public func getTimeLineMovementsManager() -> BSANTimeLineManager {
        return self.timelineMovementsManager
    }
    
    public func getBSANLoanSimulatorManager() -> BSANLoanSimulatorManager {
        return self.bsanLoanSimulatorManager
    }
    
    public func getBsanOnePlanManager() -> BSANOnePlanManager {
        return self.bsanOnePlanManager
    }
    
    public func getLastLogonManager() -> BSANLastLogonManager {
        return self.lastLogonManager
    }
    
    public func getFinancialAgregatorManager() -> BSANFinancialAgregatorManager {
        return self.financialAgregatorManager
    }
    
    public func getBSANBizumManager() -> BSANBizumManager {
        return self.bsanBizumManager
    }
    
    public func getManagerNotificationsManager() -> BSANManagerNotificationsManager {
        return self.managerNotificationsManager
    }
    
    public func getRecoveryNoticesManager() -> BSANRecoveryNoticesManager {
        return self.recoveryNoticesManager
    }
    
    public func getBsanFavouriteTransfersManager() -> BSANFavouriteTransfersManager {
        return self.bsanFavouriteTransfersManager
    }
    
    public func getBsanAviosManager() -> BSANAviosManager {
        return self.bsanAviosManager
    }
    
    public func getBsanBranchLocatorManager() -> BSANBranchLocatorManager {
        return self.bsanBranchLocatorManager
    }
    
    public func getBsanPendingSolicitudesManager() -> BSANPendingSolicitudesManager {
        return self.bsanPendingSolicitudesManager
    }
    
    public func getBsanEcommerceManager() -> BSANEcommerceManager {
        return self.bsanEcommerceManager
    }
    
    public func getBsanPredefineSCAManager() -> BSANPredefineSCAManager {
        return self.bsanPredefineSCAManager
    }
    
    public func getBsanSignBasicOperationManager() -> BSANSignBasicOperationManager {
        return self.bsanSignBasicOperationManager
    }
    
    public func getBsanFintechManager() -> BSANFintechManager {
        return self.bsanFintechManager
    }
    
    public func getBsanSubscriptionManager() -> BSANSubscriptionManager {
        return self.bsanSubscriptionManager
    }
    
    public mutating func setBsanLoansManager(manager: BSANLoansManager) {
        self.bsanLoansManager = manager
    }
}
