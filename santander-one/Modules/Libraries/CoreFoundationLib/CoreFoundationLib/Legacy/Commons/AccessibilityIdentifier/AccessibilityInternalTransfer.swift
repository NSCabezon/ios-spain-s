import Foundation

public enum AccessibilityInternalTransferOrigin: String {
    case label = "originAccount_label_sentMoney"
    case header = "originAccount_header_sentMoney"
    case cellButton = "transferBtnAccount"
}

public enum AccessibilityInternalTransferDestination: String {
    case label = "destinationAccounts_label_receiveMoney"
    case cellButton = "transferBtnAccount"
}

public enum AccessibilityInternalTransferAmount: String {
    case amountAndDateTitleLabel = "sendMoney_label_amoundDate"
    case labelAmount = "sendMoney_label_Amount"
    case labelConcept = "sendMoney_label_concept"
    case inputAmount = "transferInputAmount"
    case alertViewLabel = "sendMoney_label_conversionExchangeRate"
    case sellRateLabel = "sendMoney_label_exchangeSellRate"
    case buyRateLabel = "sendMoney_label_exchangeBuyRate"
    case inputConcept = "transferInputConcept"
    case inputScheduledDate
    case inputPeriodicity
    case inputStartDate
    case inputEndDate
    case inputEmissionDate
    case btnContinue
    case btnEndDateNever
    case labelEndDateNever = "sendMoney_label_indefinite"
    case transferAmountAndTypeBtnContinue
    case labelWhenDescriptionTitle = "transfer_label_periodicity"
}

public enum AccessibilityInternalTransferConfirmation {
    public static let sourceSuffix = "_source"
    public static let amountSuffix = "_amount"
    public static let destinationSuffix = "_destination"
    public static let dateSuffix = "_date"
    public static let exchangeSuffix = "_exchange"
}

public enum AccessibilityInternalTransferSummary: String {
    case okSummary
    case title = "summe_title_perfect"
    case subtitle = "summary_label_sentMoneyOk"
    case openCloseButton = "btnArrowDown"
    public enum Summary {
        public static let sourceSuffix = "_source"
        public static let amountSuffix = "_amount"
        public static let destinationSuffix = "_destination"
        public static let dateSuffix = "_date"
        public static let exchangeSuffix = "_exchange"
    }
    public enum ShareButton {
        public static let shareButtonView = "oneHorizontalButton"
        public static let shareButtonImg = "oneHorizontalButtonImg"
        public static let shareButtonTitle = "oneHorizontalButtonTitle"
        public static let pdfSuffix = "_0"
        public static let imageSuffix = "_1"
    }
}

public enum AccessibilityInternTransferAccountSelector {
    public static let accountVisibleItem = "internalTransfer_account_selector_item"
    public static let accountNotVisibleItem = "internTransfer_account_selector_not_visible_item"
    public static let accountLabelSeeHiddenAccounts = "originAccount_label_seeHiddenAccounts"
}

public enum AccessibilityInternTransferAccountDestinationSelector {
    public static let accountVisibleItem = "internalTransfer_account_destination_selector_item"
    public static let accountNotVisibleItem = "internTransfer_account_destination_selector_not_visible_item"
    public static let accountLabelSeeHiddenAccounts = "destinationAccount_label_seeHiddenAccounts"
}
