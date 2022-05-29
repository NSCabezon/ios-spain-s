
public struct AccountsConstants {
    public static let appConfigAccountEasyPayLowAmountLimit = "accountEasyPayLowAmountLimit"
    public static let appConfigAccountEasyPayMinAmount = "accountEasyPayMinAmount"
    public static let appConfigEnableAccountEasyPayForBills = "enableAccountEasyPayForBills"
    public static let appConfigEnableAccountFinancingMovements = "enableAccountFinancingMovements"
    public static let appCfgEnableAccountEasyPayForStandardNTransfers = "enableAccountEasyPayForStandardNationalTransfers"
    public static let isEnableAccountsHomeFutureBills = "enableAccountsHomeFutureBills"
    public static let IsEnableWithholdingList = "enableWithholdingList"
}

public struct AccountsPullOffers {
    public static let fxPayAccountsHome = "FXPAY_ACCOUNTS_HOME"
    public static let accountsHomeDonations = "ACCOUNTS_HOME_DONATIONS"
    public static let oneAcccountButton = "ONE_ACCOUNT_BUTTON"
    public static let newAccountButton = "NEW_ACCOUNT_ACCOUNT_BUTTON"
    public static let certificateAccountButton = "CERTIFICATE_ACCOUNT_BUTTON"
    public static let requestForeignCurrency = "SOLICITUD_MONEDA_EXTRANJERA"
    public static let lowEasyPayAmount = "EASY_PAY_LOW_AMOUNT"
    public static let highEasyPayAmount = "EASY_PAY_HIGH_AMOUNT"
    public static let movAccountDetail = "MOV_CTA_DETAIL"
    public static let lowEasyPayAmountDetail = "EASY_PAY_LOW_AMOUNT_ACCOUNT_DETAIL"
    public static let highEasyPayAmountDetail = "EASY_PAY_HIGH_AMOUNT_ACCOUNT_DETAIL"
    public static let homeCrossSelling = "ACCOUNTS_HOME_CROSSSELLING"
    public static let accountsHomePiggyBank = "ACCOUNTS_HOME_HUCHA"
    public static let movAccountPfm = "MOV_CTA_PFM"
    public static let correosCash = "CORREOS_CASH_CUENTAS"
    public static let contractAccount = "OPERAR_CONTRATAR_CUENTAS"
    public static let receiptFinancing = "DIRECT_ACCESS_ACCOUNT_RECEIPT_FINANCING"
    public static let customizeAtmOptions = "Z_ATM_CUSTOMIZE_OPTIONS"
    public static let atmOfficeAppointment = "ATM_OFFICE_APPOINTMENT"
    public static let atmReport = "Z_ATM_REPORT"
    public static let automaticOperations = "ACCOUNT_MOREOPTIONS_AUTOMATIC_OPERATIONS"
}

// MARK: - Tracker
 
public struct AccountsHomePage: PageWithActionTrackable, EmmaTrackable {
    public var emmaToken: String
    public typealias ActionType = Action
    public let page =  "/account"
    
    public enum Action: String {
        case copy = "copy_iban"
        case transfers = "click_transfer"
        case progress = "evolución_gasto"
        case receipt = "click_bill_tax"
        case detail = "detalle_cuenta"
        case easyPay = "easy_pay"
        case easyPayError = "easy_pay_error"
        case swipe = "swipe_account_carrousel"
        case witholding = "view_withholding"
        case filter = "click_filter"
        case pdf = "open_pdf"
        case moreMovements = "view_more_transaction"
        case operative = "select_operative"
    }
    public init() {
        self.emmaToken = ""
    }
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}

public struct AccountTransactionDetail: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/account/transaction_detail"
    
    public enum Action: String {
        case sendMoney = "send_money"
        case expenseDeposit = "gastos_e_ingresos"
        case pdf = "open_pdf"
        case easyPay = "click_easy_pay"
        case easyPayError = "easy_pay_error"
        case share = "share_transaction"
        case swipe = "swipe_transaction"
        case bills = "click_bill"
        case returnBill = "return_bill"
        case splitExpenses = "split_expense"
    }
    public init() {}
}

public struct AccountFilterPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/account/filter"
    
    public enum Action: String {
        case apply = "apply_filter"
    }
    public init() {}
}

public struct AccountAssociatedTransactionPage: PageTrackable {
    public let page = "/account/transaction_detail/related"
    
    public init() {}
}

public struct AccountScaPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/sca_accounts"
    
    public enum Action: String {
        case next = "click_continue"
        case cancel = "click_cancel"
    }
    public init() {}
}

public struct AccountDetailPage: PageTrackable {
    public let page = "/account/detail"
    
    public init() {}
}

public enum AccountFilterOperationType: String {
    case amounts = "importes"
    case dates = "fechas"
    case operationType = "tipo_operacion"
}

public struct SendMoneyOperativePullOffers {
    public static let lowEasyPayAmount = "EASY_PAY_LOW_AMOUNT"
    public static let highEasyPayAmount = "EASY_PAY_HIGH_AMOUNT"
}
