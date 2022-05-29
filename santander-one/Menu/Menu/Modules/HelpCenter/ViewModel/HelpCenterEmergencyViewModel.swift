import CoreFoundationLib

public struct HelpCenterEmergencyViewModel {
    let stolen: HelpCenterEmergencyStolenViewModel?
    let isFraudEnabled: Bool
    let isSuperlineEnabled: Bool
    let isChatEnabled: Bool
    
    public init(stolen: HelpCenterEmergencyStolenViewModel?, isFraudEnabled: Bool, isSuperlineEnabled: Bool, isChatEnabled: Bool) {
        self.stolen = stolen
        self.isFraudEnabled = isFraudEnabled
        self.isSuperlineEnabled = isSuperlineEnabled
        self.isChatEnabled = isChatEnabled
    }
}

public struct HelpCenterEmergencyStolenViewModel {
    let title: String?
    let description: String?
    let phones: [String]
    
    public init(title: String?, description: String?, phones: [String]) {
        self.title = title
        self.description = description
        self.phones = phones
    }
}

public enum HelpCenterEmergencyAction: Equatable {
    case stolenCard(phoneNumber: [String], phonePos: Int?)
    case reportFraud
    case blockSign
    case pin
    case cvv
    case cash
    case sendMoney
    case cancelTransfer
    case changeMagic
    case superlinea
    case chat
    
    public func accesibilityId() -> String {
        switch  self {
        case .stolenCard:
            return AccesibilityHelpCenterPersonalArea.btnStolenCard.rawValue
        case .reportFraud:
            return AccesibilityHelpCenterPersonalArea.btnReportFraud.rawValue
        case .blockSign:
            return AccesibilityHelpCenterPersonalArea.btnKeyLock.rawValue
        case .pin:
            return AccesibilityHelpCenterPersonalArea.btnPin.rawValue
        case .cvv:
            return AccesibilityHelpCenterPersonalArea.btnCvv.rawValue
        case .cash:
            return AccesibilityHelpCenterPersonalArea.btnNeedCash.rawValue
        case .sendMoney:
            return AccesibilityHelpCenterPersonalArea.btnSendMoney.rawValue
        case .cancelTransfer:
            return AccesibilityHelpCenterPersonalArea.btnCancelTransfer.rawValue
        case .changeMagic:
            return AccesibilityHelpCenterPersonalArea.btnChangeAccessKey.rawValue
        case .superlinea:
            return AccesibilityHelpCenterPersonalArea.btnHelpCall2.rawValue
        case .chat:
            return AccesibilityHelpCenterPersonalArea.btnHelpChat2.rawValue
        }
    }
    
    public func accesibilityIdFlipped() -> String {
        switch self {
        case .stolenCard:
            return AccesibilityHelpCenterPersonalArea.btnStolenCardFlipped.rawValue
        case .reportFraud:
            return AccesibilityHelpCenterPersonalArea.btnReportFraudFlipped.rawValue
        case .superlinea:
            return AccesibilityHelpCenterPersonalArea.btnHelpCall2Flipedd.rawValue
        default:
            return ""
        }
    }
}

public struct HelpCenterEmergencyItemViewModel {
    public let title: LocalizedStylableText
    public let subtitle: LocalizedStylableText?
    let icon: String
    public let action: HelpCenterEmergencyAction
    let isPhoneView: Bool
    
    public init(
        title: LocalizedStylableText,
        subtitle: LocalizedStylableText? = nil,
        icon: String,
        action: HelpCenterEmergencyAction,
        isPhoneView: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
        self.isPhoneView = isPhoneView
    }
}
