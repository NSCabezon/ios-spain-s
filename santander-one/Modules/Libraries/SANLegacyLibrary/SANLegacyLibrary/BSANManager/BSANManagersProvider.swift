//
//  BSANManagersProvider.swift
//  SANLegacyLibrary
//
//  Created by Victor Carrilero García on 08/01/2021.
//

import Foundation

public protocol BSANManagersProvider {
    func getBsanAuthManager() -> BSANAuthManager
    func getBsanPGManager() -> BSANPGManager
    func getBsanDepositsManager() -> BSANDepositsManager
    func getBsanEnvironmentsManager() -> BSANEnvironmentsManager
    func getBsanSessionManager() -> BSANSessionManager
    func getBsanInsurancesManager() -> BSANInsurancesManager
    func getBsanCardsManager() -> BSANCardsManager
    func getBsanUserSegmentManager() -> BSANUserSegmentManager
    func getBsanPortfoliosPBManager() -> BSANPortfoliosPBManager
    func getBsanAccountsManager() -> BSANAccountsManager
    func getBsanManagersManager() -> BSANManagersManager
    func getBsanSociusManager() -> BSANSociusManager
    func getBsanTransfersManager() -> BSANTransfersManager
    func getBsanSendMoneyManager() -> BSANSendMoneyManager
    func getBsanMobileRechargeManager() -> BSANMobileRechargeManager
    func getBsanStocksManager() -> BSANStocksManager
    func getBsanPullOffersManager() -> BSANPullOffersManager
    func getBsanBillTaxesManager() -> BSANBillTaxesManager
    func getBsanSignatureManager() -> BSANSignatureManager
    func getBsanPersonDataManager() -> BSANPersonDataManager
    func getBsanTouchIdManager() -> BSANTouchIdManager
    func getBsanLoansManager() -> BSANLoansManager
    func getBsanFundsManager() -> BSANFundsManager
    func getBsanPensionsManager() -> BSANPensionsManager
    func getBsanCashWithdrawalManager() -> BSANCashWithdrawalManager
    func getBsanCesManager() -> BSANCesManager
    func getBsanMifidManager() -> BSANMifidManager
    func getBsanOTPPushManager() -> BSANOTPPushManager
    func getBsanScaManager() -> BSANScaManager
    func getTimeLineMovementsManager() -> BSANTimeLineManager
    func getBSANLoanSimulatorManager() -> BSANLoanSimulatorManager
    func getBsanOnePlanManager() -> BSANOnePlanManager
    func getLastLogonManager() -> BSANLastLogonManager
    func getFinancialAgregatorManager() -> BSANFinancialAgregatorManager
    func getBSANBizumManager() -> BSANBizumManager
    func getManagerNotificationsManager() -> BSANManagerNotificationsManager
    func getRecoveryNoticesManager() -> BSANRecoveryNoticesManager
    func getBsanFavouriteTransfersManager() -> BSANFavouriteTransfersManager
    func getBsanAviosManager() -> BSANAviosManager
    func getBsanBranchLocatorManager() -> BSANBranchLocatorManager
    func getBsanPendingSolicitudesManager() -> BSANPendingSolicitudesManager
    func getBsanEcommerceManager() -> BSANEcommerceManager
    func getBsanPredefineSCAManager() -> BSANPredefineSCAManager
    func getBsanSignBasicOperationManager() -> BSANSignBasicOperationManager
    func getBsanFintechManager() -> BSANFintechManager
    func getBsanSubscriptionManager() -> BSANSubscriptionManager
}
