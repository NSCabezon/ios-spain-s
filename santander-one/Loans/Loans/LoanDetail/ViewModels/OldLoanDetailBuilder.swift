import CoreFoundationLib

final class OldLoanDetailBuilder {
    private var values: [OldLoanDetailProduct] = []
    
    func addAlias(alias: String, isAliasNeeded: Bool) -> Self {
        if isAliasNeeded {
            let loanAliasDetailView = OldLoanDetailProduct(title: localized("productDetail_label_alias"),
                                                        value: alias,
                                                        type: .basic,
                                                        tooltipText: nil,
                                                        titleIdentifier: AccessibilityIDLoanDetail.detailAlias.rawValue,
                                                        valueIdentifier: AccessibilityIDLoanDetail.detailAliasValue.rawValue,
                                                        iconIdentifier: nil)
            values.append(loanAliasDetailView)
        }
        return self
    }
    
    public func addAssociatedAccount(associatedAccount: String?) -> Self {
        if let associatedAccount = associatedAccount {
            let loanAccountDetailView = OldLoanDetailProduct(title: localized("productDetail_label_associatedAccount"),
                                                          value: associatedAccount,
                                                          type: .icon,
                                                          tooltipText: nil,
                                                          titleIdentifier: AccessibilityIDLoanDetail.detailAssociatedAccount.rawValue,
                                                          valueIdentifier: AccessibilityIDLoanDetail.detailAssociatedAccountValue.rawValue,
                                                          iconIdentifier: AccessibilityIDLoanDetail.detailAssociatedAccountShare.rawValue)
            values.append(loanAccountDetailView)
        }
        return self
    }
    
    func addFirstHolder(firstHolder: String?, isEnabledFirstHolder: Bool) -> Self {
        if let firstHolder = firstHolder, isEnabledFirstHolder {
            let firstHolderView = OldLoanDetailProduct(title: localized("productDetail_label_firstHolder"),
                                                    value: firstHolder,
                                                    type: .basic,
                                                    tooltipText: nil,
                                                    titleIdentifier: AccessibilityIDLoanDetail.detailFirstHolder.rawValue,
                                                    valueIdentifier: AccessibilityIDLoanDetail.detailFirstHolderValue.rawValue,
                                                    iconIdentifier: nil)
            values.append(firstHolderView)
        }
        return self
    }
    
    func addSeedAmount(seedAmount: String?) -> Self {
        if let seedAmount = seedAmount {
            let seedAmountView = OldLoanDetailProduct(title: localized("productDetail_label_seedAmount"),
                                                   value: seedAmount,
                                                   type: .basic,
                                                   tooltipText: nil,
                                                   titleIdentifier: AccessibilityIDLoanDetail.detailSeedAmount.rawValue,
                                                   valueIdentifier: AccessibilityIDLoanDetail.detailSeedAmountValue.rawValue,
                                                   iconIdentifier: nil)
            values.append(seedAmountView)
        }
        return self
    }
    
    func addInterestRate(interestRate: String?) -> Self {
        if let interestRate = interestRate {
            let taxAmountView = OldLoanDetailProduct(title: localized("productDetail_label_interestRate"),
                                                  value: interestRate,
                                                  type: .basic,
                                                  tooltipText: nil,
                                                  titleIdentifier: AccessibilityIDLoanDetail.detailInterestRate.rawValue,
                                                  valueIdentifier: AccessibilityIDLoanDetail.detailInterestRateValue.rawValue,
                                                  iconIdentifier: nil)
            values.append(taxAmountView)
        }
        return self
    }

    func addReferenceRate(referenceRate: String?) -> Self {
        if let referenceRate = referenceRate {
            let rateTypeView = OldLoanDetailProduct(title: localized("productDetail_label_interestClass"),
                                                 value: referenceRate,
                                                 type: .basic,
                                                 tooltipText: nil,
                                                 titleIdentifier: AccessibilityIDLoanDetail.detailInterestClass.rawValue,
                                                 valueIdentifier: AccessibilityIDLoanDetail.detailInterestClassValue.rawValue,
                                                 iconIdentifier: nil)
            values.append(rateTypeView)
        }
        return self
    }

    func addPeriodicity(periodicity: String?) -> Self {
        if let periodicity = periodicity {
            let periodicityView = OldLoanDetailProduct(title: localized("productDetail_label_periodicityPayments"),
                                                    value: localized(periodicity),
                                                    type: .basic,
                                                    tooltipText: nil,
                                                    titleIdentifier: AccessibilityIDLoanDetail.detailPeriodicityPayments.rawValue,
                                                    valueIdentifier: AccessibilityIDLoanDetail.detailPeriodicityPaymentsValue.rawValue,
                                                    iconIdentifier: nil)
            values.append(periodicityView)
        }
        return self
    }
    
    func addOpeningDate(openingDate: String?) -> Self {
        if let openingDate = openingDate {
            let openingDateView = OldLoanDetailProduct(title: localized("productDetail_label_openingDate"),
                                                    value: openingDate,
                                                    type: .basic,
                                                    tooltipText: nil,
                                                    titleIdentifier: AccessibilityIDLoanDetail.detailOpeningDate.rawValue,
                                                    valueIdentifier: AccessibilityIDLoanDetail.detailOpeningDateValue.rawValue,
                                                    iconIdentifier: nil)
            values.append(openingDateView)
        }
        return self
    }

    func addInitialExpirationDate(initialExpirationDate: String?, isEnabledInitialExpiration: Bool) -> Self {
        if let initialExpirationDate = initialExpirationDate, isEnabledInitialExpiration {
            let initialExpirationDateView = OldLoanDetailProduct(title: localized("productDetail_label_initialExpiration"),
                                                              value: initialExpirationDate,
                                                              type: .basic,
                                                              tooltipText: nil,
                                                              titleIdentifier: AccessibilityIDLoanDetail.detailInitialExpiration.rawValue,
                                                              valueIdentifier: AccessibilityIDLoanDetail.detailInitialExpirationValue.rawValue,
                                                              iconIdentifier: nil)
            values.append(initialExpirationDateView)
        }
        return self
    }
    
    func addCurrentInterestAmount(currentInterestAmount: String?, isEnabledCurrentInterestAmount: Bool) -> Self {
        if let currentInterestAmount = currentInterestAmount, isEnabledCurrentInterestAmount {
            let currentInterestAmountView = OldLoanDetailProduct(title: localized("productDetail_label_currentInterestAmount"),
                                                              value: currentInterestAmount,
                                                              type: .basic,
                                                              tooltipText: nil,
                                                              titleIdentifier: nil,
                                                              valueIdentifier: nil,
                                                              iconIdentifier: nil)
            values.append(currentInterestAmountView)
        }
        return self
    }
    
    func addLastOperationDate(lastOperationDate: String?, isEnabledLastOperationDate: Bool) -> Self {
        if let lastOperationDate = lastOperationDate, isEnabledLastOperationDate {
            let lastOperationDateView = OldLoanDetailProduct(title: localized("productDetail_label_lastOperationDate"),
                                                              value: lastOperationDate,
                                                              type: .basic,
                                                              tooltipText: nil,
                                                          titleIdentifier: nil,
                                                          valueIdentifier: nil,
                                                          iconIdentifier: nil)
            values.append(lastOperationDateView)
        }
        return self
    }
    
    func addNextInstallmentDate(nextInstallmentDate: String?, isEnabledNextInstallmentDate: Bool) -> Self {
        if let nextInstallmentDate = nextInstallmentDate, isEnabledNextInstallmentDate {
            let nextInstallmentDateView = OldLoanDetailProduct(title: localized("productDetail_label_dateNextInstallment"),
                                                              value: nextInstallmentDate,
                                                              type: .basic,
                                                              tooltipText: nil,
                                                            titleIdentifier: nil,
                                                            valueIdentifier: nil,
                                                            iconIdentifier: nil)
            values.append(nextInstallmentDateView)
        }
        return self
    }
    
    func addCurrentExpirationDate(currentExpirationDate: String?) -> Self {
        if let currentExpirationDate = currentExpirationDate {
            let currentExpirationDateView = OldLoanDetailProduct(title: localized("productDetail_label_currentExpiration"),
                                                              value: currentExpirationDate,
                                                              type: .basic,
                                                              tooltipText: nil,
                                                              titleIdentifier: AccessibilityIDLoanDetail.detailCurrentExpiration.rawValue,
                                                              valueIdentifier: AccessibilityIDLoanDetail.detailCurrentExpirationValue.rawValue,
                                                              iconIdentifier: nil)
            values.append(currentExpirationDateView)
        }
        return self
    }

    func build() -> [OldLoanDetailProduct] {
        return self.values
    }
}
