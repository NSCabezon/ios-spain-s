//
//  SPPushNotification.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 19/04/2021.
//
import CorePushNotificationsService
import CoreFoundationLib
import ESCommons

public enum SystemNotification {
    case notification(UNNotification)
    case response(UNNotificationResponse)
    case userInfo([AnyHashable: Any])
}

public struct SPPushNotification: PushRequestable {
    public var userInfo: [AnyHashable: Any] {
        switch systemNotification {
        case .notification(let note):
            return note.request.content.userInfo
        case .response(let note):
            return note.notification.request.content.userInfo
        case .userInfo(let note):
            return note
        }
    }
    public var date: Date
    public var systemNotification: SystemNotification

    public var didReceiveRequestAction: PushDidReceiveRequestAction? {
        guard let executableType = self.executableType else { return nil }
        switch executableType {
        case .webview:
            return PushDidReceiveRequestAction.launchAction(type: .webview(self.defaultWebViewParams))
        case .extUrl:
            return PushDidReceiveRequestAction.launchAction(type: .extUrl(self.url))
        case .cardTransaction:
            return PushDidReceiveRequestAction.launchAction(type: .cardTransaction(self.cardTransactionParams, self.alertInfoParams))
        case .accountTransaction:
            return PushDidReceiveRequestAction.launchAction(type: .accountTransaction(self.accountTransactionParams, self.alertInfoParams))
        case .dialog:
            return PushDidReceiveRequestAction.launchAction(type: .dialog(self.defaultDialogSetting))
        case .normal:
            guard let deeplinkAction = deeplinkAction else { return nil }
            return PushDidReceiveRequestAction.launchAction(type: .deeplink(deeplinkAction))
        case .otp:
            return PushDidReceiveRequestAction.launchAction(type: .dialog(self.defaultDialogSetting))
        case .custom(PushExecutableSpainCustomType.ecommerce):
            return PushDidReceiveRequestAction.launchAction(type: .custom(SpainPushActionType.ecommerce(self.otpCode)))
        case .custom:
            return nil
        }
    }
    
    public var willPresentRequestAction: PushWillPresentRequestAction? {
        guard self.isOtp else { return nil }
        return .otp
    }
    
    public subscript(index: AnyHashable) -> Any? {
        userInfo[index]
    }
    
    var deeplinkAction: DeepLinkEnumerationCapable? {
        guard let navKey = userInfo["navigation"] as? String else { return nil }
        var deepLinkInfo: [DeepLinkUserInfoKeys: String] = [:]
        if let identifier = userInfo["id"] as? String {
            deepLinkInfo[DeepLinkUserInfoKeys.identifier] = identifier
        }
        guard let deepLinkType = CoreFoundationLib.DeepLink(navKey, userInfo: deepLinkInfo) else { return nil }
        return deepLinkType
    }
    
    var defaultDialogSetting: DialogSettings {
        return DialogSettings(title: self.title, message: self.message, postDeepLinkNavigation: deeplinkAction)
    }
    
    var defaultWebViewParams: PushWebviewParams {
        return PushWebviewParams(title: self.title, url: self.url)
    }
    
    var pushType: NotificationType {
        if userInfo["tp_id"] != nil {
            return .twinpush
        } else {
            return .salesforce
        }
    }
    
    var isOtp: Bool {
        guard let otp = userInfo["otp"] as? String,
              !otp.isEmpty,
              self.twinPushActionType == nil,
              self.url.isEmpty == true
        else { return false }
        return true
    }
    
    public var executableType: PushExecutableType? {
        switch self.pushType {
        case .salesforce:
            guard let openType = self.userInfo["openType"] as? String else {
                return .dialog
            }
            switch openType {
            case "webview":
                return .webview
            case "extUrl":
                return .extUrl
            case "cardTransaction":
                return .cardTransaction
            case "accountTransaction":
                return .accountTransaction
            case "dialog":
                return .dialog
            case "normal":
                return .normal
            default:
                return .dialog
            }
        case .twinpush:
            if self.isOtp {
                return .otp
            } else {
                guard let twinPushActionType = self.twinPushActionType else { return nil }
                switch twinPushActionType {
                case .ecommerce:
                    return .custom(PushExecutableSpainCustomType.ecommerce)
                }
            }
        }
    }
    
    var otpCode: String? {
        if self.isOtp {
            guard let otpCode = userInfo["otp"] as? String else { return nil }
            return otpCode
        }
        return nil
    }
    
    var url: String {
        let urlKey = self.pushType == .salesforce ? "url" : "open_url"
        return userInfo[urlKey] as? String ?? ""
    }
    
    var message: String {
        return alertParameters?["body"] as? String ?? ""
    }
    
    var accountTransactionParams: AccountTransactionPushProtocol? {
        guard let transactionInfo = userInfo["transactionInfo"] as? String, !transactionInfo.isEmpty else { return nil }
        return CodableParser<AccountTransactionPush>().serialize(transactionInfo)
    }
    
    var cardTransactionParams: CardTransactionPush? {
        guard let transactionInfo = userInfo["transactionInfo"] as? String, !transactionInfo.isEmpty else { return nil }
        return CodableParser<CardTransactionPush>().serialize(transactionInfo)
    }
    
    var alertInfoParams: CardAlertPush? {
        guard let alertInfo = userInfo["alertInfo"] as? String, !alertInfo.isEmpty else { return nil }
        return CodableParser<CardAlertPush>().serialize(alertInfo)
    }
    
    var transactionData: [AnyHashable: Any] {
        return userInfo["transactionData"] as? [AnyHashable: Any] ?? [:]
    }
    
    var twinPushActionType: TwinPushActionType? {
        guard
            let key = userInfo["open_type"] as? String
            else { return nil }
        return TwinPushActionType(rawValue: key)
    }
}

public enum TwinPushActionType: String {
    case ecommerce
}

// commons userInfo Attributes
extension SPPushNotification {
    var alertParameters: NSDictionary? {
        let aps = userInfo["aps"] as? NSDictionary
        return aps?["alert"] as? NSDictionary
    }
    
    var title: String {
        return alertParameters?["title"] as? String ?? ""
    }
}
