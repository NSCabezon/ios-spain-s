
public struct LoansConstants {
    public static let appConfigEnableChangeLoanLinkedAccount = "enableChangeLoanLinkedAccount"
    public static let appConfigEnableLoanRepayment = "enableLoanRepayment"
}

public struct LoanPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/loan"
    
    public enum Action: String {
        case swipe = "swipe_loan"
        case copy = "copy_contract"
        case search = "search"
    }
    public init() {}
}

public struct LoanDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "/loan/detail"
    
    public enum Action: String {
        case copyAccount = "copy_associated_account"
        case copyContract = "copy_contract"
    }
    public init() {}
}

// MARK: - Loan Partial Amortization

public struct LoanPartialAmortizationTypePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public init() {}
    public let page = "prestamos_amortizacion_anticipada_tipo"

    public enum Action: String {
        case advanceExpiration = "tooltip_adelantar_vencimiento"
        case decreaseFee = "tooltip_disminuir_cuota"
    }
}

public struct LoanPartialAmortizationConfirmationPage: PageTrackable {
    public let page = "prestamos_amortizacion_anticipada_confirmacion"
    public init() {}
}

public struct LoanPartialAmortizationSignaturePage: PageTrackable {
    public let page = "prestamos_amortizacion_anticipada_firma"
    public init() {}
}

public struct LoanPartialAmortizationSummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public init() {}
    public let page = "prestamos_amortizacion_anticipada_resumen"
    public enum Action: String {
        case share = "compartir"
    }
}

public struct LoanSearchPage: PageWithActionTrackable {
    public typealias ActionType = Action

    public let page = "/loan/search"

    public enum Action: String {
        case apply_days = "search_days"
        case apply_days_amount = "search_days_amount"
        case removeFilter = "remove_filter"
    }
    public init() {}
}

public enum LoanFilterOperationType: String {
    case amounts = "importes"
    case dates = "fechas"
}

public struct LoanTransactionDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public var page = "/loan/detail/transaction"
    
    public init() {}
    
    public enum Action: String {
        case share = "share_information"
    }
}
