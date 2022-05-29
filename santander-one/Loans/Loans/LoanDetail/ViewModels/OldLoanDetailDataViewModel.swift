import CoreFoundationLib

final class OldLoanDetailDataViewModel {
    private let loanEntity: LoanEntity
    private let loanDetailEntity: LoanDetailEntity
    private let dependenciesResolver: DependenciesResolver
    
    init(loanEntity: LoanEntity, loanDetailEntity: LoanDetailEntity, dependenciesResolver: DependenciesResolver) {
        self.loanEntity = loanEntity
        self.loanDetailEntity = loanDetailEntity
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private lazy var loanDetailModifier: OldLoanDetailModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: OldLoanDetailModifierProtocol.self)
    }()
    
    var alias: String {
        return self.loanEntity.alias?.camelCasedString ?? ""
    }
    
    var associatedAccount: String? {
        return self.loanDetailEntity.linkedAccount
    }
    
    var firstHolder: String {
        return self.loanDetailEntity.holder?.camelCasedString ?? ""
    }
    
    var displayNumber: String {
        guard let loanId = self.loanEntity.contractDisplayNumber else {
            return ""
        }
        return loanId
    }

    var seedAmount: String? {
        guard let initialAmount = loanDetailEntity.initialAmount else { return nil }
        let initialAmountDecorator = MoneyDecorator(initialAmount,
                                  font: UIFont.santander(family: .text,
                                                         type: .regular,
                                                         size: 16.0))
        return initialAmountDecorator.formatAsMillionsWithoutDecimals()?.string
    }
    
    var interestRate: String? {
        return self.loanDetailEntity.interestRate?.camelCasedString
    }
    
    var referenceRate: String? {
        return self.loanDetailEntity.referenceRate?.camelCasedString
    }

    var periodicity: String? {
        guard let periodicity = self.loanDetailEntity.feePeriod else {
            return nil
        }
        guard let formattedPeriodicity = loanDetailModifier?.formatPeriodicity(periodicity) else {
            return periodicity.camelCasedString
        }
        return formattedPeriodicity
    }

    var openingDate: String? {
        return timeManager.toString(date: self.loanDetailEntity.openingDate, outputFormat: .d_MMM_yyyy)
    }

    var initialExpirationDate: String? {
        return timeManager.toString(date: self.loanDetailEntity.initialDueDate, outputFormat: .d_MMM_yyyy)
    }
    
    var lastOperationDate: String? {
        return timeManager.toString(date: self.loanDetailEntity.representable.lastOperationDate, outputFormat: .d_MMM_yyyy)
    }
    
    var nextInstallmentDate: String? {
        return timeManager.toString(date: self.loanDetailEntity.nextInstallmentDate, outputFormat: .d_MMM_yyyy)
    }
    
    var currentInsterestAmount: String? {
        return self.loanDetailEntity.currentInterestAmount
    }

    var currentExpirationDate: String? {
        return timeManager.toString(date: self.loanDetailEntity.currentDueDate, outputFormat: .d_MMM_yyyy)
    }
    
    var availableBigAmountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = loanEntity.currentBalanceAmount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 32)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 18)
        return amount.getFormatedCurrency()
    }
    
    private var isEnabledAlias: Bool {
        guard let isEnabledAlias = loanDetailModifier?.aliasIsNeeded else {
            return true
        }
        return isEnabledAlias
    }
    
    private var isEnabledLastOperationDate: Bool {
        guard let isEnabledLastOperationDate = loanDetailModifier?.isEnabledLastOperationDate else { return false
        }
        return isEnabledLastOperationDate
    }
    
    private var isEnabledNextInstallmentDate: Bool {
        guard let isEnabledNextInstallmentDate = loanDetailModifier?.isEnabledNextInstallmentDate else { return false
        }
        return isEnabledNextInstallmentDate
    }
    
    private var isEnabledCurrentInterestAmount: Bool {
        guard let isEnabledCurrentInterestAmount = loanDetailModifier?.isEnabledCurrentInterestAmount else { return false
        }
        return isEnabledCurrentInterestAmount
    }
    
    private var isEnabledFirstHolder: Bool {
        guard let isEnabledFirstHolder = loanDetailModifier?.isEnabledFirstHolder else {
            return true
        }
        return isEnabledFirstHolder
    }

    private var isEnabledInitialExpiration: Bool {
        guard let isEnabledInitialExpiration = loanDetailModifier?.isEnabledInitialExpiration else {
            return true
        }
        return isEnabledInitialExpiration
    }

    var products: [OldLoanDetailProduct] {
        let builder = OldLoanDetailBuilder()
            .addAlias(alias: self.alias, isAliasNeeded: self.isEnabledAlias)
            .addAssociatedAccount(associatedAccount: self.associatedAccount)
            .addFirstHolder(firstHolder: self.firstHolder,
                            isEnabledFirstHolder: self.isEnabledFirstHolder)
            .addSeedAmount(seedAmount: self.seedAmount)
            .addInterestRate(interestRate: self.interestRate)
            .addReferenceRate(referenceRate: self.referenceRate)
            .addPeriodicity(periodicity: self.periodicity)
            .addCurrentInterestAmount(currentInterestAmount: self.currentInsterestAmount, isEnabledCurrentInterestAmount: isEnabledCurrentInterestAmount)
            .addOpeningDate(openingDate: self.openingDate)
            .addLastOperationDate(lastOperationDate: self.lastOperationDate, isEnabledLastOperationDate: self.isEnabledLastOperationDate)
            .addNextInstallmentDate(nextInstallmentDate: self.nextInstallmentDate, isEnabledNextInstallmentDate: isEnabledNextInstallmentDate)
            .addInitialExpirationDate(initialExpirationDate: self.initialExpirationDate,
                                      isEnabledInitialExpiration: self.isEnabledInitialExpiration)
            .addCurrentExpirationDate(currentExpirationDate: self.currentExpirationDate)
        return builder.build()
    }
}

extension OldLoanDetailDataViewModel: Shareable {
    public func getShareableInfo() -> String {
        return loanEntity.contractDescription ?? ""
    }
}
