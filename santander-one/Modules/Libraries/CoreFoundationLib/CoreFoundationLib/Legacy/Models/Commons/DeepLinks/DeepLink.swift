import Foundation

public enum DeepLinkUserInfoKeys: String, CaseIterable {
    case identifier = "id"
    case date = "date"
    case authorizationId = "authorizationId"
    case scope = "scope"
}

public enum DeepLinkAccessType {
    case privateDeepLink
    case publicDeepLink
    case generalDeepLink
}

public protocol DeepLinkEnumerationCapable {
    var trackerId: String? { get }
    var deepLinkKey: String { get }
    var accessType: DeepLinkAccessType { get }
    init?(_ string: String, userInfo: [DeepLinkUserInfoKeys: String])
}
// swiftlint:disable cyclomatic_complexity
public enum DeepLink {
    case internalTransfer
    case transfer
    case pinQuery
    case cvvQuery
    case turnOffCard
    case turnOnCard
    case activateCard
    case ecash
    case directMoney
    case easyPay
    case cardPdfExtract
    case cesSignUp
    case payLater
    case billsAndTaxesPay
    case nationalTransfer
    case withdrawMoneyWithCode
    case extraordinaryContribution
    case fundSuscription
    case marketplace
    case personalArea
    case securitySettings
    case atm
    case analysisArea
    case offerLink(identifier: String, location: PullOfferLocation?)
    case open
    case changeCardPayMethod
    case timeline
    // ! Purchase products
    case cat(identifier: String)
    case myManager
    case offersForYou
    case onlineMessagesInbox
    case secureDevice
    case userBasicInfo
    case addToApplePay
    case changeSign
    case financing
    case financingCards
    case payOff
    case whatsNew
    case correosCash
    case cardBoarding
    case whatsNewFractionableCardMovements
    case tips
    case globalPosition
    case authorizationProcess(authorizationId: String, scope: String)
    // Legacy compat
    case custom(deeplink: String, userInfo: [DeepLinkUserInfoKeys: String])
}

extension DeepLink: DeepLinkEnumerationCapable {
    // swiftlint:disable cyclomatic_complexity
    public init?(_ string: String, userInfo: [DeepLinkUserInfoKeys: String] = [:]) {
        switch string {
        case DeepLink.internalTransfer.deepLinkKey: self = .internalTransfer
        case DeepLink.transfer.deepLinkKey: self = .transfer
        case DeepLink.pinQuery.deepLinkKey: self = .pinQuery
        case DeepLink.cvvQuery.deepLinkKey: self = .cvvQuery
        case DeepLink.turnOffCard.deepLinkKey: self = .turnOffCard
        case DeepLink.turnOnCard.deepLinkKey: self = .turnOnCard
        case DeepLink.activateCard.deepLinkKey: self = .activateCard
        case DeepLink.ecash.deepLinkKey: self = .ecash
        case DeepLink.directMoney.deepLinkKey: self = .directMoney
        case DeepLink.easyPay.deepLinkKey: self = .easyPay
        case DeepLink.cardPdfExtract.deepLinkKey: self = .cardPdfExtract
        case DeepLink.cesSignUp.deepLinkKey: self = .cesSignUp
        case DeepLink.payLater.deepLinkKey: self = .payLater
        case DeepLink.billsAndTaxesPay.deepLinkKey: self = .billsAndTaxesPay
        case DeepLink.nationalTransfer.deepLinkKey: self = .nationalTransfer
        case DeepLink.withdrawMoneyWithCode.deepLinkKey: self = .withdrawMoneyWithCode
        case DeepLink.extraordinaryContribution.deepLinkKey: self = .extraordinaryContribution
        case DeepLink.fundSuscription.deepLinkKey: self = .fundSuscription
        case DeepLink.marketplace.deepLinkKey: self = .marketplace
        case DeepLink.personalArea.deepLinkKey: self = .personalArea
        case DeepLink.securitySettings.deepLinkKey: self = .securitySettings
        case DeepLink.atm.deepLinkKey: self = .atm
        case DeepLink.analysisArea.deepLinkKey: self = .analysisArea
        case DeepLink.offerLink(identifier: "", location: nil).deepLinkKey:
            guard let offerLinkIdentifier = userInfo[.identifier] else { return nil }
            self = .offerLink(identifier: offerLinkIdentifier, location: nil)
        case DeepLink.open.deepLinkKey: self = .open
        case DeepLink.cat(identifier: "").deepLinkKey:
            guard let identifier = userInfo[.identifier] else { return nil }
            self = .cat(identifier: identifier)
        case DeepLink.changeCardPayMethod.deepLinkKey: self = .changeCardPayMethod
        case DeepLink.timeline.deepLinkKey: self = .timeline
        case DeepLink.myManager.deepLinkKey: self = .myManager
        case DeepLink.offersForYou.deepLinkKey: self = .offersForYou
        case DeepLink.onlineMessagesInbox.deepLinkKey: self = .onlineMessagesInbox
        case DeepLink.secureDevice.deepLinkKey: self = .secureDevice
        case DeepLink.addToApplePay.deepLinkKey: self = .addToApplePay
        case DeepLink.userBasicInfo.deepLinkKey: self = .userBasicInfo
        case DeepLink.changeSign.deepLinkKey: self = .changeSign
        case DeepLink.financing.deepLinkKey: self = .financing
        case DeepLink.financingCards.deepLinkKey: self = .financingCards
        case DeepLink.payOff.deepLinkKey: self = .payOff
        case DeepLink.whatsNew.deepLinkKey: self = .whatsNew
        case DeepLink.correosCash.deepLinkKey: self = .correosCash
        case DeepLink.cardBoarding.deepLinkKey: self = .cardBoarding
        case DeepLink.whatsNewFractionableCardMovements.deepLinkKey: self = .whatsNewFractionableCardMovements
        case DeepLink.tips.deepLinkKey: self = .tips
        case DeepLink.globalPosition.deepLinkKey: self = .globalPosition
        case DeepLink.authorizationProcess(authorizationId: "", scope: "").deepLinkKey:
            guard let authorizationId = userInfo[.authorizationId], let scope = userInfo[.scope] else { return nil }
            self = .authorizationProcess(authorizationId: authorizationId, scope: scope)
        // Legacy compat
        default: self = .custom(deeplink: string, userInfo: userInfo)
        }
    }
    
    public var trackerId: String? {
        switch self {
        case .internalTransfer:
            return "trasp"
        case .transfer:
            return "thab"
        case .pinQuery:
            return "tarpin"
        case .cvvQuery:
            return "tarcvv"
        case .turnOffCard:
            return "taroff"
        case .turnOnCard:
            return "taron"
        case .activateCard:
            return "tarac"
        case .ecash:
            return "tarecash"
        case .directMoney:
            return "dd"
        case .easyPay:
            return "pf"
        case .cardPdfExtract:
            return "tarpdf"
        case .cesSignUp:
            return "tarces"
        case .payLater:
            return "pl"
        case .billsAndTaxesPay:
            return "recimp"
        case .nationalTransfer:
            return "tnac"
        case .withdrawMoneyWithCode:
            return "tarcod"
        case .extraordinaryContribution:
            return "planae"
        case .fundSuscription:
            return "fons"
        case .marketplace:
            return "mkp"
        case .personalArea:
            return "apers"
        case .securitySettings:
            return "secset"
        case .atm:
            return "atm"
        case .analysisArea:
            return "za"
        case .offerLink:
            return "offer"
        case .open:
            return "open"
        case .cat:
            return "cat"
        case .changeCardPayMethod:
            return "tarcfp"
        case .timeline:
            return "timeline"
        case .myManager:
            return "gest"
        case .offersForYou:
            return "contra"
        case .onlineMessagesInbox:
            return "bzn"
        case .secureDevice:
            return "dispseg"
        case .userBasicInfo:
            return "datcon"
        case .addToApplePay:
            return "inapp"
        case .changeSign:
            return "firma"
        case .financing:
            return "zf"
        case .financingCards:
            return "zfc"
        case .payOff:
            return "ingtar"
        case .whatsNew:
            return "wn"
        case .correosCash:
            return "correos"
        case .cardBoarding:
            return "cardboard"
        case .whatsNewFractionableCardMovements:
            return "wntmf"
        case .tips:
            return "cons"
        case .globalPosition:
            return "globalposition"
        case .authorizationProcess:
            return "stoneauth"
        // Legacy compat
        case .custom:
            return nil
        }
    }
    
    public var deepLinkKey: String {
        switch self {
        case .internalTransfer: return "trasp"
        case .transfer: return "thab"
        case .pinQuery: return "tarpin"
        case .cvvQuery: return "tarcvv"
        case .turnOffCard: return "taroff"
        case .turnOnCard: return "taron"
        case .activateCard: return "tarac"
        case .ecash: return "tarecash"
        case .directMoney: return "dd"
        case .easyPay: return "pf"
        case .cardPdfExtract: return "tarpdf"
        case .cesSignUp: return "tarces"
        case .payLater: return "pl"
        case .billsAndTaxesPay: return "recimp"
        case .nationalTransfer: return "tnac"
        case .withdrawMoneyWithCode: return "tarcod"
        case .extraordinaryContribution: return "planae"
        case .fundSuscription: return "fons"
        case .marketplace: return "mkp"
        case .personalArea: return "apers"
        case .securitySettings: return "secset"
        case .atm: return "atm"
        case .analysisArea: return "za"
        case .offerLink: return "offer"
        case .open: return "open"
        case .changeCardPayMethod: return "tarcfp"
        case .timeline: return "timeline"
        case .cat: return "cat"
        case .myManager: return "gest"
        case .offersForYou: return "contra"
        case .onlineMessagesInbox: return "bzn"
        case .secureDevice: return "dispseg"
        case .userBasicInfo: return "datcon"
        case .addToApplePay: return "inapp"
        case .changeSign: return "firma"
        case .financing: return "zf"
        case .financingCards: return "zfc"
        case .payOff: return "ingtar"
        case .whatsNew: return "wn"
        case .correosCash: return "correos"
        case .cardBoarding: return "cardboard"
        case .whatsNewFractionableCardMovements: return "wntmf"
        case .tips: return "cons"
        case .globalPosition: return "globalposition"
        case .authorizationProcess: return "stoneauth"
        case .custom(let deeplink, _): return deeplink
        }
    }
    
    public var accessType: DeepLinkAccessType {
        switch self {
        case .tips:
            return .generalDeepLink
        default:
            return .privateDeepLink
        }
    }
}
// swiftlint:enable cyclomatic_complexity
