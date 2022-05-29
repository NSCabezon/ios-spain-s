import SANLibraryV3

struct BSANManagersProviderBuilder {
    let bsanDataProvider: BSANDataProvider
    let targetProvider: TargetProvider
    
    func build() -> BSANManagersProvider {
        let sanSoapServicesImpl = SanSoapServicesImpl(callExecutor: targetProvider.getSoapCallExecutorProvider(), demoExecutor: targetProvider.getSoapDemoExecutorProvider(), bsanDataProvider: bsanDataProvider)
        let sanRestServiceImpl = SanRestServicesImpl(callExecutor: targetProvider.getRestCallExecutorProvider(), demoExecutor: targetProvider.getRestDemoExecutorProvider(), bsanDataProvider: bsanDataProvider)
        let sanJsonRestServicesImpl = SanRestServicesImpl(callExecutor: targetProvider.getRestCallJsonExecutorProvider(), demoExecutor: targetProvider.getRestDemoExecutorProvider(), bsanDataProvider: bsanDataProvider)

        let authDataSourceImpl = AuthDataSourceImpl(sanRestServices: sanRestServiceImpl)
        let authManager = BSANAuthManagerImplementation(sanSoapServices: sanSoapServicesImpl, sanRestServices: sanRestServiceImpl, bsanDataProvider: bsanDataProvider, authDataSource: authDataSourceImpl, webServicesUrlProvider: targetProvider.webServicesUrlProvider)
        let recoveryNoticesManager = BSANRecoveryNoticesManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl)
        let managerProvider = BSANManagersProvider()
            .setRecoveryNoticesManager(recoveryNoticesManager)
            .setBSANAuthManager(bsanAuthManager: authManager)
            .setBSANPGManager(bsanPGManager: BSANPGManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanTouchIdManager(bsanTouchIdManager: BSANTouchIdManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBSANEnvironmentsManager(bsanEnvironmentsManager: BSANEnvironmentsManagerImplementation(bsanHostProvider: HostModule.providesBSANHostProvider(), bsanDataProvider: bsanDataProvider))
            .setBsanAccountsManager(bsanAccountsManager: BSANAccountsManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl, sanRestServices: sanJsonRestServicesImpl))
            .setBsanCardsManager(bsanCardsManager: BSANCardsManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl, sanRestServices: sanJsonRestServicesImpl))
            .setBsanPensionsManager(bsanPensionsManager: BSANPensionsManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBSANDepositsManager(bsanDepositsManager: BSANDepositsManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanLoansManager(bsanLoansManager: BSANLoansManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanFundsManager(bsanFundsManager: BSANFundsManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanSignatureManager(bsanSignatureManager: BSANSignatureManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanPullOffersManager(bsanPullOffersManager: BSANPullOffersManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanPortfoliosPBManager(bsanPortfoliosPBManager: BSANPortfoliosPBManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanSendMoneyManager(bsanSendMoneyManager: BSANSendMoneyManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanTransfersManager(bsanTransfersManager: BSANTransfersManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl, sanRestServices: sanJsonRestServicesImpl))
            .setBsanPersonDataManager(bsanPersonDataManager: BSANPersonDataManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanSociusManager(bsanSociusManager: BSANSociusManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanManagersManager(bsanManagersManager: BSANManagersManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl, sanRestServices: sanJsonRestServicesImpl))
            .setBSANSessionManager(bsanSessionManager: BSANSessionManagerImplementation(bsanDataProvider: bsanDataProvider))
            .setBsanUserSegmentManager(bsanUserSegmentManager: BSANUserSegmentManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanInsurancesManager(bsanInsurancesManager: BSANInsurancesManagerImplementation(bsanDataProvider: bsanDataProvider, bsanAuthManager: authManager, sanRestServices: sanRestServiceImpl, webServicesUrlProvider: targetProvider.webServicesUrlProvider))
            .setBsanStocksManager(bsanStocksManager: BSANStocksManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanBillTaxesManager(bsanBillTaxesManager: BSANBillTaxesManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl, sanRestServices: sanJsonRestServicesImpl))
            .setBsanMobileRechargeManager(bsanMobileRechargeManager: BSANMobileRechargeManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanCashWithdrawalManager(bsanCashWithdrawalManager: BSANCashWithdrawalManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanCesManager(bsanCesManager: BSANCesManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanMifidManager(bsanMifidManager: BSANMifidManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanOTPPushManager(bsanOTPPushManager: BSANOTPPushManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBsanScaManager(bsanScaManager: BSANScaManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setBSANLoanSimulatorManager(bsanLoanSimulatorManager: BSANLoanSimulatorManagerImplementation(bsanDataProvider: bsanDataProvider, bsanAuthManager: authManager, sanRestServices: sanJsonRestServicesImpl))
            .setBsanPendingSolicitudesManager(bsanPendingSolicitudesManager: BSANPendingSolicitudesManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setTimeLineMovementsManager(BSANTimeLineManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setBSANOnePlanManager(BSANOnePlanManagerImplementation(bsanDataProvider: bsanDataProvider, sanSoapServices: sanSoapServicesImpl))
            .setLastLogonManager(BSANLastLogonManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setBSANBizumManager(BSANBizumManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setFinancialAgregatorManager(BSANFinancialAgregatorManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setBsanBranchLocatorManager(BSANBranchLocatorManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanRestServiceImpl))
            .setBsanAviosManager(BSANAviosManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setRecoveryNoticesManager(BSANRecoveryNoticesManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setBsanEcommerceManager(BSANEcommerceManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setBsanFintechManager(BSANFintechManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanJsonRestServicesImpl))
            .setBsanSignBasicOperationManager(BSANSignBasicOperationManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanRestServiceImpl))
            .setBsanSubscriptionManager(BSANSubscriptionManagerImplementation(bsanDataProvider: bsanDataProvider, sanRestServices: sanRestServiceImpl))
        return managerProvider
    }
}
