public protocol PushInfo {
    var userInfo: [AnyHashable: Any] { get }
    var date: Date { get }
    var navigation: PushNavigation? { get }
    var executableType: PushExecutableType? { get }
    subscript(index: AnyHashable) -> Any? { get }
}

public enum PushNavigation {
    case standard
    case deeplink(String)
    case offerlink(String)
}

public enum SalesforcePushOpenType: String {
    case normal
    case dialog
    case webview
    case extUrl
    case cardTransaction
    case accountTransaction
}

public struct SalesforcePushInfo {
    public let userInfo: [AnyHashable: Any]
    public let date: Date
    
    public var type: SalesforcePushOpenType {
        guard
            let key = userInfo["openType"] as? String
            else { return .dialog }
        return SalesforcePushOpenType(rawValue: key) ?? .dialog
    }
    
    public var executableType: PushExecutableType? {
        guard userInfo["otp"] != nil else { return nil }
        return .otp
    }
    
    public var url: String? {
        return userInfo["url"] as? String
    }
    
    public var alertParameters: NSDictionary? {
        let aps = userInfo["aps"] as? NSDictionary
        return aps?["alert"] as? NSDictionary
    }
    
    public var title: String? {
        return alertParameters?["title"] as? String
    }
    
    public var message: String? {
        return alertParameters?["body"] as? String
    }
    
    public var transactionInfo: String? {
        return userInfo["transactionInfo"] as? String
    }
    
    public var alertInfo: String? {
        return userInfo["alertInfo"] as? String
    }
    
    public var navigation: PushNavigation? {
        let nav = userInfo["navigation"] as? String
        switch nav {
        case "offer_link":
            guard let offerId = userInfo["id"] as? String else { return nil }
            return .offerlink(offerId)
        case "":
            return .standard
        default:
            guard let deeplinkId = nav else { return nil }
            return .deeplink(deeplinkId)
        }
    }
    
    public init(userInfo: [AnyHashable: Any], date: Date) {
        self.userInfo = userInfo
        self.date = date
    }
    
    public subscript(index: AnyHashable) -> Any? {
        return userInfo[index]
    }
}

extension SalesforcePushInfo: PushInfo {}

public enum TwinPushOpenType: String {
    case ecommerce
}

public struct TwinPushInfo {
    public let userInfo: [AnyHashable: Any]
    public let date: Date
    
    public init(userInfo: [AnyHashable: Any], date: Date) {
        self.userInfo = userInfo
        self.date = date
    }
    
    public subscript(index: AnyHashable) -> Any? {
        return userInfo[index]
    }
    
    public var type: TwinPushOpenType? {
        guard
            let key = userInfo["open_type"] as? String
            else { return nil }
        return TwinPushOpenType(rawValue: key)
    }
    
    public var alertParameters: NSDictionary? {
        let aps = userInfo["aps"] as? NSDictionary
        return aps?["alert"] as? NSDictionary
    }
    
    public var title: String? {
        return alertParameters?["title"] as? String
    }
    
    public var url: String? {
        return userInfo["open_url"] as? String
    }
    
    public var executableType: PushExecutableType? {
        guard
            let otp = userInfo["otp"] as? String,
            !otp.isEmpty,
            type == nil,
            url == nil || url?.isEmpty == true
        else { return nil }
        return .otp
    }
}

extension TwinPushInfo: PushInfo {
    public var navigation: PushNavigation? {
        return .standard
    }
}

public class PushInfoFactory {
    public static func create(from userInfo: [AnyHashable: Any], date: Date?) -> PushInfo {
        let date = date ?? Date()
        if userInfo["tp_id"] != nil {
            return TwinPushInfo(userInfo: userInfo, date: date)
        } else {
            return SalesforcePushInfo(userInfo: userInfo, date: date)
        }
    }
}
