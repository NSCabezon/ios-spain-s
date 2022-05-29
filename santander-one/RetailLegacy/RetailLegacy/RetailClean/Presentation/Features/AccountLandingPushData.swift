import Foundation
import CoreFoundationLib

class AccountLandingPushData {
    private let accountTransactionInfo: AccountTransactionPush
    private let alertInfo: AlertInfoType
    private let landingType: AccountLandingType
    var navigator: UrlActionsCapable?
    private let deepLinkManager: DeepLinkManagerProtocol
    private let stringLoader: StringLoader
    private let trackerManager: TrackerManager
    private let dependenciesResolver: DependenciesResolver
    private lazy var landingFactory = AccountLandingOptionsFactory(
        deepLinkManager: deepLinkManager,
        stringLoader: stringLoader,
        trackerManager: trackerManager,
        dependenciesResolver: dependenciesResolver
    )
    
    init?(accountTransactionInfo: AccountTransactionPush, alertInfo: AlertInfoType, stringLoader: StringLoader, deepLinkManager: DeepLinkManager, trackerManager: TrackerManager, dependenciesResolver: DependenciesResolver) {
        guard let landingType = AccountLandingType(rawValue: alertInfo.name) else {
            return nil
        }
        self.accountTransactionInfo = accountTransactionInfo
        self.alertInfo = alertInfo
        self.landingType = landingType
        self.deepLinkManager = deepLinkManager
        self.stringLoader = stringLoader
        self.trackerManager = trackerManager
        self.dependenciesResolver = dependenciesResolver
    }
    
    init?(bridgedInfo: AccountLandingPushDataBridge) {
        guard let landingType = AccountLandingType(rawValue: bridgedInfo.alertInfo.name) else {
            return nil
        }
        self.accountTransactionInfo = AccountTransactionPush(accountTransactionInfo: bridgedInfo.accountTransactionInfo)
        self.alertInfo = bridgedInfo.alertInfo
        self.landingType = landingType
        self.deepLinkManager = bridgedInfo.deepLinkManager
        self.stringLoader = bridgedInfo.stringLoader
        self.trackerManager = bridgedInfo.trackerManager
        self.dependenciesResolver = bridgedInfo.dependenciesResolver
    }
    
    func createLandingOptions(preDeepLinkAction: @escaping () -> Void) -> [GenericLandingPushOptionType] {
        return landingType.options(factory: landingFactory, preDeepLinkAction: preDeepLinkAction)
    }
    
    var amount: String? {
        return accountTransactionInfo.amount
    }
    
    var screenId: String {
        return landingType.metricsPage
    }
    
    func headerModel() -> GenericLandingPushHeader {
        let amountToDisplay = landingType.isAmountOutFromDetail ? amount : nil
        let header = GenericLandingPushHeader(title: nil, subtitle: stringLoader.getString(landingType.subtitleKey), amount: amountToDisplay, detailInfo: landingType.accountInfoModel(stringLoader: stringLoader, accountTransactionInfo: accountTransactionInfo))
        
        return header
    }
}
