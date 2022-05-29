import Foundation

public enum AccessibilityUnrememberedLogin: String {
    case backgroundImageView
    case inputTextDocument
    case inputTextPassword
    case btnArrowDown
    case btnEyeOpen
    case btnCheck
    case btnCheckLabel
    case btnEnter
    case btnEnterLabel = "login_button_enter"
    case btnEnvironment
    case btnEnvironmentLabel
    case btnLostKey
    case btnLostKeyLabel
    case loginDropDownView
    case regardLabel
    case rememberActivated = "voiceover_login_radioButton_rememberUser_activated"
    case rememberDeactivated = "voiceover_login_radioButton_rememberUser_deactivated"
    case rememberLabel = "login_radioButton_rememberUser"
    case rememberMeView
    case sanIconImageView
}

public enum AccessibilityUnrememberedLoginType {
    public static let nif = "unrememberedLoginCellNIF"
    public static let nie = "unrememberedLoginCellNIE"
    public static let cif = "unrememberedLoginCellCIF"
    public static let passport = "unrememberedLoginCellPassport"
    public static let user = "unrememberedLoginCellUser"
}

public enum AccessibilityRememberedLogin: String {
    case inputTextPassword
    case btnEnter
    case btnChangeUser
    case btnLostKey
    case btnEnvironment
    case btnEnvironmentLabel
    case btnBalance
    case btnBalanceLabel
    case btnChangeUserLabel
    case loginContainer
    case headerView
    case backgroundImageView
    case backgroundCoverView
}

public enum AccessibilityRememberedLoginView {
    public static let santanderLogoImage = "logoSanLogin"
    public static let nameLabel = "login_label_hello"
    public static let changeUserButton = "loginBtnChangeUser"
}

public enum AccessibilityQuickBalance: String {
    case btnClose
    case btnCloseLabel
    case btnEnter
    case btnActivate
    case btnActivateLabel
    case btnBackLogin
    case btnBackLoginLabel
    case btnBizum
    case btnSendMoney
    case btnPin
    case btnBlockCard
    case closeImageView
    case deeplinksView
    case scrollView
    case stackView
    case bottomSeparatorView
    case topSeparatorView
    case imageView
    case playImageView
    case sectionView
    case descriptionLabel
}

public enum AccessibilityQuickBalanceHeader: String {
    case logoImageView
    case balanceTitleLabel
    case balanceLabel
    case updatedDateLabel
    case reloadButton
    case reloadButtonLabel
    case separatorView
}

public enum AccessibilityQuickBalanceSectionView: String {
    case sectionTitleLabel
}

public enum AccessibilityTopAlert: String {
    case alertLogin
    case icnOk
    case discreteModeActivated = "pg_alert_discreteModeActivated"
    case alertTitleLabel
    case icnAlertView
    case alertView
}

public enum AccessibilityEnvironmentSelector: String {
    case btnClose
    case btnAccept
    case txtEnvironment
    case lblEnvironment
}
