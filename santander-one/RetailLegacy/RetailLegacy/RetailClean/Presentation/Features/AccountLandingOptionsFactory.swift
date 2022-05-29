import Foundation
import CoreFoundationLib

class AccountLandingOptionsFactory {
    
    private let deepLinkManager: DeepLinkManagerProtocol
    private let trackerManager: TrackerManager
    private let stringLoader: StringLoader
    private let dependenciesResolver: DependenciesResolver
    
    var page: String?
    var event: String?
    var preDeepLinkAction: (() -> Void)?
    
    init(deepLinkManager: DeepLinkManagerProtocol, stringLoader: StringLoader, trackerManager: TrackerManager, dependenciesResolver: DependenciesResolver) {
        self.deepLinkManager = deepLinkManager
        self.stringLoader = stringLoader
        self.trackerManager = trackerManager
        self.dependenciesResolver = dependenciesResolver
    }
    
    func track(deeplink: DeepLink) {
        guard let trackerId = deeplink.trackerId else { return }
        trackerManager.trackEvent(screenId: page ?? "", eventId: event ?? "", extraParameters: [TrackerDimensions.deeplinkLogin: trackerId])
    }
    
    func billsQuery() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_consultReceipt"), imageKey: "icnViewBillsBlue") { [weak self] in
            let deeplink: DeepLink = DeepLink.billsAndTaxesPay
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
    
    func transfer() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_doingOnePay"), imageKey: "icnOnePayBlue") { [weak self] in
            let deeplink: DeepLink = DeepLink.nationalTransfer
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
    
    func newTransfer() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_newOnePay"), imageKey: "icnOnePayBlue") { [weak self] in
            let deeplink: DeepLink = DeepLink.nationalTransfer
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
    
    func manageAlerts() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_settingsAlerts"), imageKey: "icnAlertsBlue") { [weak self] in
            let deeplink: DeepLink = DeepLink.offerLink(identifier: "Conf_Alertas", location: nil)
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
    
    func moneyRequest() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_requestMoney"), imageKey: "icnBizumBlue") { [weak self] in
            guard let deeplink = DeepLink("bizum") else { return }
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
    
    func transfersHistory() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_historyOnePay"), imageKey: "icnLogOnePayBlue") { [weak self] in
            let deeplink: DeepLink = DeepLink.transfer
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
    
    func shopping() -> GenericLandingOption {
        return GenericLandingOption(title: stringLoader.getString("landingPush_label_shoppingSantander"), imageKey: "icnShoppingBlue") { [weak self] in
            let deeplink: DeepLink = DeepLink.marketplace
            self?.preDeepLinkAction?()
            self?.deepLinkManager.registerDeepLink(deeplink)
            self?.track(deeplink: deeplink)
        }
    }
}
