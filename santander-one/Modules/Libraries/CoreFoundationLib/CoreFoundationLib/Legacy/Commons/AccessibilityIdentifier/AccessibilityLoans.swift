import Foundation

public enum AccessibilityLoanTransaction: String {
    case relatedCarouselTitle = "transactionDetail_title_related"
    case relatedTransactionDate = "relatedTransaction_label_operationDate"
}

public enum AccessibilityLoanDetail: String {
    case loanAlias = "productDetail_label_alias"
    case loanCopyIcon = "icnCopy"
    case titleDetail
    case subtitleDetail
    case shareIconDetail
    case loanHeaderView
    case detailView
    case mainLabel
    case titlePerfect
    case subtitlePerfect
    case ticImage
    case perfectView
}

public enum AccesibilityLoanHomeAction {
    public static let loansHomeBtnPdfExtract = "loansHomeBtnPdfExtract"
    public static let loansHomeBtnShare = "loansHomeBtnShare"
}

public enum AccessibilityLoansFilter {
    public static let applyButton = "searchBtnApply"
    public static let applyButtonView = "searchViewApply"
    public static let searchConceptView = "searchConceptView"
    public static let segmentedControlView = "shearchSegmentedControlView"
    public static let dateFilterView = "searchDateFilterView"
    public static let operationTypeView = "searchOperationTypeView"
}

public enum AccessibilityIDLoansHome: String {
    case loanCardContainer = "loansViewItem"
    case loanAlias = "loansLabelAlias"
    case loanContractNumber = "loansLabelContract"
    case loanState = "loans_label_pending"
    case loanBalanceAmount = "loansLabelAmount"
    case loanProgressBar = "loansViewProgressBar"
    case loanStartDate = "loansLabelStartDate"
    case loanEndDate = "loansLabelEndDate"
    case loanShareIcon = "icnShare"
    case optionRepaymentContainer = "loansBtnEarlyRepayment"
    case optionRepaymentTitleLabel = "loansOption_button_anticipatedAmortization"
    case optionRepaymentImage = "icnEarlyRepayment"
    case optionChangeAccountContainer = "loansBtnChangeAccount"
    case optionChangeAccountTitleLabel = "loansOption_button_changeAccount"
    case optionChangeAccountImage = "icnChangeAccount"
    case optionDetailContainer = "loansBtnLoanDetail"
    case optionDetailTitleLabel = "loansOption_button_detailLoan"
    case optionDetailImage = "icnCheckExtract"
    case movementTitle = "productHome_label_moves"
    case movementDateLabel = "productListMovesLabelDate"
    case movementConceptLabel = "productListMovesLabelConcept"
    case movementAmountLabel = "productListMovesLabelAmount"
    case loadingImage = "loansLoaderSecundary"
    case loadingLabel = "loading_label_transactionsLoading"
    case pageControl = "productCarouselTab"
    case scrollTopAlias = "loansScrollTopAlias"
    case scrollTopAmount = "loansScrollTopAmount"
    case noMovements = "generic_label_emptyNotAvailableMoves"
    case movementsError = "productEmptyView"
    case filters = "loansBtnFilter"
    case optionCustomerServiceContainer = "loansBtnCustomerService"
    case optionScheduleContainer = "loansBtnLoanSchedule"
}

public enum AccessibilityIDLoansTransactionsDetail: String {
    case itemContainer = "transactionDetailViewItem"
    case itemTitle = "transactionDetailAlias"
    case itemAlias = "transactionDetailProductAlias"
    case itemAmount = "transactionDetailAmount"
    case transactionDateDescription = "transaction_label_operationDate"
    case transactionDateValue = "transaction_label_operationDate_value"
    case effectiveDateDescription = "transaction_label_valueDate"
    case effectiveDateValue = "transaction_label_valueDate_value"
    case feeAmountDescription = "transaction_label_feeAmount"
    case feeAmountValue = "transaction_label_feeAmount_value"
    case capitalAmountDescription = "transaction_label_amount"
    case capitalAmountValue = "transaction_label_amount_value"
    case interestAmountDescription = "transaction_label_interests"
    case interestAmountValue = "transaction_label_interests_value"
    case pendingAmountDescription = "transaction_label_pendingAmount"
    case pendingAmountValue = "transaction_label_pendingAmount_value"
    case recipientAccountDescription = "transaction_label_recipientAccount"
    case recipientAccountValue = "transaction_label_recipientAccount_value"
    case recipientDataDescription = "transaction_label_recipientData"
    case recipientDataValue = "transaction_label_recipientData_value"
    case actionPDFContainer = "transactionBtnSeePDF"
    case actionPDFLabel = "generic_button_viewPdf"
    case actionPDFIcon = "icnPDF"
    case actionShareContainer = "transactionBtnShare"
    case actionShareLabel = "generic_button_share"
    case actionShareIcon = "icnShareBostonRedLight"
    case actionAmortizationPartialContainer = "transactionBtnAmortizationPartial"
    case actionAmortizationPartialLabel = "transaction_buttonOption_amortizationPartial"
    case actionAmortizationPartialIcon = "icnAmortizationPartial"
    case actionChangeAccountContainer = "transactionBtnChangeAccount"
    case actionChangeAccountLabel = "transaction_buttonOption_changeAccount"
    case actionChangeAccountIcon = "icnChangeAccount"
    case actionSeeDetailContainer = "transactionBtnSeeDetail"
    case actionSeeDetailAccountLabel = "transaction_buttonOption_detailLoan"
    case actionSeeDetailAccountIcon = "icnInfo"
    
}

public enum AccessibilityIDLoanDetail: String {
    case itemContainer = "loansViewItem"
    case itemAlias = "loansLabelAlias"
    case itemContract = "loansLabelContract"
    case itemCopyIcon = "icnCopy"
    case itemStatus = "loansLabelStatus"
    case itemAmount = "loansLabelAmount"
    case detailAlias = "productDetail_label_alias"
    case detailAliasValue = "productDetail_label_alias_value"
    case detailAssociatedAccount = "productDetail_label_associatedAccount"
    case detailAssociatedAccountValue = "productDetail_label_associatedAccount_value"
    case detailAssociatedAccountShare = "icnShare"
    case detailFirstHolder = "productDetail_label_firstHolder"
    case detailFirstHolderValue = "productDetail_label_firstHolder_value"
    case detailSeedAmount = "productDetail_label_seedAmount"
    case detailSeedAmountValue = "productDetail_label_seedAmount_value"
    case detailInterestRate = "productDetail_label_interestRate"
    case detailInterestRateValue = "productDetail_label_interestRate_value"
    case detailInterestClass = "productDetail_label_interestClass"
    case detailInterestClassValue = "productDetail_label_interestClass_value"
    case detailPeriodicityPayments = "productDetail_label_periodicityPayments"
    case detailPeriodicityPaymentsValue = "productDetail_label_periodicityPayments_value"
    case detailOpeningDate = "productDetail_label_openingDate"
    case detailOpeningDateValue = "productDetail_label_openingDate_value"
    case detailInitialExpiration = "productDetail_label_initialExpiration"
    case detailInitialExpirationValue = "productDetail_label_initialExpiration_value"
    case detailCurrentExpiration = "productDetail_label_currentExpiration"
    case detailCurrentExpirationValue = "productDetail_label_currentExpiration_value"
    case detailCurrentInterestAmount = "productDetail_label_currentInterestAmount"
    case detailCurrentInterestAmountValue = "productDetail_label_currentInterestAmount_value"
    case detailLastOperationDate = "productDetail_label_lastOperationDate"
    case detailLastOperationDateValue = "productDetail_label_lastOperationDate_value"
    case detailNextInstallmentDate = "productDetail_label_dateNextInstallment"
    case detailNextInstallmentDateValue = "productDetail_label_dateNextInstallment_value"
    case copyContainer = "accountDetailViewSuccessfully"
    case copyIcon = "icnCheckToast"
    case copyTitle = "generic_label_perfect"
    case copySubtitle = "generic_label_copy"
}
