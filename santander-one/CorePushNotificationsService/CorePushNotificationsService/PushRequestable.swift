//
//  PushRequestable.swift
//  CorePushNotificationsService
import CoreFoundationLib

/// Model incoming push notifications redirected to Core from country app

/// Convert the userInfo notification to a type adopting this protocol
public protocol PushRequestable {
    var userInfo: [AnyHashable: Any] { get }
    var date: Date { get }
    var didReceiveRequestAction: PushDidReceiveRequestAction? { get }
    var willPresentRequestAction: PushWillPresentRequestAction? { get }
    var executableType: PushExecutableType? { get }
}

/**
 A request type offered by Core
 
 launchAction: an action that launch a navigation or presents a screen. @See PushLaunchActionType
 otp: a notification that will be processed as otp
 
 */
public enum PushDidReceiveRequestAction {
    case launchAction(type: PushLaunchActionType)
}

extension PushDidReceiveRequestAction: Equatable {
    public static func ==(lhs: PushDidReceiveRequestAction, rhs: PushDidReceiveRequestAction) -> Bool {
        switch (lhs, rhs) {
        case (let .launchAction(lhsLaunchType), let .launchAction(rhsLaunchType)):
            return lhsLaunchType == rhsLaunchType
        }
    }
}

public enum PushWillPresentRequestAction: Equatable {
    case otp
}

/**
 Launch Action types:
 
 dialog: Open a dialog with certain settings
 webview: Open a local webview
 extUrl: Open an external url using the string passed as parameter
 cardTransaction:
 accountTransaction:
 deeplink: open a deeplink
 
 */
public enum PushLaunchActionType {
    case dialog(PushDialogSettings)
    case webview(PushWebviewSettings)
    case extUrl(String)
    case cardTransaction(CardTransactionPush?, CardAlertPush?)
    case accountTransaction(AccountTransactionPushProtocol?, CardAlertPush?)
    case deeplink(DeepLinkEnumerationCapable)
    case custom(CustomPushLaunchActionTypeCapable)
}

extension PushLaunchActionType: Equatable {
    public static func ==(lhs: PushLaunchActionType, rhs: PushLaunchActionType) -> Bool {
        switch (lhs, rhs) {
        case (let .dialog(lhsDialogSettings), let .dialog(rhsDialogSettings)):
            return lhsDialogSettings.title == rhsDialogSettings.title
                && lhsDialogSettings.message == rhsDialogSettings.message
        case (.webview, .webview):
            return true
        case (let .extUrl(lhsUrlString), let .extUrl(rhsUrlString)):
            return lhsUrlString == rhsUrlString
        case (.cardTransaction, .cardTransaction):
            return true
        case (.accountTransaction, .accountTransaction):
            return true
        case (let .deeplink(lhsDeepLink), let .deeplink(rhsDeepLink)):
            return lhsDeepLink.trackerId == rhsDeepLink.trackerId
        default:
            return false
        }
    }
}

public protocol CustomPushLaunchActionTypeCapable {}

public protocol PushDialogSettings {
    var title: String { get }
    var message: String { get }
    var postDeepLinkNavigation: DeepLinkEnumerationCapable? { get }
}

public protocol PushWebviewSettings {
    var title: String { get }
    var url: String { get }
}

public protocol LandingPushTransactionDataSettings {
    var user: String { get }
    var cardName: String { get }
    var cardType: String { get }
    var pan: String { get }
    var bin: String { get }
    var transanction: TransactionSettings? { get }
    var alert: TransactionAlertSettings? { get }
}

public protocol TransactionSettings {
    var amountValue: Decimal? { get }
    var amountCurrency: String? { get }
    var commerce: String? { get }
    var date: String? { get }
}

public protocol TransactionAlertSettings {
    var name: String? { get }
    var category: String? { get }
}
