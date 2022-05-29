
public struct PublicMenuConstants {
    public static let recoverPassword = "recoverKeysUrl"
    public static let mobileWeb = "webMovilUrl"
    public static let getMagic = "obtainKeysUrl"
    public static let becomeClient = "becomeClientUrl"
    public static let recoverProcess = "recoverProcessUrl"
    public static let enablePublicProducts = "enablePublicProducts"
    public static let enableStockholders = "enableStockholders"
    public static let prepaidLogin = "prepaidLoginUrl"
    public static let shareHolders = "shareHoldersUrl"
    public static let enablePricingConditions = "enablePrecarioCondicoes"
    public static let enableLoanRepayment = "enableLoanRepayment"
    public static let enableChangeLoanLinkedAccount = "enableChangeLoanLinkedAccount"
}

public struct PublicMenuPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/public_menu"
    
    public enum Action: String {
        case recoveryKeys = "recuperar_claves"
        case getKeys = "obtener_claves"
        case prepaidKeys = "prepaid_key"
        case shareHoldersKeys = "shareHolders_key"
        case branch = "open_atm_branch_locator"
        case stockholders = "accionistas"
        case continueEntry = "continuar_alta"
        case newEntry = "nueva_alta"
        case cardEmergency = "click_card_emergency"
        case products = "click_our_product"
        case web = "goto_mobile_web"
        case swipe = "swipe"
        case tips = "discover_tip"
        case offer = "acceder_oferta"
        case pricingConditions = "precarioCondicoes_key"
    }
    public init() {}
}
