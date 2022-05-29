import CoreFoundationLib
import CoreDomain

final class LoanDetailProductsBuilder {
    private var values: [LoanDetailProduct]
    private let loan: LoanRepresentable
    private let detail: LoanDetailRepresentable
    private let config: LoanDetailConfigRepresentable
    private let locale: Locale
    
    init(loan: LoanRepresentable,
         detail: LoanDetailRepresentable,
         config: LoanDetailConfigRepresentable,
         locale: Locale) {
        self.values = []
        self.detail = detail
        self.loan = loan
        self.config = config
        self.locale = locale
    }
    
    func getProducts() -> [LoanDetailProduct] {
        values = []
        addAlias(alias: loan.alias?.camelCasedString ?? "", isAliasNeeded: config.aliasIsNeeded)
        addAssociatedAccount(associatedAccount: detail.linkedAccountDesc)
        addFirstHolder(firstHolder: detail.holder?.camelCasedString ?? "", isEnabledFirstHolder: config.isEnabledFirstHolder)
        addSeedAmount(seedAmount: detail.seedAmount)
        addInterestRate(interestRate: detail.interestType?.camelCasedString)
        addReferenceRate(referenceRate: detail.interestTypeDesc?.camelCasedString)
        addPeriodicity(periodicity: periodicity)
        addCurrentInterestAmount(currentInterestAmount: detail.currentInterestAmount, isEnabledCurrentInterestAmount: config.isEnabledCurrentInterestAmount)
        addOpeningDate(openingDate: openingDate)
        addLastOperationDate(lastOperationDate: lastOperationDate, isEnabledLastOperationDate: config.isEnabledLastOperationDate)
        addNextInstallmentDate(nextInstallmentDate: nextInstallmentDate, isEnabledNextInstallmentDate: config.isEnabledNextInstallmentDate)
        addInitialExpirationDate(initialExpirationDate: initialExpirationDate, isEnabledInitialExpiration: config.isEnabledInitialExpiration)
        addCurrentExpirationDate(currentExpirationDate: currentExpirationDate)
        return values
    }
}

private extension LoanDetailProductsBuilder {
    
    var periodicity: String? {
        guard let periodicity = self.detail.formatPeriodicity else { return nil }
        return periodicity.camelCasedString
    }
    
    var openingDate: String? {
        return self.detail.openingDate?.toString(TimeFormat.d_MMM_yyyy.rawValue, locale: self.locale)
    }
    
    var lastOperationDate: String? {
        return self.detail.lastOperationDate?.toString(TimeFormat.d_MMM_yyyy.rawValue, locale: self.locale)
    }
    
    var nextInstallmentDate: String? {
        return self.detail.nextInstallmentDate?.toString(TimeFormat.d_MMM_yyyy.rawValue, locale: self.locale)
    }
    
    var initialExpirationDate: String? {
        return self.detail.initialDueDate?.toString(TimeFormat.d_MMM_yyyy.rawValue, locale: self.locale)
    }
    
    var currentExpirationDate: String? {
        return self.detail.currentDueDate?.toString(TimeFormat.d_MMM_yyyy.rawValue, locale: self.locale)
    }
    
    func addAlias(alias: String, isAliasNeeded: Bool) {
        guard isAliasNeeded else { return }
        let loanAliasDetailView = LoanDetailProduct(
            title: localized("productDetail_label_alias"),
            value: alias,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailAlias.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailAliasValue.rawValue,
            iconIdentifier: nil
        )
        values.append(loanAliasDetailView)
    }
    
    func addAssociatedAccount(associatedAccount: String?) {
        guard let associatedAccount = associatedAccount else { return }
        let loanAccountDetailView = LoanDetailProduct(
            title: localized("productDetail_label_associatedAccount"),
            value: associatedAccount,
            type: .icon,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailAssociatedAccount.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailAssociatedAccountValue.rawValue,
            iconIdentifier: AccessibilityIDLoanDetail.detailAssociatedAccountShare.rawValue
        )
        values.append(loanAccountDetailView)
    }
    
    func addFirstHolder(firstHolder: String?, isEnabledFirstHolder: Bool) {
        guard let firstHolder = firstHolder, isEnabledFirstHolder else { return }
        let firstHolderView = LoanDetailProduct(
            title: localized("productDetail_label_firstHolder"),
            value: firstHolder,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailFirstHolder.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailFirstHolderValue.rawValue,
            iconIdentifier: nil
        )
        values.append(firstHolderView)
    }
    
    func addSeedAmount(seedAmount: String?) {
        guard let seedAmount = seedAmount else { return }
        let seedAmountView = LoanDetailProduct(
            title: localized("productDetail_label_seedAmount"),
            value: seedAmount,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailSeedAmount.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailSeedAmountValue.rawValue,
            iconIdentifier: nil
        )
        values.append(seedAmountView)
    }
    
    func addInterestRate(interestRate: String?) {
        guard let interestRate = interestRate else { return }
        let taxAmountView = LoanDetailProduct(
            title: localized("productDetail_label_interestRate"),
            value: interestRate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailInterestRate.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailInterestRateValue.rawValue,
            iconIdentifier: nil
        )
        values.append(taxAmountView)
    }

    func addReferenceRate(referenceRate: String?) {
        guard let referenceRate = referenceRate else { return }
        let rateTypeView = LoanDetailProduct(
            title: localized("productDetail_label_interestClass"),
            value: referenceRate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailInterestClass.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailInterestClassValue.rawValue,
            iconIdentifier: nil
        )
        values.append(rateTypeView)
    }

    func addPeriodicity(periodicity: String?) {
        guard let periodicity = periodicity else { return }
        let periodicityView = LoanDetailProduct(
            title: localized("productDetail_label_periodicityPayments"),
            value: localized(periodicity),
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailPeriodicityPayments.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailPeriodicityPaymentsValue.rawValue,
            iconIdentifier: nil
        )
        values.append(periodicityView)
    }
    
    func addOpeningDate(openingDate: String?) {
        guard let openingDate = openingDate else { return }
        let openingDateView = LoanDetailProduct(
            title: localized("productDetail_label_openingDate"),
            value: openingDate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailOpeningDate.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailOpeningDateValue.rawValue,
            iconIdentifier: nil
        )
        values.append(openingDateView)
    }

    func addInitialExpirationDate(initialExpirationDate: String?, isEnabledInitialExpiration: Bool) {
        guard let initialExpirationDate = initialExpirationDate, isEnabledInitialExpiration else { return }
        let initialExpirationDateView = LoanDetailProduct(
            title: localized("productDetail_label_initialExpiration"),
            value: initialExpirationDate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailInitialExpiration.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailInitialExpirationValue.rawValue,
            iconIdentifier: nil
        )
        values.append(initialExpirationDateView)
    }
    
    func addCurrentInterestAmount(currentInterestAmount: String?, isEnabledCurrentInterestAmount: Bool) {
        guard let currentInterestAmount = currentInterestAmount, isEnabledCurrentInterestAmount else { return }
        let currentInterestAmountView = LoanDetailProduct(
            title: localized("productDetail_label_currentInterestAmount"),
            value: currentInterestAmount,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailCurrentInterestAmount.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailCurrentInterestAmountValue.rawValue,
            iconIdentifier: nil
        )
        values.append(currentInterestAmountView)
    }
    
    func addLastOperationDate(lastOperationDate: String?, isEnabledLastOperationDate: Bool) {
        guard let lastOperationDate = lastOperationDate, isEnabledLastOperationDate else { return }
        let lastOperationDateView = LoanDetailProduct(
            title: localized("productDetail_label_lastOperationDate"),
            value: lastOperationDate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailLastOperationDate.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailLastOperationDateValue.rawValue,
            iconIdentifier: nil
        )
        values.append(lastOperationDateView)
    }
    
    func addNextInstallmentDate(nextInstallmentDate: String?, isEnabledNextInstallmentDate: Bool) {
        guard let nextInstallmentDate = nextInstallmentDate, isEnabledNextInstallmentDate else { return }
        let nextInstallmentDateView = LoanDetailProduct(
            title: localized("productDetail_label_dateNextInstallment"),
            value: nextInstallmentDate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailNextInstallmentDate.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailNextInstallmentDateValue.rawValue,
            iconIdentifier: nil
        )
        values.append(nextInstallmentDateView)
    }
    
    func addCurrentExpirationDate(currentExpirationDate: String?) {
        guard let currentExpirationDate = currentExpirationDate else { return }
        let currentExpirationDateView = LoanDetailProduct(
            title: localized("productDetail_label_currentExpiration"),
            value: currentExpirationDate,
            type: .basic,
            tooltipText: nil,
            titleIdentifier: AccessibilityIDLoanDetail.detailCurrentExpiration.rawValue,
            valueIdentifier: AccessibilityIDLoanDetail.detailCurrentExpirationValue.rawValue,
            iconIdentifier: nil
        )
        values.append(currentExpirationDateView)
    }
}
