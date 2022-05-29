//
//  OtherOperativesWrapper.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 12/02/2020.
//

import Foundation
import CoreFoundationLib

protocol OtherOperativesWrapperProtocol {
    func setOtherOperativesChecks(_ useCase: GetOtherOperativesChecksUseCaseOkOutput)
    func getAllEnableActions() -> [AllOperatives: Any]
}

final class OtherOperativesWrapper: OtherOperativesWrapperProtocol {
    var enabledAccountsActions = [AccountOperativeActionTypeProtocol]()
    var enabledCardsActions =  [CardOperativeActionType]()
    var enabledStocksActions = [StocksActionType]()
    var enabledLoanActions = [LoanActionType]()
    var enabledPensionActions = [PensionActionType]()
    var enabledFundActions = [FundActionType]()
    var enabledInsuranceActions = [InsuranceActionType]()
    var enabledInsuranceProtectionActions = [InsuranceProtectionActionType]()
    var enabledOtherActions = [OtherActionType]()
    var offers: [PullOfferLocation: OfferEntity]?
    private var appConfigRepository: AppConfigRepositoryProtocol?
    private var isOTPExcepted: Bool?
    private var isPb: Bool?
    private var isDemo: Bool?
    private var shouldShowPensionOperatives: Bool = false
    private var isEnrollingCardEnabled: Bool?
    private let dependenciesResolver: DependenciesResolver?
    
    init(_ dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func setOtherOperativesChecks(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        self.appConfigRepository = useCase.appConfigRepository
        self.isOTPExcepted = useCase.isOTPExcepted
        self.offers = useCase.pullOfferCandidates
        self.isPb = useCase.isPb
        self.isDemo = useCase.isDemo
        self.shouldShowPensionOperatives = useCase.shouldShowPensionOperatives
        self.isEnrollingCardEnabled = useCase.isEnrollingCardEnabled
        checkAccountList(visibleAccounts: useCase.visibleAccounts, allAccounts: useCase.allAccounts)
        checkCardsList(cards: useCase.cards)
        checkStocksList(stocks: useCase.stockAccount)
        checkLoansList(loans: useCase.loans)
        checkPensionsList(pensions: useCase.pensions)
        checkFundsList(funds: useCase.funds)
        checkInsuranceSavingsList(insuranceSaving: useCase.insuranceSavings)
        checkInsuranceProtectionsList(insuranceProtection: useCase.protectionInsurances)
        checkCountryOperatives(useCase)
        checkOtherActionsList()
    }
    
    func getAllEnableActions() -> [AllOperatives: Any] {        
        var allEnabledActions = [AllOperatives: Any]()
        allEnabledActions[.accountActions] = enabledAccountsActions
        allEnabledActions[.cardsActions] = enabledCardsActions
        allEnabledActions[.stocksActions] = enabledStocksActions
        allEnabledActions[.loanActions] = enabledLoanActions
        allEnabledActions[.pensionActions] = enabledPensionActions
        allEnabledActions[.fundActions] = enabledFundActions
        allEnabledActions[.insuranceActions] = enabledInsuranceActions
        allEnabledActions[.insuranceProtectionActions] = enabledInsuranceProtectionActions
        allEnabledActions[.otherActions] = enabledOtherActions

        return allEnabledActions
    }
    
    private func isAppConfigEnabled(node: String) -> Bool {
        return self.appConfigRepository?.getBool(node) ?? false
    }
    
    private func isThereCandidateOffer(for location: String, offers: [PullOfferLocation: OfferEntity]) -> Bool {
        return offers.contains(location: location)
    }
    
    // MARK: - Accounts
    
    func checkAccountList(visibleAccounts: [AccountEntity], allAccounts: [AccountEntity]) {
        if !visibleAccounts.isEmpty {
            addBillAndTaxesOperatives(accounts: visibleAccounts)
            enabledAccountsActions.append(AccountOperativeActionType.changeAlias)
        }
        if !allAccounts.isEmpty {
            addTransferOperatives(accounts: allAccounts)
        }
        if allAccounts.count >= 2 {
            addInternalTransferOperatives()
        }
        if let presentOffers = offers {
            if isThereCandidateOffer(for: OperatePullOffers.foreignCurrencyOperate, offers: presentOffers) {
                enabledAccountsActions.append(AccountOperativeActionType.foreignExchange)
            }
            if isThereCandidateOffer(for: OperatePullOffers.donationsOperate, offers: presentOffers) {
                enabledAccountsActions.append(AccountOperativeActionType.donation)
            }
            let isSanflixEnabled = isAppConfigEnabled(node: "enableApplyBySanflix")
            if (isSanflixEnabled && isThereCandidateOffer(for: OperatePullOffers.accountContractOperate, offers: presentOffers)) || !isSanflixEnabled {
                enabledAccountsActions.append(AccountOperativeActionType.contractAccounts)
            }
            if isThereCandidateOffer(for: OperatePullOffers.inboxOperate, offers: presentOffers) {
                enabledAccountsActions.append(AccountOperativeActionType.settingsAlerts)
            }
            if isThereCandidateOffer(for: OperatePullOffers.fxPayOperate, offers: presentOffers) {
                enabledAccountsActions.append(AccountOperativeActionType.fxPay)
            }
            if isThereCandidateOffer(for: OperatePullOffers.ownershipCertificateOperate, offers: presentOffers) {
                enabledAccountsActions.append(AccountOperativeActionType.certificateOfOwnership)
            }
            if isThereCandidateOffer(for: OperatePullOffers.transferOfContractsOperate, offers: presentOffers) {
                enabledAccountsActions.append(AccountOperativeActionType.transferOfContracts)
            }
        }
    }
    
    func addTransferOperatives(accounts: [AccountEntity]) {
        if accounts.allSatisfy({ $0.isPiggyBankAccount }) { return }
        enabledAccountsActions.append(AccountOperativeActionType.transfer)
        enabledAccountsActions.append(AccountOperativeActionType.favoriteTransfer)
    }
    
    func addBillAndTaxesOperatives(accounts: [AccountEntity]) {
        if accounts.allSatisfy({ $0.isPiggyBankAccount }) { return }
        enabledAccountsActions.append(AccountOperativeActionType.payBill)
        enabledAccountsActions.append(AccountOperativeActionType.payTax)
        enabledAccountsActions.append(AccountOperativeActionType.cancelDirectDebit)
    }
    
    func addInternalTransferOperatives() {
        enabledAccountsActions.append(AccountOperativeActionType.internalTransfer)
        enabledAccountsActions.append(AccountOperativeActionType.changeDirectDebit)
    }
    
    // MARK: Stocks
    
    func checkStocksList(stocks: [StockAccountEntity]) {
        guard !stocks.isEmpty else { return }
        guard dependenciesResolver?.resolve(forOptionalType: OtherOperativesModifierProtocol.self)?.isStockAccountsDisabled == true else {
            _ = StocksActionType.allCases.map { enabledStocksActions.append($0)}
            return
        }
    }
    
    // MARK: Loans
    
    func checkLoansList(loans: [LoanEntity]) {
        if !loans.isEmpty {
            if isAppConfigEnabled(node: "enableLoanRepayment") {
                enabledLoanActions.append(.partialAmortization)
            }
            
            if isAppConfigEnabled(node: "enableChangeLoanLinkedAccount") {
                enabledLoanActions.append(.changeAccount)
            }
        }
        if let presentOffers = offers {
            if isThereCandidateOffer(for: OperatePullOffers.inboxOperate, offers: presentOffers) {
                enabledLoanActions.append(.configureAlerts)
            }
        }
    }
    
    // MARK: Pensions
    
    func checkPensionsList(pensions: [PensionEntity]) {
        guard !pensions.isEmpty else { return }
        checkContributionPension(pensions: pensions)
    }
    
    private func checkContributionPension(pensions: [PensionEntity]) {
        guard
            isAppConfigEnabled(node: "enabledPensionOperations"),
            shouldShowPensionOperatives
        else { return }
        enabledPensionActions.append(.extraordinaryContribution)
        enabledPensionActions.append(.periodicalContribution)
    }
    
    // MARK: Funds
    
    func checkFundsList(funds: [FundEntity]) {
        guard !funds.isEmpty else { return }
        self.isSubscriptionFundAvailable(funds)
    }
    
    private func isSubscriptionFundAvailable(_ funds: [FundEntity]) {
        let subcriptionNativeMode = isAppConfigEnabled(node: "fundOperationsSubcriptionNativeMode")
        
        if subcriptionNativeMode {
            let existsOneFund = funds.first { allowsFund($0) }
            
            if existsOneFund != nil {
                enabledFundActions.append(.subscription)
            }
        } else {
            if let presentOffers = offers, isThereCandidateOffer(for: OperatePullOffers.suscriptionFundOperate, offers: presentOffers) {
                enabledFundActions.append(.subscription)
            }
        }
    }

    private func allowsFund(_ fund: FundEntity) -> Bool {
        guard let isPb = self.isPb, let isDemo = self.isDemo else { return false }
        return !fund.isAllianz && (!isPb || isDemo)
    }
    
    // MARK: InsuranceSavings
    
    func checkInsuranceSavingsList(insuranceSaving: [InsuranceSavingEntity]) {
        guard isAppConfigEnabled(node: OperateConstants.appConfigInsuranceDetailEnabled),
              !insuranceSaving.isEmpty,
              let presentOffers = offers
        else { return }
        if isThereCandidateOffer(for: OperatePullOffers.insuranceContributionOperate, offers: presentOffers) {
            enabledInsuranceActions.append(.extraordinaryContribution)
        }
        if isThereCandidateOffer(for: OperatePullOffers.insuranceChangePlanOperate, offers: presentOffers) {
            enabledInsuranceActions.append(.changeRemittancePlan)
        }
        if isThereCandidateOffer(for: OperatePullOffers.insuranceActivatePlanOperate, offers: presentOffers) {
            enabledInsuranceActions.append(.activateRemittancePlan)
        }
    }
    
    // MARK: InsuranceProtection
    
    func checkInsuranceProtectionsList(insuranceProtection: [InsuranceProtectionEntity]) {
        guard isAppConfigEnabled(node: OperateConstants.appConfigInsuranceDetailEnabled),
              !insuranceProtection.isEmpty,
              let presentOffers = offers
        else { return }
        let insuranceSetupOperate = isThereCandidateOffer(for: OperatePullOffers.insurcanceSetupOperate, offers: presentOffers)
        if  insuranceSetupOperate {
            enabledInsuranceProtectionActions.append(.managePolicy)
        }
    }
    
    // MARK: - Cards
    
    func checkCardsList(cards: [CardEntity]) {

        if !cards.isEmpty {
            self.isTurnOffAvailable(cards)
            self.isTurnOnAvailable(cards)
            self.isDirectMoneyAvailable(cards)
            self.isChangePaymentModeAvailable(cards)
            self.isPayLaterAvailable(cards)
            self.isPayOffAvailable(cards)
            self.isPinAvailable(cards)
            self.isCvvAvailable(cards)
            self.isWithdrawMoneyAvailable(cards)
            self.isApplePayAvailable(cards)
            self.isBlockCardAvailable(cards)
            self.enabledCardsActions.append(.mobileTopUp)
            self.isCesSignUpAvailable(cards)
            self.isPdfExtractAvailable(cards)
            if isAppConfigEnabled(node: "enableLimitsChangeCards") {
                self.enabledCardsActions.append(.modifyLimits)
            }
            self.subscriptionsEnabledForCards(cards)
        }
        
        if let presentOffers = offers {
            if isThereCandidateOffer(for: OperatePullOffers.solidarityOperate, offers: presentOffers) {
                enabledCardsActions.append(.solidarityRounding)
            }
            let isSanflixEnabled = isAppConfigEnabled(node: "enableApplyBySanflix")
            if (isSanflixEnabled && isThereCandidateOffer(for: OperatePullOffers.cardContractOperate, offers: presentOffers)) || !isSanflixEnabled {
                enabledCardsActions.append(.hireCard)
            }
            if isThereCandidateOffer(for: OperatePullOffers.inboxOperate, offers: presentOffers) {
                enabledCardsActions.append(.settingsAlerts)
            }
        }
        
        if !cards.isEmpty {
            self.enabledCardsActions.append(.changeAlias)
        }
    }
    
    private func isOnOffEnable() -> Bool {
        if self.isPb ?? false {
            return isAppConfigEnabled(node: "enableOnOffCardsForPBUsers")
        } else {
            return isAppConfigEnabled(node: "enableOnOffCardsForRetailUsers")
        }
    }
    
    private func isTurnOffAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { isReadyForOff(card: $0) }
        
        if existsOneCard != nil && self.isOnOffEnable() {
            enabledCardsActions.append(.offCard)
        }
    }
    
    private func isTurnOnAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { isReadyForOn(card: $0) }
        
        if existsOneCard != nil && self.isOnOffEnable() {
            enabledCardsActions.append(.onCard)
        }
    }
    
    private func isDirectMoneyAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsDirectMoney(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.instantCash)
        }
    }
    
    private func isPayLaterAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsPayLater(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.delayPayment)
        }
    }
    
    private func isChangePaymentModeAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { isCardContractHolder(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.changePaymentMethod)
        }
    }
    
    private func isPdfExtractAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsPdfExtract(card: $0) && isActiveAndNotDisabled(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.pdfExtract)
        }
    }
    
    private func isBlockCardAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsBlock(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.block)
        }
    }
    
    private func isCesSignUpAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsCES(card: $0) }
        
        if existsOneCard != nil && isAppConfigEnabled(node: "enableCesEnrollment") {
            enabledCardsActions.append(.ces)
        }
    }
    
    private func isPayOffAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsPayOff(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.payOff)
        }
    }
    
    private func isApplePayAvailable(_ cards: [CardEntity]) {
        guard isEnrollingCardEnabled == true else { return }
        
        let existsOneCard = cards.first {
            !$0.isContractBlocked
                && !isTemporallyOff(card: $0)
                && !isPrepaidCard(card: $0)
        }
        
        if existsOneCard != nil && isAppConfigEnabled(node: "enableInAppEnrollment") {
            enabledCardsActions.append(.applePay)
        }
    }
    
    private func isWithdrawMoneyAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { allowsWithdrawMoney(card: $0) }
        
        if existsOneCard != nil && isAppConfigEnabled(node: "enableCashWithdrawal") {
            enabledCardsActions.append(.withdrawMoneyWithCode)
        }
    }
    
    private func isPinAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { !isPINAndCVVDisabled(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.pin)
        }
    }
    
    private func isCvvAvailable(_ cards: [CardEntity]) {
        let existsOneCard = cards.first { !isPINAndCVVDisabled(card: $0) }
        
        if existsOneCard != nil {
            enabledCardsActions.append(.cvv)
        }
    }
    
    private func subscriptionsEnabledForCards(_ cards: [CardEntity]) {
        let existOneCard = cards.first {
            $0.isVisible && !$0.isInactive && !$0.isTemporallyOff
        }
        if existOneCard != nil && isAppConfigEnabled(node: CardConstants.isEnabledM4M) {
            enabledCardsActions.append(.subcriptions)
        }
    }

    // MARK: - Other Actions

    private func checkOtherActionsList() {
        guard let presentOffers = offers else { return }
        if isThereCandidateOffer(for: OperatePullOffers.officeAppointmentOperate, offers: presentOffers) {
            enabledOtherActions.append(.officeAppointment)
        }
    }
    
    // MARK: - Functions check somethings about cards
    
    private func isInactiveOrDisabled(card: CardEntity) -> Bool {
        return card.isDisabled || card.isInactive
    }
    
    private func isInactive(card: CardEntity) -> Bool {
        return card.isInactive
    }
    
    private func isTemporallyOff(card: CardEntity) -> Bool {
        return card.isTemporallyOff
    }
    
    private func isPrepaidCard(card: CardEntity) -> Bool {
        return card.isPrepaidCard
    }
    
    private func isCardContractHolder(card: CardEntity) -> Bool {
        return card.isCardContractHolder
    }

    private func isPINAndCVVDisabled(card: CardEntity) -> Bool {
        return card.isPINAndCVVDisabled
    }
    
    private func isActiveAndNotDisabled(card: CardEntity) -> Bool {
        return !card.isInactive && !card.isDisabled
    }
    
    private func isReadyForOff(card: CardEntity) -> Bool {
        return !card.isTemporallyOff && !card.inactive
    }
    
    private func isReadyForOn(card: CardEntity) -> Bool {
        return card.isCardContractHolder && !card.inactive && card.isTemporallyOff
    }
    
    private func allowsDirectMoney(card: CardEntity) -> Bool {
        return card.allowsDirectMoney && isAppConfigEnabled(node: "enableDirectMoney")
    }
    
    private func allowsPayLater(card: CardEntity) -> Bool {
        guard let currentBalance = card.currentBalance.value else { return false }
        return card.isContractActive && card.isCardContractHolder && isAppConfigEnabled(node: "enablePayLater") && abs(currentBalance) > 0
    }
    
    private func allowsPayOff(card: CardEntity) -> Bool {
        guard let currentBalance = card.currentBalance.value else { return false }
        return card.isContractActive && card.isCardContractHolder && abs(currentBalance) > 0
    }
    
    private func allowsBlock(card: CardEntity) -> Bool {
        return !card.isContractBlocked
    }
    
    private func allowsWithdrawMoney(card: CardEntity) -> Bool {
        return card.isDebitCard && card.isContractActive && !card.isTemporallyOff
    }
    
    private func allowsPdfExtract(card: CardEntity) -> Bool {
        return card.isCardContractHolder
    }
    
    private func allowsCES(card: CardEntity) -> Bool {
        guard let isOtpExcepted = self.isOTPExcepted else { return false }
        return card.isContractActive && !card.isPrepaidCard && !isOtpExcepted
    }
}

private extension OtherOperativesWrapper {    
    func checkCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        checkAccountsCountryOperatives(useCase)
        checkCardsCountryOperatives(useCase)
        checkLoansCountryOperatives(useCase)
        checkPensionCountryOperatives(useCase)
        checkLoansFundsCountryOperatives(useCase)
        checkInsuranceProtectionCountryOperatives(useCase)
        checkOtherCountryOperatives(useCase)
    }
    
    func checkAccountsCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPAccountOperativeOptionProtocol.self) 
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryAccountOperativeActionType(accounts: useCase.visibleAccounts)
        filterAllCustomActionWithLocations(operative: .accountActions, actions: actions)
    }
    
    func checkCardsCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPCardsOperativeOptionProtocol.self)
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryCardsOperativeActionType(cards: useCase.cards)
        filterAllCustomActionWithLocations(operative: .cardsActions, actions: actions)
    }
    
    func checkLoansCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPLoanOperativeOptionProtocol.self) 
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryLoanOperativeActionType(loans: useCase.loans)
        filterAllCustomActionWithLocations(operative: .loanActions, actions: actions) 
    }
    
    func checkPensionCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPPensionOperativeOptionProtocol.self) 
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryPensionOperativeActionType(pensions: useCase.pensions)
        filterAllCustomActionWithLocations(operative: .pensionActions, actions: actions) 
    }
    
    func checkLoansFundsCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard 
            let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPInvestmentFundOperativeOptionProtocol.self) 
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryFundOperativeActionType(fund: useCase.funds)
        filterAllCustomActionWithLocations(operative: .fundActions, actions: actions) 
    }

    func checkInsuranceProtectionCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard
            let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPInsuranceProtectionOperativeOptionProtocol.self)
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryInsuranceProtectionOperativeActionType(insuranceProtections: useCase.protectionInsurances)
        filterAllCustomActionWithLocations(operative: .insuranceProtectionActions, actions: actions)
    }

    func checkOtherCountryOperatives(_ useCase: GetOtherOperativesChecksUseCaseOkOutput) {
        guard
            let getPGFrequentOperativeOption = self.dependenciesResolver?.resolve(forOptionalType: GetGPOtherOperativeOptionProtocol.self)
        else {
            return
        }
        let actions = getPGFrequentOperativeOption.getCountryOtherOperativeActionType()
        filterAllCustomActionWithLocations(operative: .otherActions, actions: actions)
    }

    func filterAllCustomActionWithLocations(operative: AllOperatives, actions: [Any]) {
        switch operative {    
        case .accountActions: 
            let filtered = actions.compactMap { accountOperative -> AccountOperativeActionType? in
                guard customAccountOperative(accountOperative: accountOperative) else {
                    return nil
                }
                return accountOperative as? AccountOperativeActionType
            }
            filtered.forEach { enabledAccountsActions.append($0) }
            if filtered.isEmpty {
                _ = actions
                    .compactMap({ $0 as? AccountOperativeActionTypeProtocol })
                    .compactMap({ enabledAccountsActions.append($0) })
            }
            
        case .cardsActions: 
            let filtered = actions.compactMap { cardOperative -> CardOperativeActionType? in
                guard customCardOperative(cardOperative: cardOperative) else {
                    return nil
                }
                return cardOperative as? CardOperativeActionType
            }
            filtered.forEach { enabledCardsActions.append($0) }
            
        case .loanActions:
            let filtered = actions.compactMap { loansOperative -> LoanActionType? in
                guard customLoansOperative(loansOperative: loansOperative) else {
                    return nil
                }
                return loansOperative as? LoanActionType
            }
            filtered.forEach { enabledLoanActions.append($0) }
            
        case .pensionActions:
            let filtered = actions.compactMap { pensionOperative -> PensionActionType? in
                guard customPensionOperative(pensionOperative: pensionOperative) else {
                    return nil
                }
                return pensionOperative as? PensionActionType
            }
            filtered.forEach { enabledPensionActions.append($0) }
            
        case .fundActions:
            let filtered = actions.compactMap { fundsOperative -> FundActionType? in
                guard customFundsOperative(fundsOperative: fundsOperative) else {
                    return nil
                }
                return fundsOperative as? FundActionType
            }
            filtered.forEach { enabledFundActions.append($0) }

        case .insuranceProtectionActions:
            let filtered = actions.compactMap { insuranceProtection -> InsuranceProtectionActionType? in
                guard customInsuranceProtectionOperative(insuranceProtectionOperative: insuranceProtection) else {
                    return nil
                }
                return insuranceProtection as? InsuranceProtectionActionType
            }
            filtered.forEach { enabledInsuranceProtectionActions.append($0) }

        case .otherActions:
            let filtered = actions.compactMap { other -> OtherActionType? in
                guard customOtherOperative(otherOperative: other) else {
                    return nil
                }
                return other as? OtherActionType
            }
            filtered.forEach { enabledOtherActions.append($0) }

        default:
            break
        }
    }
    
    func customAccountOperative(accountOperative: Any) -> Bool {
        guard case AccountOperativeActionType.custom(let values) = accountOperative else { return false }
        return self.getValidation(values)
    }
    
    func customCardOperative(cardOperative: Any) -> Bool {
        guard case CardOperativeActionType.custom(let values) = cardOperative else { return false }
        return self.getValidation(values)
    }
    
    func customLoansOperative(loansOperative: Any) -> Bool {
        guard case LoanActionType.custom(let values) = loansOperative else { return false }
        return self.getValidation(values)
    }
    
    func customPensionOperative(pensionOperative: Any) -> Bool {
        guard case PensionActionType.custom(let values) = pensionOperative else { return false }
        return self.getValidation(values)
    }
    
    func customFundsOperative(fundsOperative: Any) -> Bool {
        guard case FundActionType.custom(let values) = fundsOperative else { return false }
        return self.getValidation(values)
    }

    func customInsuranceProtectionOperative(insuranceProtectionOperative: Any) -> Bool {
        guard case InsuranceProtectionActionType.custom(let values) = insuranceProtectionOperative else { return false }
        return self.getValidation(values)
    }

    func customOtherOperative(otherOperative: Any) -> Bool {
        guard case OtherActionType.custom(let values) = otherOperative else { return false }
        return self.getValidation(values)
    }

    func getValidation(_ values: OperativeActionValues) -> Bool {
        switch values.location != nil {
        case true:
            if let offer = offers?.contains(location: values.location ?? ""),
               offer == true,
               !values.isDisabled {
                return true
            } else {
                return false
            }
        case false:
            if !values.isDisabled {
                return true
            } else {
                return false
            }
        }
    }
}
