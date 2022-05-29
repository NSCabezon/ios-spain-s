import CoreFoundationLib

public protocol InboxActionBuilderProtocol {
    func addInboxActionViewModel(offerOnLine: OfferEntity?) -> [InboxActionViewModel]
    func addDelegate(_ delegate: InboxActionDelegate)
    func webViewConfigurationEnabled(_ isWebViewConfiguration: Bool?)
    func trackTapNotificationInbox(_ handler: @escaping () -> Void)
}

public protocol InboxActionDelegate: class {
    func didSelectSlideOffer(_ offer: OfferEntity?)
    func didSelectOffer(_ offer: OfferEntity?)
    func didSelectWebAction(_ inboxActionExtras: InboxActionExtras?)
    func gotoInboxNotification(_ inboxActionExtras: InboxActionExtras?)
    func didToast(_ inboxActionExtras: InboxActionExtras?)
}
