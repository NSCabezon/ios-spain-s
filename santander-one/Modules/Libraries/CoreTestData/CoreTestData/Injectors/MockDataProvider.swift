import SANLegacyLibrary
import CoreDomain
import CoreFoundationLib

public class MockDataProvider {
    public var accountData: MockAccountDataProvider
    public var gpData: MockGlobalPositionDataProvider
    public var loanSimulatorData: MockLoanSimulatorDataProvider
    public var scaData: MockScaDataProvider
    public var billAndTaxesData: MockBillAndTaxesDataProvider
    public var signatureData: MockSignatureDataProvider
    public var otpPushData: MockOTPPushDataProvider
    public var pullOffers: MockPullOffersManager
    public var authData: MockAuthDataProvider
    public var pendingSolicitudes: MockPendingSolicitudesDataProvider
    public var cardsData: MockCardDataProvider
    public var branchLocator: MockLBranchLocatorDataProvider
    public var comingFeatures: MockComingFeatureDataProvider
    public var faqs: MockFaqsDataProvider
    public var loadingTips: MockLoadingTipsProvider
    public var segmentedUser: MockSegmentedUserDataProvider
    public var tricks: MockTricksDataProvider
    public var pullOffersConfig: MockPullOffersConfigDataProvider
    public var appConfigLocalData: MockAppConfigLocalDataProvider
    public var bsanSignBasicData: MockBSANSignBasicDataProvider
    public var recoveryNoticiesData: MockRecoveryNoticiesDataProvider
    public var transferData: MockTransferDataProvider
    public var sepaInfo: MockSepaInfoDataProvider
    public var oapData: MockOapDataProvider
    public var loansData: MockLoansDataProvider
    public var savingProductsData: MockSavingProductDataProvider
    public var session: MockSessionDataProvider
    public var sendMoney: MockSendMoneyDataProvider
    public var userSegment: MockUserSegmentDataProvider
    public var commercialSegment: MockSegmentedUserRepository?
    public var reactivePullOffers: MockPullOffersDataProvider
    public var reactiveOffers: MockOffersDataProvider
    public var predefineSCA: MockBSANPredefineSCADataProvider
    public var carbonFootprint: MockBSANCarbonFootprintTokenProvider
    public var financialHealthData: MockFinancialHealthDataProvider
    public var userSessionFinancialHealthData: MockUserSessionFinancialHealthDataProvider
    public var personalAreaData: MockPersonalAreaDataProvider
    public var lastLoginData: MockLastLoginDataProvider
    
    public init() {
        self.accountData = MockAccountDataProvider()
        self.gpData = MockGlobalPositionDataProvider()
        self.loanSimulatorData = MockLoanSimulatorDataProvider()
        self.scaData = MockScaDataProvider()
        self.billAndTaxesData = MockBillAndTaxesDataProvider()
        self.signatureData = MockSignatureDataProvider()
        self.otpPushData = MockOTPPushDataProvider()
        self.pullOffers = MockPullOffersManager()
        self.authData = MockAuthDataProvider()
        self.pendingSolicitudes = MockPendingSolicitudesDataProvider()
        self.cardsData = MockCardDataProvider()
        self.branchLocator = MockLBranchLocatorDataProvider()
        self.comingFeatures = MockComingFeatureDataProvider()
        self.faqs = MockFaqsDataProvider()
        self.loadingTips = MockLoadingTipsProvider()
        self.segmentedUser = MockSegmentedUserDataProvider()
        self.tricks = MockTricksDataProvider()
        self.pullOffersConfig = MockPullOffersConfigDataProvider()
        self.appConfigLocalData = MockAppConfigLocalDataProvider()
        self.bsanSignBasicData = MockBSANSignBasicDataProvider()
        self.recoveryNoticiesData = MockRecoveryNoticiesDataProvider()
        self.transferData = MockTransferDataProvider()
        self.sepaInfo = MockSepaInfoDataProvider()
        self.oapData = MockOapDataProvider()
        self.loansData = MockLoansDataProvider()
        self.session = MockSessionDataProvider()
        self.sendMoney = MockSendMoneyDataProvider()
        self.userSegment = MockUserSegmentDataProvider()
        self.reactivePullOffers = MockPullOffersDataProvider()
        self.reactiveOffers = MockOffersDataProvider()
        self.predefineSCA = MockBSANPredefineSCADataProvider()
        self.carbonFootprint = MockBSANCarbonFootprintTokenProvider()
        self.savingProductsData = MockSavingProductDataProvider()
        self.financialHealthData = MockFinancialHealthDataProvider()
        self.userSessionFinancialHealthData = MockUserSessionFinancialHealthDataProvider()
        self.personalAreaData = MockPersonalAreaDataProvider()
        self.lastLoginData = MockLastLoginDataProvider()
    }
}
