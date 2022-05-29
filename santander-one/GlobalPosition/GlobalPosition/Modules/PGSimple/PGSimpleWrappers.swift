import CoreFoundationLib
import SANLegacyLibrary
import OfferCarousel
import CoreDomain
import Cards
import UI

protocol SimpleGlobalPositionWrapperProtocol: OtherOperativesEvaluator, OfferCarouselBuilderDelegate {
    var configuration: SimpleConfiguration? { get }
    
    func setGPValues(_ gpw: GetPGUseCaseOkOutput, filter: PGInterventionFilter)
    func setAccountState(_ account: AccountEntity, state: PGMovementsNoticesCellState) -> Int?
    func setMovements(_ num: Int?, in account: AccountEntity) -> Int?
    func setMovements(_ num: Int?, in card: CardEntity) -> Int?
    func toCellsDictionary() -> [[PGCellInfo]]
    func removePullOffer(_ pullOffer: PullOfferCompleteInfo)
    func resizePullOffer(_ pullOffer: Any, to size: CGFloat)
    func switchFilterHeader() -> Bool
    func filterDidSelect(_ filter: PGInterventionFilter) -> Bool
    func refreshUserPref(_ gpw: GetPGUseCaseOkOutput?)
    func refreshFilteredSections()
    func isLocationEnabled(_ location: String) -> Bool
    func offerWithLocation(_ location: String) -> OfferEntity?
    func setLoanSimulatorLimits(limits: LoanSimulationLimitsEntity?)
    func setLoanBannerLimits(limits: LoanBannerLimitsEntity)
    func getPullOfferLocation(for location: String) -> OfferEntity?
    func isVisibleAccountsEmpty() -> Bool
    func isAllAccountsEmpty() -> Bool
}

final class SimpleGlobalPositionWrapper {
    
    // MARK: - Attributes
    private let dependenciesResolver: DependenciesResolver
    private let accountAvailableBalance: AccountAvailableBalanceDelegate?
    private var productIdDelegate: ProductIdDelegateProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: ProductIdDelegateProtocol.self)
    }
    private lazy var simpleGlobalPositionModifier: SimpleGlobalPositionModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: SimpleGlobalPositionModifierProtocol.self)
    }()
    var configuration: SimpleConfiguration?
    var visibleAccountList: [PGStatedCellViewModel]?
    var allAccountList: [PGStatedCellViewModel]?
    var cardsList: [PGCardCellViewModel]?
    var stockAccountList: [PGStatedCellViewModel]?
    var loanList: [PGStatedCellViewModel]?
    var depositList: [PGStatedCellViewModel]?
    var pensionList: [PGStatedCellViewModel]?
    var fundsList: [PGStatedCellViewModel]?
    var notManagedPortfolioList: [PGStatedCellViewModel]?
    var managedPortfolioList: [PGStatedCellViewModel]?
    var insuranceSavingsList: [PGStatedCellViewModel]?
    var protectionInsurancesList: [PGStatedCellViewModel]?
    var savingProductsList: [PGStatedCellViewModel]?
    var pullOffersList: [AnyHashable: (PullOfferLocation, CarouselOfferViewModel)] = [:]
    var interventionFilterSelected: PGInterventionFilterModel = PGInterventionFilterModel(filter: .all, selected: false)
    private var lastAccountPosition: Int?
    var filteredAccountList: [PGStatedCellViewModel]?
    var filteredCardsList: [PGCardCellViewModel]?
    var filteredStockAccountList: [PGStatedCellViewModel]?
    var filteredLoanList: [PGStatedCellViewModel]?
    var filteredDepositList: [PGStatedCellViewModel]?
    var filteredPensionList: [PGStatedCellViewModel]?
    var filteredFundsList: [PGStatedCellViewModel]?
    var filteredNotManagedPortfolioList: [PGStatedCellViewModel]?
    var filteredManagedPortfolioList: [PGStatedCellViewModel]?
    var filteredInsuranceSavingsList: [PGStatedCellViewModel]?
    var filteredProtectionInsurancesList: [PGStatedCellViewModel]?
    var filteredSavingProductsList: [PGStatedCellViewModel]?
    private var loanSimulatorViewModel: LoanSimulatorViewModel?
    private var pregrantedViewModel: PregrantedViewModel?
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    private var isTopPG: Bool = false
    private var shouldShowAviosBanner: Bool = false
    private var carouselOfferBuilder: OfferCarouselBuilderProtocol?
    
    // MARK: - Initializers
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.accountAvailableBalance = self.dependenciesResolver.resolve(forOptionalType: AccountAvailableBalanceDelegate.self)
        self.carouselOfferBuilder = self.dependenciesResolver.resolve(forOptionalType: OfferCarouselBuilderProtocol.self)
    }
    
    // MARK: - Public methods
    
    func isLocationEnabled(_ location: String) -> Bool { pullOffersList[location] != nil }
    
    func isVisibleAccountsEmpty() -> Bool { visibleAccountList?.isEmpty ?? true }
    
    func isAllAccountsEmpty() -> Bool { allAccountList?.isEmpty ?? true }
    
    func hasTwoOrMoreAccounts() -> Bool { visibleAccountList?.count ?? 0 >= 2 }
    
    func offerWithLocation(_ location: String) -> OfferEntity? {
        guard let location = pullOffersList[location]?.0 else { return nil }
        return pullOfferCandidates[location]
    }
    
    func setAccountState(_ account: AccountEntity, state: PGMovementsNoticesCellState) -> Int? {
        if let row = getAccountIndex(account) {
            guard visibleAccountList?[row].state != state else { return nil }
            visibleAccountList?[row].state = state
            return row + (lastAccountPosition ?? 0)
        }
        return nil
    }
    
    func isStockholdersEnable() -> Bool {
        configuration?.enableStockholders == true
    }
    func isPregrantedOfferExpired(_ offerId: String) -> Bool {
        return self.carouselOfferBuilder?.isPregrantedOfferExpired(offerId) ?? true
    }
}

private extension SimpleGlobalPositionWrapper {
    enum Constants {
        static let aviosBannerCell = "SimpleGPAviosBannerContainerTableViewCell"
    }
    
    func footerOfAccount(_ account: PGStatedCellViewModel) -> [PGCellInfo] {
        var footer = [PGCellInfo]()
        if account.state != .none {
            footer.append(PGCellInfo(cellClass: "MovementsNoticesTableViewCell", cellHeight: 56.0, info: account.state))
        }
        return footer
    }
    
    func getAccountIndex(_ account: AccountEntity) -> Int? {
        return (visibleAccountList ?? []).firstIndex(where: { ($0.elem as? AccountEntity) == account })
    }
    
    func getCardIndex(_ card: CardEntity) -> Int? {
        return (cardsList ?? []).firstIndex(where: { ($0.elem as? CardEntity) == card })
    }
    
    func matches(_ type: OwnershipTypeDesc?) -> Bool {
        return interventionFilterSelected.filter.matchesFor(type)
    }
    
    func selectLoanId(_ loan: LoanEntity) -> String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: LoanNumberFormatterProtocol.self) else {
            return loan.contractDescription ?? ""
        }
        return numberFormat.loanNumberFormat(loan)
    }
    
    func getAccountIban(_ account: AccountEntity) -> String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return account.getIBANPapel()
        }
        return numberFormat.getIBANFormatted(account.getIban())
    }
    
    func getAccount(_ account: AccountEntity) -> String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return account.contractNumber ?? getAccountIban(account)
        }
        return numberFormat.accountNumberFormat(account)
    }
    
    func moneyDecoratorAbs(_ amount: AmountEntity?,
                           fontFamily: FontFamily = .headline,
                           fontSize: CGFloat = 24.0,
                           decimalSize: CGFloat = 16.0,
                           inAbs: Bool = false) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        return MoneyDecorator(amount,
                              font: UIFont.santander(family: fontFamily, size: fontSize),
                              decimalFontSize: decimalSize).getFormatedAbsWithoutMillion()
    }
    
    func moneyDecorator(_ amount: AmountRepresentable?,
                        fontFamily: FontFamily = .headline,
                        fontSize: CGFloat = 24.0,
                        decimalSize: CGFloat = 16.0,
                        inAbs: Bool = false) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        return MoneyDecorator(AmountEntity(amount),
                              font: UIFont.santander(family: fontFamily, size: fontSize),
                              decimalFontSize: decimalSize).getFormattedStringWithoutMillion()
    }
    
    func createStatedCellViewModel(title: String?,
                                   subtitle: String?,
                                   amountDescriptionKey: String?,
                                   amount: AmountRepresentable?,
                                   rows: [PGStatedCellViewModelRow]?,
                                   elem: Any?) -> PGStatedCellViewModel {
        var allRows = rows ?? []
        if let titleKey = amountDescriptionKey, let amount = amount {
            let attributedAmount = moneyDecorator(amount, fontFamily: .headline, fontSize: 24.0, decimalSize: 16.0)
            allRows.insert(PGStatedCellViewModelRow.titleAmount(titleKey: titleKey, amount: attributedAmount), at: 0)
        }
        return PGStatedCellViewModel(state: .noResults,
                                     title: title,
                                     subtitle: subtitle,
                                     ammount: nil,
                                     rows: allRows,
                                     elem: elem)
    }
}

// MARK: - Extension and conform SimpleGlobalPositionWrapperProtocol

extension SimpleGlobalPositionWrapper: SimpleGlobalPositionWrapperProtocol {    
    
    func getVisibleAccountList(_ visibleAccounts: [AccountEntity]) -> [PGStatedCellViewModel]? {
        return visibleAccounts.map {
            let subtitle = simpleGlobalPositionModifier?.showIbanAccountOnSubtitle != false ? getAccountIban($0) : getAccount($0)
            let amount: AmountRepresentable?
            if let availableBalance = accountAvailableBalance, availableBalance.isEnabled() {
                amount = $0.dto.availableNoAutAmount
            } else {
                amount = $0.dto.currentBalance
            }
            var rows: [PGStatedCellViewModelRow] = []
            if let balanceIncludedPending = $0.dto.balanceIncludedPending {
                let amount = moneyDecorator(balanceIncludedPending, fontFamily: .micro, fontSize: 14, decimalSize: 14)
                rows.append(.titleAmount(titleKey: "pg_label_balancePending", amount: amount))
            }
            if let overdraftRemaining = $0.dto.overdraftRemaining {
                let amount = moneyDecorator(overdraftRemaining, fontFamily: .micro, fontSize: 14, decimalSize: 14)
                rows.append(.titleAmount(titleKey: "pg_label_overdraftRemaining", amount: amount))
            }
            
            return createStatedCellViewModel(title: $0.alias?.noDoubleWhitespaces(),
                                             subtitle: subtitle,
                                             amountDescriptionKey: "pg_label_availableBalance",
                                             amount: amount,
                                             rows: rows,
                                             elem: $0)
        }
    }
    
    func getAllAccountList(_ allAccounts: [AccountEntity]) -> [PGStatedCellViewModel]? {
        return allAccounts.map {
            let subtitle = simpleGlobalPositionModifier?.showIbanAccountOnSubtitle != false ? getAccountIban($0) : getAccount($0)
            let amount: AmountRepresentable?
            if let availableBalance = accountAvailableBalance, availableBalance.isEnabled() {
                amount = $0.dto.availableNoAutAmount
            } else {
                amount = $0.dto.currentBalance
            }
            var rows: [PGStatedCellViewModelRow] = []
            if let balanceIncludedPending = $0.dto.balanceIncludedPending {
                let amount = moneyDecorator(balanceIncludedPending, fontFamily: .micro, fontSize: 14, decimalSize: 14)
                rows.append(.titleAmount(titleKey: "pg_label_balancePending", amount: amount))
            }
            if let overdraftRemaining = $0.dto.overdraftRemaining {
                let amount = moneyDecorator(overdraftRemaining, fontFamily: .micro, fontSize: 14, decimalSize: 14)
                rows.append(.titleAmount(titleKey: "pg_label_overdraftRemaining", amount: amount))
            }
            
            return createStatedCellViewModel(title: $0.alias?.noDoubleWhitespaces(),
                                             subtitle: subtitle,
                                             amountDescriptionKey: "pg_label_availableBalance",
                                             amount: amount,
                                             rows: rows,
                                             elem: $0)
        }
    }
    
    func getCardList(_ cards: [CardEntity], baseURL: String?) -> [PGCardCellViewModel]? {
        return cards.map {
            let amount = $0.cardType == .prepaid ? moneyDecorator($0.amount?.dto) : moneyDecoratorAbs($0.amount)
            return PGCardCellViewModel(
                title: $0.alias?.noDoubleWhitespaces(),
                subtitle: $0.shortContract,
                ammount: amount,
                notification: 0,
                availableBalance:  simpleGlobalPositionModifier?.showCreditCardAvailableAmount == true ? moneyDecoratorAbs($0.availableAmount, fontSize: 16.0, decimalSize: 16.0) : nil,
                imgURL: (baseURL ?? "") + $0.buildImageRelativeUrl(miniature: true),
                customFallbackImage: self.dependenciesResolver.resolve(forOptionalType: CardDefaultFallbackImageModifierProtocol.self)?.defaultGPFallbackImage(card: $0),
                balanceTitle: localized($0.cardHeaderAmountInfoKey),
                disabled: $0.isDisabled,
                toActivate: $0.isInactive,
                elem: $0,
                cardType: CardType(cardType: $0.cardType)
            )
        }
    }
    
    func getTotalFinance(_ total: Decimal?) -> NSAttributedString? {
        guard let totalFinance = total else {
            let differentCurrenciesText: String = localized("pgBasket_label_differentCurrency")
            let builder = TextStylizer.Builder(fullText: differentCurrenciesText)
            let styled = TextStylizer.Builder.TextStyle(word: differentCurrenciesText).setStyle(UIFont.santander(family: .text, type: .bold, size: 32.0))
            return builder.addPartStyle(part: styled).build()
        }
        let entirePartFont = UIFont.santander(family: .text, type: .bold, size: 26.0)
        let amountEntity = AmountEntity(value: totalFinance)
        let moneyDecorator = MoneyDecorator(amountEntity, font: entirePartFont, decimalFontSize: 20.0)
        return moneyDecorator.getFormattedStringWithoutMillion()
    }
    
    func setGPValues(_ gpw: GetPGUseCaseOkOutput, filter: PGInterventionFilter) {
        visibleAccountList = getVisibleAccountList(gpw.visibleAccounts)
        allAccountList = getAllAccountList(gpw.allAccounts)
        cardsList = getCardList(gpw.cards, baseURL: gpw.baseURL)
        stockAccountList = gpw.stockAccount.map {
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: "pg_label_investment",
                                             amount: $0.representable.valueAmountRepresentable,
                                             rows: nil,
                                             elem: $0)
        }
        loanList = gpw.loans.map {
            var rows: [PGStatedCellViewModelRow] = []
            if let repaymentAmount = $0.dto.repaymentAmount {
                let amount = moneyDecorator(repaymentAmount, fontFamily: .micro, fontSize: 14, decimalSize: 14)
                rows.append(.titleAmount(titleKey: "pg_label_repayment", amount: amount))
            }
            return createStatedCellViewModel(title: $0.alias?.noDoubleWhitespaces(),
                                             subtitle: self.selectLoanId($0),
                                             amountDescriptionKey: "pg_label_outstandingAmount",
                                             amount: $0.dto.currentBalance,
                                             rows: rows,
                                             elem: $0)
        }
        depositList = gpw.deposits.map {
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: "pg_label_investment",
                                             amount: $0.dto.balance,
                                             rows: nil,
                                             elem: $0)
        }
        pensionList = gpw.pensions.map {
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: "pg_label_outstandingBalanceDots",
                                             amount: $0.dto.valueAmount,
                                             rows: nil,
                                             elem: $0)
        }
        fundsList = gpw.funds.map {
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: "pg_label_investment",
                                             amount: $0.dto.valueAmount,
                                             rows: nil,
                                             elem: $0)
        }
        notManagedPortfolioList = gpw.notManagedPortfolio.map {
            $0.productId = "NotManagedPortfolio"
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: "pg_label_investment",
                                             amount: $0.dto.consolidatedBalance,
                                             rows: nil,
                                             elem: $0)
        }
        managedPortfolioList = gpw.managedPortfolio.map {
            $0.productId = "ManagedPortfolio"
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: "pg_label_investment",
                                             amount: $0.dto.consolidatedBalance,
                                             rows: nil,
                                             elem: $0)
        }
        insuranceSavingsList = gpw.insuranceSavings.map {
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: gpw.isSavingInsuranceBalanceAvailable ? "pg_label_investment" : nil,
                                             amount: gpw.isSavingInsuranceBalanceAvailable ? $0.dto.importeSaldoActual : nil,
                                             rows: nil,
                                             elem: $0)
        }
        protectionInsurancesList = gpw.protectionInsurances.map {
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: $0.detailUI,
                                             amountDescriptionKey: nil,
                                             amount: nil,
                                             rows: nil,
                                             elem: $0)
        }
        savingProductsList = gpw.savingProducts.map {
            var rows: [PGStatedCellViewModelRow] = []
            if let balanceIncludedPending = $0.dto.balanceIncludedPending {
                let amount = moneyDecorator(balanceIncludedPending, fontFamily: .micro, fontSize: 14, decimalSize: 14)
                rows.append(.titleAmount(titleKey: "pg_label_balancePending", amount: amount))
            }
            let savingInfo = simpleGlobalPositionModifier != nil ? simpleGlobalPositionModifier?.displayInfo(for: $0) : ($0.productIdentifier, "pg_label_investment")
            return createStatedCellViewModel(title: $0.alias,
                                             subtitle: savingInfo?.subtitle,
                                             amountDescriptionKey: savingInfo?.descriptionKey,
                                             amount: $0.dto.currentBalance,
                                             rows: rows,
                                             elem: $0)
        }
        self.setPullOffers(gpw.pullOfferCandidates)
        let totalFinance = getTotalFinance(gpw.totalFinance)
        interventionFilterSelected = PGInterventionFilterModel(filter: filter, selected: false)
        refreshFilteredSections()
        let availableName: String = {
            let alias = gpw.userPref?.getUserAlias() ?? ""
            guard alias.isEmpty else { return alias }
            guard let name: String = gpw.clientNameWithoutSurname, !name.isEmpty else {
                return gpw.clientName?.camelCasedString ?? ""
            }
            return name.camelCasedString
        }()
        shouldShowAviosBanner = gpw.isEnabledAviosZone && gpw.hasAviosProduct
        configuration = SimpleConfiguration(isPb: gpw.isPb,
                                            userName: availableName,
                                            isYourMoneyVisible: true,
                                            userMoney: totalFinance,
                                            userBirthday: gpw.clientBirthDate,
                                            orderedBoxes: gpw.userPref?.getBoxesOrder() ?? [],
                                            isSanflixEnabled: gpw.isSanflixEnabled,
                                            isPregrantedSimulatorEnabled: gpw.isPregrantedSimulatorEnabled,
                                            userId: gpw.userPref?.userId ?? "",
                                            frequentOperatives: gpw.frequentOperatives,
                                            enableStockholders: gpw.enableStockholders)
        buildCarouselOffer(gpw)
    }
    
    func setPullOffers(_ pullOfferCandidates: [PullOfferLocation: OfferEntity]) {
        self.pullOfferCandidates = pullOfferCandidates
        pullOffersList = pullOfferCandidates.reduce([:], { (res, elem) in
            var resCpy = res
            resCpy[elem.key.stringTag] = (
                elem.key,
                CarouselOfferViewModel(imgURL: elem.value.banner?.url,
                                       height: elem.value.banner?.height,
                                       elem: PullOfferCompleteInfo(location: elem.key, entity: elem.value),
                                       transparentClosure: elem.value.transparentClosure))
            return resCpy
        })
    }
    
    func buildCarouselOffer(_ gpw: GetPGUseCaseOkOutput) {
        // Create PGTopConfiguration
        let pregrantedConfiguration = PregrantedConfiguration(
            isVisible: true,
            isPGTopPregrantedBannerEnable: gpw.isPGTopPregrantedBannerEnable,
            pregrantedBannerColor: PregrantedBannerColor(value: (gpw.pregrantedBannerColor).lowercased()),
            pregrantedBannerText: gpw.pregrantedBannerText,
            pgTopPregrantedBannerStartedText: gpw.pgTopPregrantedBannerStartedText
        )
        // Create PGTopCarrouselOffers
        let carouselOfferViewModels = (gpw.topCarrouselOffers ?? []).map({ (offer) in
            return CarouselOfferViewModel(
                imgURL: offer.banner?.url,
                height: offer.banner?.height,
                elem: offer,
                transparentClosure: offer.transparentClosure
            )
        })
        // Build PGTopCorouselComponent
        self.carouselOfferBuilder?.build(
            pregrantedConfiguration: pregrantedConfiguration,
            shouldDisplayRobinsonBanner: gpw.isPGTopPregrantedBannerEnable && gpw.isRobinsonUser,
            carouselOfferViewModels: carouselOfferViewModels,
            pullOfferCandidates: self.pullOfferCandidates
        )
    }
    
    func setMovements(_ num: Int?, in account: AccountEntity) -> Int? {
        var sameNum = false
        visibleAccountList = visibleAccountList?.map({
            guard let acc = $0.elem as? AccountEntity, acc == account else { return $0 }
            var cpy = $0
            sameNum = cpy.notification == num
            cpy.notification = num
            return cpy
        })
        let all = interventionFilterSelected.filter == .all
        filteredAccountList = all ? visibleAccountList : visibleAccountList?.compactMap({ return matches(($0.elem as? AccountEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        return sameNum ? nil : getAccountIndex(account)
    }
    
    func setMovements(_ num: Int?, in card: CardEntity) -> Int? {
        cardsList = cardsList?.map({
            guard let prevCard = $0.elem as? CardEntity, prevCard == card else { return $0 }
            var cpy = $0
            cpy.notification = num
            return cpy
        })
        let all = interventionFilterSelected.filter == .all
        filteredCardsList = all ? cardsList : cardsList?.compactMap({ return matches(($0.elem as? CardEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        return getCardIndex(card)
    }
    
    func removePullOffer(_ pullOffer: PullOfferCompleteInfo) {
        pullOffersList.removeValue(forKey: pullOffer.location.stringTag)
    }
    
    func resizePullOffer(_ pullOffer: Any, to size: CGFloat) {
        if let offerInfo = pullOffer as? PullOfferCompleteInfo, var offer = pullOffersList[offerInfo.location.stringTag] {
            offer.1.height = size
            pullOffersList[offerInfo.location.stringTag]?.1 = offer.1
        }
    }
    
    func switchFilterHeader() -> Bool {
        interventionFilterSelected.selected = !interventionFilterSelected.selected
        return interventionFilterSelected.selected
    }
    
    func filterDidSelect(_ filter: PGInterventionFilter) -> Bool {
        if interventionFilterSelected.filter != filter {
            interventionFilterSelected.filter = filter
            _ = switchFilterHeader()
            refreshFilteredSections()
            return true
        }
        return false
    }
    
    func refreshUserPref(_ gpw: GetPGUseCaseOkOutput?) {
        let availableName: String = {
            let alias = gpw?.userPref?.getUserAlias() ?? ""
            guard alias.isEmpty else { return alias }
            guard let name = gpw?.clientNameWithoutSurname, !name.isEmpty else { return gpw?.clientName?.camelCasedString ?? "" }
            return name.camelCasedString
        }()
        configuration?.userName = availableName
    }
    
    func setLoanSimulatorLimits(limits: LoanSimulationLimitsEntity?) {
        guard let simulatorLocation = self.pullOfferCandidates.filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator }).first, let limits = limits else {
            self.isTopPG = true
            return
        }
        loanSimulatorViewModel = LoanSimulatorViewModel(entity: limits,
                                                        offerLocation: simulatorLocation.key,
                                                        offerEntity: simulatorLocation.value)
        self.isTopPG = self.loanSimulatorViewModel?.amountMaximum == nil
    }
    
    func setLoanBannerLimits(limits: LoanBannerLimitsEntity) {
        carouselOfferBuilder?.setPregrantedBanner(display: true)
        guard let location = self.pullOfferCandidates
            .filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator }).first
        else { return }
        pregrantedViewModel = PregrantedViewModel(entity: limits,
                                                  offerLocation: location.key,
                                                  offerEntity: location.value)
    }
    
    func toCellsDictionary() -> [[PGCellInfo]] {
        var cells = [[PGCellInfo]]()
        lastAccountPosition = nil
        
        func cellInfo(_ className: String = "GeneralProductTableViewCell", cellHeight: CGFloat, info: Any?) -> PGCellInfo {
            return PGCellInfo(cellClass: className, cellHeight: cellHeight, info: info)
        }
        func createSection(_ sec: [Any]?) {
            guard let sec = sec else { return }
            cells.append(contentsOf: sec.map({ [cellInfo(cellHeight: 120.0, info: $0)] }))
        }
        func createPullOffer( _ location: String) {
            if let offer = pullOffersList[location], offer.0.hasBanner {
                cells.append([PGCellInfo(cellClass: "OfferTableViewCell", cellHeight: offer.1.height ?? 81.0, info: offer.1)])
            }
        }
        
        let boxes = configuration?.orderedBoxes ?? []
        
        let sectionActions: [ProductTypeEntity: () -> Void] = [
            .account: {
                createSection(self.filteredAccountList)
                createPullOffer(self.filteredAccountList?.isEmpty ?? true ? "PG_CTA_NO": "PG_CTA_BELOW")
            },
            .card: {
                if let cards = self.filteredCardsList {
                    cells.append(contentsOf: cards.map({ [cellInfo("CardProductTableViewCell", cellHeight: 76.0, info: $0)] }))
                }
                createPullOffer(self.filteredCardsList?.isEmpty ?? true ? "PG_TAR_NO": "PG_TAR_BELOW")
            },
            .deposit: {
                createSection(self.filteredDepositList)
                createPullOffer(self.filteredDepositList?.isEmpty ?? true ? "PG_DEP_NO": "PG_DEP_BELOW")
            },
            .pension: {
                createSection(self.filteredPensionList)
                createPullOffer(self.filteredPensionList?.isEmpty ?? true ? "PG_PLA_NO": "PG_PLA_BELOW")
            },
            .fund: {
                createSection(self.filteredFundsList)
                createPullOffer(self.filteredFundsList?.isEmpty ?? true ? "PG_FON_NO": "PG_FON_BELOW")
            },
            .managedPortfolio: {
                createSection(self.filteredManagedPortfolioList)
            },
            .notManagedPortfolio: {
                createSection(self.filteredNotManagedPortfolioList)
            },
            .stockAccount: {
                createSection(self.filteredStockAccountList)
                createPullOffer(self.filteredStockAccountList?.isEmpty ?? true ? "PG_VAL_NO": "PG_VAL_BELOW")
            },
            .loan: {
                createSection(self.filteredLoanList)
                createPullOffer(self.filteredLoanList?.isEmpty ?? true ? "PG_PRE_NO": "PG_PRE_BELOW")
            },
            .insuranceSaving: {
                createSection(self.filteredInsuranceSavingsList)
                createPullOffer(self.filteredInsuranceSavingsList?.isEmpty ?? true ? "PG_SAI_NO": "PG_SAI_BELOW")
            },
            .insuranceProtection: {
                createSection(self.filteredProtectionInsurancesList)
                createPullOffer(self.filteredProtectionInsurancesList?.isEmpty ?? true ? "PG_SPR_NO": "PG_SPR_BELOW")
            },
            .savingProduct: {
                createSection(self.filteredSavingProductsList)
                createPullOffer(self.filteredSavingProductsList?.isEmpty ?? true ? "PG_SAV_NO": "PG_SAV_BELOW")
            }
        ]
        self.carouselOfferBuilder?.setPregrantedViewModel(pregrantedViewModel: self.pregrantedViewModel)
        self.carouselOfferBuilder?.setPregrantedOfferEntity(pregrantedOfferEntity: self.loanSimulatorViewModel?.offerEntity)
        let offerCarouselViewModel: OfferCarouselViewModel? = self.carouselOfferBuilder?.createOfferCarouselCells()
        var infoCells: [PGCellInfo] = []
        if let offerCarouselViewModel = offerCarouselViewModel {
            infoCells = [PGCellInfo(cellClass: "OfferCarouselTableViewCell",
                                    cellHeight: OfferCarouselConstants.View.cellHeight,
                                    info: offerCarouselViewModel)]
        }
        if infoCells.count > 0 {
            cells.insert(infoCells, at: 0)
        }
        boxes.forEach { sectionActions[$0.asProductType]?() }
        let onlyPGTop: Bool = self.carouselOfferBuilder?.isOnlyGPTop(
            cellsCount: cells.count,
            cellInfos: cells.first,
            isValid: true
        ) ?? false
        if cells.isEmpty || onlyPGTop {
            cells.append([cellInfo("NoResultsTableViewCell", cellHeight: 211.0, info: nil)])
        }
        if shouldShowAviosBanner {
            cells.append([cellInfo(Constants.aviosBannerCell, cellHeight: 56, info: nil)])
        }
        if configuration?.isPb == true && simpleGlobalPositionModifier?.isInterventionFilterEnabled != false {
            var filterSection = [cellInfo("InterventionFilterHeaderTableViewCell", cellHeight: 56.0, info: interventionFilterSelected)]
            if interventionFilterSelected.selected {
                filterSection.append(cellInfo("InterventionFilterOptionTableViewCell",
                                              cellHeight: 175.0,
                                              info: interventionFilterSelected.filter))
            }
            cells.append(filterSection)
        }
        if simpleGlobalPositionModifier?.isConfigureWhatYouSeeVisible != false {
            cells.append([cellInfo("ConfigureYourGPTableViewCell", cellHeight: 58.0, info: nil)])
        }
        return cells
    }
    
    func getPullOfferLocation(for location: String) -> OfferEntity? {
        return (self.pullOffersList[location]?.1.elem as? PullOfferCompleteInfo)?.entity
    }
    
    func refreshFilteredSections() {
        let all = interventionFilterSelected.filter == .all
        filteredAccountList = all ? visibleAccountList : visibleAccountList?.compactMap({ return matches(($0.elem as? AccountEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredCardsList = all ? cardsList : cardsList?.compactMap({ return matches(($0.elem as? CardEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredStockAccountList = all ? stockAccountList : stockAccountList?.compactMap({ return matches(($0.elem as? StockAccountEntity)?.representable.ownershipTypeDesc) ? $0 : nil })
        filteredLoanList = all ? loanList : loanList?.compactMap({ return matches(($0.elem as? LoanEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredDepositList = all ? depositList : depositList?.compactMap({ return matches(($0.elem as? DepositEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredPensionList = all ? pensionList : pensionList?.compactMap({ return matches(($0.elem as? PensionEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredFundsList = all ? fundsList : fundsList?.compactMap({ return matches(($0.elem as? FundEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredNotManagedPortfolioList = all ? notManagedPortfolioList : notManagedPortfolioList?.compactMap({ return matches(($0.elem as? PortfolioEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredManagedPortfolioList = all ? managedPortfolioList : managedPortfolioList?.compactMap({ return matches(($0.elem as? PortfolioEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredInsuranceSavingsList = all ? insuranceSavingsList : insuranceSavingsList?.compactMap({ return matches(($0.elem as? InsuranceSavingEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredProtectionInsurancesList = all ? protectionInsurancesList : protectionInsurancesList?.compactMap({ return matches(($0.elem as? InsuranceProtectionEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredSavingProductsList = all ? savingProductsList : savingProductsList?.compactMap({ return matches(($0.elem as? SavingProductEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
    }
    
    func isCarbonFootprintDisable() -> Bool {
        true
    }
}

// MARK: - OtherOperativesEvaluator
extension SimpleGlobalPositionWrapper {
    var isSmartGP: Bool? { return false }
    
    func isAnalysisDisabled() -> Bool { return true }
    func isFinancingZoneDisabled() -> Bool { return false }
    func isSmartUser() -> Bool { return false }
    func isEnableMarketplace() -> Bool { return false }
    func isPublicProductEnable() -> Bool { return false }
    
    func isConsultPinEnabled() -> Bool {
        return cardsList?.isEmpty ?? true
    }
    func isCardsMenuEmpty() -> Bool {
        return cardsList?.isEmpty ?? true
    }
    
    func isSanflixEnabled() -> Bool {
        return configuration?.isSanflixEnabled ?? false
    }
    
    func getOffer(forLocation location: String) -> PullOfferCompleteInfo? {
        guard let offerLocation = pullOffersList[location]?.0,
              let offerEntity = (self.pullOffersList[location]?.1.elem as? PullOfferCompleteInfo)?.entity else {
            return nil
        }
        return PullOfferCompleteInfo(location: offerLocation, entity: offerEntity)
    }
    
    func getFrequentOperatives() -> [PGFrequentOperativeOptionProtocol]? {
        return configuration?.frequentOperatives
    }
}
