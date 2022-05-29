import Foundation

enum AccountLandingType: String {
    case overdraft = "0024"
    case transaction = "0030"
    case bill = "0035"
    case lowerBalance = "0026"
    case emittedTransfer = "0028"
    
    func options(factory: AccountLandingOptionsFactory, preDeepLinkAction: (() -> Void)?) -> [GenericLandingPushOptionType] {
        var result = [GenericLandingPushOptionType]()
        factory.page = metricsPage
        factory.event = eventId
        factory.preDeepLinkAction = preDeepLinkAction
        switch self {
        case .bill:
            result.append(factory.billsQuery())
            result.append(factory.transfer())
            result.append(factory.manageAlerts())
            result.append(factory.moneyRequest())
        case .emittedTransfer:
            result.append(factory.newTransfer())
            result.append(factory.manageAlerts())
            result.append(factory.transfersHistory())
            result.append(factory.shopping())
        case .transaction:
            result.append(factory.transfer())
            result.append(factory.manageAlerts())
            result.append(factory.shopping())
        case .overdraft, .lowerBalance:
            result.append(factory.billsQuery())
            result.append(factory.transfer())
            result.append(factory.manageAlerts())
            result.append(factory.moneyRequest())
        }
        
        return result
    }
    
    var subtitleKey: String {
        switch self {
        case .overdraft:
            return "landingPush_label_0024"
        case .transaction:
            return "landingPush_label_0030"
        case .bill:
            return "landingPush_label_0035"
        case .lowerBalance:
            return "landingPush_label_0026"
        case .emittedTransfer:
            return "landingPush_label_0028"
        }
    }
    
    var metricsPage: String {
        switch self {
        case .overdraft:
            return TrackerPagePrivate.LandingPushOverdraft().page
        case .transaction:
            return TrackerPagePrivate.LandingPushAccountTransaction().page
        case .bill:
            return TrackerPagePrivate.LandingPushBill().page
        case .lowerBalance:
            return TrackerPagePrivate.LandingPushLowerBalance().page
        case .emittedTransfer:
            return TrackerPagePrivate.LandingPushEmittedTransfer().page
        }
    }
    
    var eventId: String {
        switch self {
        case .overdraft:
            return TrackerPagePrivate.LandingPushOverdraft.Action.deeplink.rawValue
        case .transaction:
            return TrackerPagePrivate.LandingPushAccountTransaction.Action.deeplink.rawValue
        case .bill:
            return TrackerPagePrivate.LandingPushBill.Action.deeplink.rawValue
        case .lowerBalance:
            return TrackerPagePrivate.LandingPushLowerBalance.Action.deeplink.rawValue
        case .emittedTransfer:
            return TrackerPagePrivate.LandingPushEmittedTransfer.Action.deeplink.rawValue
        }
    }
    
    var isAmountOutFromDetail: Bool {
        return [AccountLandingType.emittedTransfer, AccountLandingType.transaction].contains(self)
    }
    
    func accountInfoModel(stringLoader: StringLoader, accountTransactionInfo: AccountTransactionPush) -> [GenericLandingInfoLineType] {
        switch self {
        case .bill:
            return [.title(stringLoader.getString("landingPush_label_accountId")), .line(accountTransactionInfo.accountName, "***\(accountTransactionInfo.ccc)")]
        case .emittedTransfer:
            return [.line(accountTransactionInfo.accountName, "***\(accountTransactionInfo.ccc)")]
        case .transaction:
            return [.line(accountTransactionInfo.accountName, "***\(accountTransactionInfo.ccc)")]
        case .overdraft, .lowerBalance:
            return [.itemAndColumnTitle(accountTransactionInfo.accountName, stringLoader.getString("cardDetail_label_balance")), .itemAndAmount("***\(accountTransactionInfo.ccc)", accountTransactionInfo.amount)]
        }
    }
    
}
