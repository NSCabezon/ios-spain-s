// swiftlint:disable type_body_length

import CoreFoundationLib
import SANLegacyLibrary
import OfferCarousel
import CoreDomain
import Cards

protocol ClassicGlobalPositionWrapperProtocol: OtherOperativesEvaluator, OfferCarouselBuilderDelegate {
    var configuration: ClassicConfiguration? { get }
    
    func setGPValues(_ gpw: GetPGUseCaseOkOutput, filter: PGInterventionFilter)
    func setNotification(_ num: Int?, in account: AccountEntity) -> (Int?, Int?)
    func setNotification(_ num: Int?, in card: CardEntity) -> (Int?, Int?)
    func toCellsDictionary() -> [PGClassicTableViewCellInfo]
    func switchHeader(_ type: ProductTypeEntity)
    func removePullOffer(_ pullOffer: PullOfferCompleteInfo)
    func resizePullOffer(_ pullOffer: PullOfferCompleteInfo, to size: CGFloat)
    func switchFilterHeader() -> Bool
    func filterDidSelect(_ filter: PGInterventionFilter) -> Bool
    func refreshUserPref(_ gpw: GetPGUseCaseOkOutput?)
    func isSmartUser() -> Bool
    func isEnableMarketplace() -> Bool
    func isOnePayCarouselEnabled() -> Bool
    func getInvestmentPositionPullOffer() -> PullOfferCompleteInfo?
    func isAnalysisDisabled() -> Bool
    func isAllAccountsEmpty() -> Bool
    func isVisibleAccountsEmpty() -> Bool
    func isCardsMenuEmpty() -> Bool
    func isConsultPinEnabled() -> Bool
    func indexOfSection(in cells: [PGClassicTableViewCellInfo], withIdentifier identifier: String) -> Int?
    func setLoanSimulatorLimits(limits: LoanSimulationLimitsEntity?)
    func setLoanBannerLimits(limits: LoanBannerLimitsEntity)
    func accountsSection() -> Int?
    func cardsSection() -> Int?
}

private typealias PullOfferLocationViewModel = (location: PullOfferLocation, cellViewModel: CarouselOfferViewModel)

private extension ClassicGlobalPositionWrapper {
    enum Constants {
        static let aviosBannerCell = "ClassicGPAviosBannerContainerTableViewCell"
    }
}

final class ClassicGlobalPositionWrapper: ClassicGlobalPositionWrapperProtocol {
    
    // MARK: - Attributes
    
    private let dependenciesResolver: DependenciesResolver
    private let accountAvailableBalance: AccountAvailableBalanceDelegate?
    private var isCounterValueEnabled: Bool {
        self.dependenciesResolver.resolve(for: GlobalPositionConfiguration.self).isCounterValueEnabled
    }
    private var productIdDelegate: ProductIdDelegateProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: ProductIdDelegateProtocol.self)
    }
    private var classicGlobalPositionModifier: ClassicGlobalPositionModifierProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: ClassicGlobalPositionModifierProtocol.self)
    }
    var isSmartGP: Bool?
    var configuration: ClassicConfiguration?
    var visibleAccountList: [PGGenericNotificationCellViewModel]?
    var allAccountList: [PGGenericNotificationCellViewModel]?
    var filteredAccountList: [PGGenericNotificationCellViewModel]?
    var cardsList: [PGCardCellViewModel]?
    var filteredCardsList: [PGCardCellViewModel]?
    var stockAccountList: [PGGenericCellViewModel]?
    var filteredStockAccountList: [PGGenericCellViewModel]?
    var stockAccountTotal: Decimal? {
        return (filteredStockAccountList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? StockAccountEntity else { return res }
            if let value = entity.counterValueAmount, isCounterValueEnabled {
                return res + value
            } else if entity.representable.valueAmountRepresentable?.currencyRepresentable?.currencyType == CoreCurrencyDefault.default {
                return res + (entity.representable.valueAmountRepresentable?.value ?? 0.0)
            }
            return nil
        })
    }
    
    var savingProductList: [PGGenericCellViewModel]?
    var filteredSavingProductList: [PGGenericCellViewModel]?
    var savingProductTotal: Decimal? {
        return (filteredSavingProductList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? SavingProductEntity else { return res }
            if let value = entity.counterValueAmount, isCounterValueEnabled {
                return res + value
            } else if entity.dto.currency?.currencyType == CoreCurrencyDefault.default {
                return res + (entity.dto.currentBalance?.value ?? 0.0)
            }
            return nil
        })
    }
    
    var loanList: [PGGenericCellViewModel]?
    var filteredLoanList: [PGGenericCellViewModel]?
    var loanTotal: Decimal? {
        return (filteredLoanList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? LoanEntity else { return res }
            if let value = entity.counterValueCurrentBalanceAmount, isCounterValueEnabled {
                return res + value
            } else if entity.dto.currency?.currencyType == CoreCurrencyDefault.default {
                return res + (entity.dto.currentBalance?.value ?? 0.0)
            }
            return nil
        })
    }
    var depositList: [PGGenericCellViewModel]?
    var filteredDepositList: [PGGenericCellViewModel]?
    var depositTotal: Decimal? {
        return (filteredDepositList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? DepositEntity else { return res }
            if let value = entity.counterValueCurrentBalance, isCounterValueEnabled {
                return res + value
            } else if entity.dto.currency?.currencyType == CoreCurrencyDefault.default {
                return res + (entity.dto.balance?.value ?? 0.0)
            }
            return nil
        })
    }
    var pensionList: [PGGenericCellViewModel]?
    var filteredPensionList: [PGGenericCellViewModel]?
    var pensionTotal: Decimal? {
        return (filteredPensionList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? PensionEntity else { return res }
            if let value = entity.counterValueAmount, isCounterValueEnabled {
                return res + value
            } else if entity.dto.currency?.currencyType == CoreCurrencyDefault.default {
                return res + (entity.dto.valueAmount?.value ?? 0.0)
            }
            return nil
        })
    }
    var fundsList: [PGGenericCellViewModel]?
    var filteredFundsList: [PGGenericCellViewModel]?
    var fundsTotal: Decimal? {
        return (filteredFundsList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? FundEntity else { return res }
            if let value = entity.counterValueAmount, isCounterValueEnabled {
                return res + value
            } else if entity.dto.currency?.currencyType == CoreCurrencyDefault.default {
                return res + (entity.dto.valueAmount?.value ?? 0.0)
            }
            return nil
        })
    }
    var notManagedPortfolioList: [PGGenericCellViewModel]?
    var filteredNotManagedPortfolioList: [PGGenericCellViewModel]?
    var notManagedPortfolioTotal: Decimal {
        return (filteredNotManagedPortfolioList ?? []).reduce(0.0, {
            guard let entity = $1.elem as? PortfolioEntity else { return $0 }
            return $0 + (entity.dto.consolidatedBalance?.value ?? 0.0)
        })
    }
    var managedPortfolioList: [PGGenericCellViewModel]?
    var filteredManagedPortfolioList: [PGGenericCellViewModel]?
    var managedPortfolioTotal: Decimal {
        return (filteredManagedPortfolioList ?? []).reduce(0.0, {
            guard let entity = $1.elem as? PortfolioEntity else { return $0 }
            return $0 + (entity.dto.consolidatedBalance?.value ?? 0.0)
        })
    }
    var insuranceSavingsList: [PGGenericCellViewModel]?
    var filteredInsuranceSavingsList: [PGGenericCellViewModel]?
    var insuranceSavingsTotal: Decimal {
        return (filteredInsuranceSavingsList ?? []).reduce(0.0, {
            guard let entity = $1.elem as? InsuranceSavingEntity else { return $0 }
            return $0 + (entity.dto.importeSaldoActual?.value ?? 0.0)
        })
    }
    var protectionInsurancesList: [PGGenericCellViewModel]?
    var filteredProtectionInsurancesList: [PGGenericCellViewModel]?
    fileprivate var pullOffersList: [AnyHashable: PullOfferLocationViewModel] = [:]
    var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    var bookmarkPullOffers: [(PullOfferBookmarkEntity, [OfferEntity])] = []
    var interventionFilterSelected: PGInterventionFilterModel = PGInterventionFilterModel(filter: .all, selected: false)
    
    private var accountsSec: Int?
    private var cardsSec: Int?
    private var loanSimulatorViewModel: LoanSimulatorViewModel?
    private var pregrantedViewModel: PregrantedViewModel?
    private var shouldShowAviosBanner: Bool = false
    private var carouselOfferBuilder: OfferCarouselBuilderProtocol?
    
    // MARK: - Initializers
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver =  dependenciesResolver
        self.accountAvailableBalance = dependenciesResolver.resolve(forOptionalType: AccountAvailableBalanceDelegate.self)
        self.carouselOfferBuilder = dependenciesResolver.resolve(forOptionalType: OfferCarouselBuilderProtocol.self)
    }
    
    // MARK: - Public methods
    
    func setGPValues(_ gpw: GetPGUseCaseOkOutput, filter: PGInterventionFilter) {
        func createGenericCellViewModel(_ title: String?,
                                        _ subtitle: String?,
                                        _ amount: AmountRepresentable?,
                                        _ elem: Any?) -> PGGenericCellViewModel {
            return PGGenericCellViewModel(title: title,
                                          subtitle: subtitle,
                                          ammount: moneyDecorator(amount),
                                          elem: elem)
        }
        
        visibleAccountList = gpw.visibleAccounts.map { [weak self] in
            let amount: NSAttributedString?
            if let availableBalance = accountAvailableBalance, availableBalance.isEnabled() {
                amount = self?.moneyDecorator($0.dto.availableNoAutAmount)
            } else {
                amount = self?.moneyDecorator($0.dto.currentBalance)
            }
            return PGGenericNotificationCellViewModel(title: $0.alias,
                                                      subtitle: self?.getAccountIban($0),
                                                      ammount: amount,
                                                      elem: $0,
                                                      notification: 0)
        }
        
        allAccountList = gpw.allAccounts.map { [weak self] in
            let amount: NSAttributedString?
            if let availableBalance = accountAvailableBalance, availableBalance.isEnabled() {
                amount = self?.moneyDecorator($0.dto.availableNoAutAmount)
            } else {
                amount = self?.moneyDecorator($0.dto.currentBalance)
            }
            return PGGenericNotificationCellViewModel(title: $0.alias,
                                                      subtitle: self?.getAccountIban($0),
                                                      ammount: amount,
                                                      elem: $0,
                                                      notification: 0)
        }
        
        cardsList = gpw.cards.map {
            let typeCard = $0.cardType.keyGP
            let placeholder = StringPlaceholder(.value, $0.shortContract)
            let amnount = $0.cardType == .prepaid ? moneyDecorator($0.amount?.dto) : moneyDecoratorAbs($0.amount)
            return PGCardCellViewModel(
                title: $0.alias,
                subtitle: localized(typeCard, [placeholder]).text,
                ammount: amnount,
                notification: 0,
                imgURL: (gpw.baseURL ?? "") + $0.buildImageRelativeUrl(miniature: true),
                customFallbackImage: self.dependenciesResolver.resolve(forOptionalType: CardDefaultFallbackImageModifierProtocol.self)?.defaultGPFallbackImage(card: $0),
                balanceTitle: localized($0.cardHeaderAmountInfoKey),
                disabled: $0.isDisabled,
                toActivate: $0.isInactive,
                elem: $0,
                cardType: CardType(cardType: $0.cardType)
            )
        }
        stockAccountList = gpw.stockAccount.map {
            createGenericCellViewModel($0.alias, $0.shortContract, $0.representable.valueAmountRepresentable, $0)
        }
        loanList = gpw.loans.map {
            createGenericCellViewModel($0.alias, self.selectLoanId($0), $0.dto.currentBalance, $0)
        }
        savingProductList = gpw.savingProducts.map {
            createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.currentBalanceRepresentable, $0)
        }
        depositList = gpw.deposits.map {
            createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.balance, $0)
        }
        pensionList = gpw.pensions.map {
            createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.valueAmount, $0)
        }
        fundsList = gpw.funds.map {
            createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.valueAmount, $0)
        }
        notManagedPortfolioList = gpw.notManagedPortfolio.map {
            $0.productId = "NotManagedPortfolio"
            return createGenericCellViewModel($0.alias, $0.detailUI, $0.dto.consolidatedBalance, $0)
        }
        managedPortfolioList = gpw.managedPortfolio.map {
            $0.productId = "ManagedPortfolio"
            return createGenericCellViewModel($0.alias, $0.detailUI, $0.dto.consolidatedBalance, $0)
        }
        insuranceSavingsList = gpw.insuranceSavings.map {
            createGenericCellViewModel($0.alias, $0.detailUI, gpw.isSavingInsuranceBalanceAvailable ? $0.dto.importeSaldoActual : nil, $0)
        }
        protectionInsurancesList = gpw.protectionInsurances.map {
            createGenericCellViewModel($0.alias, $0.detailUI, nil, $0)
        }
        self.pullOfferCandidates = gpw.pullOfferCandidates
        self.bookmarkPullOffers = gpw.bookmarkPullOffers
        pullOffersList = gpw.pullOfferCandidates.reduce([:], { (res, elem) in
            var resCpy = res
            resCpy[elem.key.stringTag] = (elem.key, CarouselOfferViewModel(imgURL: elem.value.banner?.url,
                                                                           height: elem.value.banner?.height,
                                                                           elem: PullOfferCompleteInfo(location: elem.key, entity: elem.value),
                                                                           transparentClosure: elem.value.transparentClosure))
            return resCpy
        })
        interventionFilterSelected = PGInterventionFilterModel(filter: filter, selected: false)
        refreshFilteredSections()
        
        let availableName: String = {
            let alias = gpw.userPref?.getUserAlias() ?? ""
            guard alias.isEmpty else { return alias }
            guard let name = gpw.clientNameWithoutSurname, !name.isEmpty else { return gpw.clientName?.camelCasedString ?? "" }
            return name.camelCasedString
        }()
        self.isSmartGP = gpw.userPref?.globalPositionOnboardingSelected() == GlobalPositionOptionEntity.smart
        self.shouldShowAviosBanner = gpw.isEnabledAviosZone && gpw.hasAviosProduct
        self.configuration = ClassicConfiguration(
            isPb: gpw.isPb,
            userId: gpw.userPref?.userId,
            userName: availableName,
            isYourMoneyVisible: true,
            userBirthday: gpw.clientBirthDate,
            collapsed: gpw.userPref?.getStatusBoxCollapsed() ?? [:],
            enableMarketplace: gpw.enableMarketplace,
            isAnalysisAreaEmpty: analysisAreaState(gpw.userPref,
                                                   analysisAreaEnabled: gpw.isAnalysisAreaEnabled),
            isSmartUser: gpw.userPref?.isSmartUser(),
            orderedBoxes: gpw.userPref?.getBoxesOrder() ?? [],
            isTimeLineEnabled: gpw.isTimelineEnabled,
            isPregrantedSimulatorEnabled: gpw.isPregrantedSimulatorEnabled,
            isOnePayCarouselEnabled: gpw.isClassicOnePayCarouselEnabled,
            isSanflixEnabled: gpw.isSanflixEnabled,
            isPublicProductEnable: gpw.isPublicProductEnable,
            isFinanzingZoneEnabled: gpw.isFinancingZoneEnabled,
            enableStockholders: gpw.enableStockholders,
            frequentOperatives: gpw.frequentOperatives,
            isWhatsNewZoneEnabled: gpw.isWhatsNewZoneEnabled,
            isCarbonFootprintEnabled: gpw.isCarbonFootprintEnabled
        )
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
    
    func toCellsDictionary() -> [PGClassicTableViewCellInfo] {
        let isPb = configuration?.isPb ?? false
        
        var cells = [PGClassicTableViewCellInfo]()
        cardsSec = nil
        accountsSec = nil
        
        let boxes = configuration?.orderedBoxes ?? []
        
        let sections: [ProductTypeEntity: (inout [PGClassicTableViewCellInfo]) -> Void] = [
            .account: createAccountSection,
            .card: createCardSection,
            .deposit: createDepositSection,
            .pension: createPensionSection,
            .fund: createFundSection,
            .managedPortfolio: createManagedPortfolioSection,
            .notManagedPortfolio: createNotManagedPortfolioSection,
            .stockAccount: createStockAccountSection,
            .loan: createLoanSection,
            .savingProduct: createSavingProductSection,
            .insuranceSaving: createInsuranceSavingSection,
            .insuranceProtection: createInsuranceProtection
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
            let cell = PGClassicTableViewCellInfo(header: nil,
                                                  cellInfos: infoCells,
                                                  underCell: nil)
            cells.insert(cell, at: 0)
        }
        boxes.forEach { sections[$0.asProductType]?(&cells) }
        let onlyPGTop: Bool = self.carouselOfferBuilder?.isOnlyGPTop(
            cellsCount: cells.count,
            cellInfos: cells.first?.cellInfos,
            isValid: cells.first?.header == nil
        ) ?? false
        if cells.isEmpty || onlyPGTop {
            cells.append(PGClassicTableViewCellInfo(header: nil, cellInfos: [cellInfo("NoResultsTableViewCell", cellHeight: 211.0, info: nil)], underCell: nil))
        }
        self.createAviosSection(in: &cells)
        if isPb && classicGlobalPositionModifier?.isInterventionFilterEnabled != false {
            var filterSection = [cellInfo("InterventionFilterHeaderTableViewCell", cellHeight: 56.0, info: interventionFilterSelected)]
            if interventionFilterSelected.selected {
                filterSection.append(cellInfo("InterventionFilterOptionTableViewCell",
                                              cellHeight: 175.0,
                                              info: interventionFilterSelected.filter))
            }
            cells.append(PGClassicTableViewCellInfo(header: nil, cellInfos: filterSection, underCell: nil))
        }
        cells.append(PGClassicTableViewCellInfo(header: nil, cellInfos: [cellInfo("ConfigureYourGPTableViewCell", cellHeight: 58.0, info: nil)], underCell: nil))
        let timelineType: PGBookmarkTimelineTypeViewModel
        let addBookmarks: Bool
        if self.configuration?.isTimeLineEnabled == true {
            timelineType = .timeline
            addBookmarks = true
        } else if let timelineLocation = self.pullOfferCandidates.filter({ $0.key.stringTag == GlobalPositionPullOffers.pgTimeline }).first {
            timelineType = .offer(url: timelineLocation.value.banner?.url)
            addBookmarks = true
        } else if bookmarkPullOffers.count > 0 {
            timelineType = .offer(url: nil)
            addBookmarks = true
        } else {
            timelineType = .offer(url: nil)
            addBookmarks = self.configuration?.isPregrantedSimulatorEnabled == true && self.loanSimulatorViewModel != nil
        }
        if addBookmarks {
            let sizeOfferViewModels = createSizeOfferViewModels()
            let bookmarkModel = PGBookmarkTableViewModel(resolver: self.dependenciesResolver,
                                                         timelineType: timelineType,
                                                         loanViewModel: self.loanSimulatorViewModel,
                                                         sizeOfferViewModel: sizeOfferViewModels)
            cells.append(PGClassicTableViewCellInfo(header: nil, cellInfos: [cellInfo("PGBookmarkTableViewCell", cellHeight: 358.0, info: bookmarkModel)], underCell: nil))
        }
        if isOnePayCarouselEnabled() {
            cells.append(PGClassicTableViewCellInfo(header: nil, cellInfos: [cellInfo("OnePayTableViewCell", cellHeight: 240.0, info: nil)], underCell: nil))
        }
        return cells
    }
    
    func setLoanSimulatorLimits(limits: LoanSimulationLimitsEntity?) {
        guard let simulatorLocation = self.pullOfferCandidates.filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator }).first,
              let limits = limits else { return }
        loanSimulatorViewModel = LoanSimulatorViewModel(entity: limits,
                                                        offerLocation: simulatorLocation.key,
                                                        offerEntity: simulatorLocation.value)
    }
    
    func setLoanBannerLimits(limits: LoanBannerLimitsEntity) {
        carouselOfferBuilder?.setPregrantedBanner(display: true)
        guard let location = self.pullOfferCandidates
                .filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator })
                .first
        else { return }
        pregrantedViewModel = PregrantedViewModel(
            entity: limits,
            offerLocation: location.key,
            offerEntity: location.value
        )
    }
    
    func indexOfSection(in cells: [PGClassicTableViewCellInfo], withIdentifier identifier: String) -> Int? {
        return cells
            .enumerated()
            .first(where: { _, element in
                element.cellInfos.first?.cellClass == identifier
            })?.offset
    }
    
    func switchHeader(_ type: ProductTypeEntity) {
        if let state = self.configuration?.collapsed[type] {
            configuration?.collapsed[type] = !state
        }
    }
    
    func setNotification(_ num: Int?, in account: AccountEntity) -> (Int?, Int?) {
        if let row = getAccountIndex(account), visibleAccountList?[row].notification != num {
            visibleAccountList?[row].notification = num
            refreshFilteredAccountSection()
            return (accountsSec, (self.configuration?.collapsed[.account] ?? false) ? getAccountIndex(account, filtered: true) : nil)
        }
        return (nil, nil)
    }
    
    func setNotification(_ num: Int?, in card: CardEntity) -> (Int?, Int?) {
        if let row = getCardIndex(card), cardsList?[row].notification != num {
            cardsList?[row].notification = num
            refreshFilteredCardSection()
            return (cardsSec, (self.configuration?.collapsed[.card] ?? false) ? getCardIndex(card, filtered: true) : nil)
        }
        return (nil, nil)
    }
    
    func removePullOffer(_ pullOffer: PullOfferCompleteInfo) {
        pullOffersList.removeValue(forKey: pullOffer.location.stringTag)
    }
    
    func resizePullOffer(_ pullOffer: PullOfferCompleteInfo, to size: CGFloat) {
        if var offer = pullOffersList[pullOffer.location.stringTag] {
            offer.cellViewModel.height = size
            pullOffersList[pullOffer.location.stringTag]?.cellViewModel = offer.cellViewModel
        }
    }
    
    func isOnePayCarouselEnabled() -> Bool {
        return self.configuration?.isOnePayCarouselEnabled ?? false
    }
    
    func getInvestmentPositionPullOffer() -> PullOfferCompleteInfo? {
        return pullOffersList["posicionSofia"]?.cellViewModel.elem as? PullOfferCompleteInfo
    }
    
    func isSofiaInvestment() -> Bool {
        return pullOffersList["posicionSofia"] != nil
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
    
    func accountsSection() -> Int? {
        return accountsSec
    }
    
    func cardsSection() -> Int? {
        return cardsSec
    }
    
    func isPregrantedOfferExpired(_ offerId: String) -> Bool {
        return self.carouselOfferBuilder?.isPregrantedOfferExpired(offerId) ?? true
    }
}

// MARK: - Private creating section methods

private extension ClassicGlobalPositionWrapper {
    
    func createInsuranceProtection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_insurance"), open: self.isOpen(filteredList: self.filteredProtectionInsurancesList, isCollapsed: self.configuration?.collapsed[.insuranceProtection]), .insuranceProtection, isCollapsable: self.filteredProtectionInsurancesList?.isEmpty == false),
            sections: self.filteredProtectionInsurancesList,
            pullOfferLocation: (self.filteredProtectionInsurancesList ?? []).isEmpty ? GlobalPositionPullOffers.pgSprNo : GlobalPositionPullOffers.pgSpr,
            footer: .none)
    }
    
    func createInsuranceSavingSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_insuranceSaving"), open: self.isOpen(filteredList: self.filteredInsuranceSavingsList, isCollapsed: self.configuration?.collapsed[.insuranceSaving]), .insuranceSaving, isCollapsable: self.filteredInsuranceSavingsList?.isEmpty == false),
            sections: self.filteredInsuranceSavingsList,
            pullOfferLocation: (self.filteredInsuranceSavingsList ?? []).isEmpty ? GlobalPositionPullOffers.pgSaiNo : GlobalPositionPullOffers.pgSai,
            footer: self.hasFooter(filteredList: self.filteredInsuranceSavingsList, basketLabel: "pgBasket_label_totInvestiment", value: self.insuranceSavingsTotal)
        )
    }
    
    func createSavingProductSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells, 
            header: self.createHeader(localized("pgBasket_title_deposits"), open: self.isOpen(filteredList: self.filteredSavingProductList, isCollapsed: self.configuration?.collapsed[.savingProduct]), .savingProduct, isCollapsable: self.filteredSavingProductList?.isEmpty == false),
            sections: self.filteredSavingProductList,
            pullOfferLocation: (self.filteredSavingProductList ?? []).isEmpty ? GlobalPositionPullOffers.pgSavNo : GlobalPositionPullOffers.pgSav,
            footer: self.hasFooter(filteredList: self.filteredSavingProductList, basketLabel: "pgBasket_label_totalValue", value: self.savingProductTotal),
            bottomOffer: GlobalPositionPullOffers.pgSavBelow
        )
    }
    
    func createLoanSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_loans"), open: self.isOpen(filteredList: self.filteredLoanList, isCollapsed: self.configuration?.collapsed[.loan]), .loan, isCollapsable: self.filteredLoanList?.isEmpty == false),
            sections: self.filteredLoanList,
            pullOfferLocation: (self.filteredLoanList ?? []).isEmpty ? GlobalPositionPullOffers.pgPreNo : GlobalPositionPullOffers.pgPre,
            footer: self.hasFooter(filteredList: self.filteredLoanList, basketLabel: "pgBasket_label_totPending", value: self.loanTotal),
            bottomOffer: GlobalPositionPullOffers.pgPreBelow
        )
    }
    
    func createStockAccountSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_stocks"), open: self.isOpen(filteredList: self.filteredStockAccountList, isCollapsed: self.configuration?.collapsed[.stockAccount]), .stockAccount, isCollapsable: self.filteredStockAccountList?.isEmpty == false),
            sections: self.filteredStockAccountList,
            pullOfferLocation: (self.filteredStockAccountList ?? []).isEmpty ? GlobalPositionPullOffers.pgValNo : GlobalPositionPullOffers.pgVal,
            footer: self.hasFooter(filteredList: self.filteredStockAccountList, basketLabel: "pgBasket_label_totInvestiment", value: self.stockAccountTotal),
            bottomOffer: GlobalPositionPullOffers.pgValBelow
        )
    }
    
    func createNotManagedPortfolioSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_portfolioNotManaged"), open: self.configuration?.collapsed[.notManagedPortfolio] ?? true, .notManagedPortfolio, isCollapsable: self.filteredNotManagedPortfolioList?.isEmpty == false),
            sections: self.filteredNotManagedPortfolioList,
            pullOfferLocation: "",
            footer: .always(self.createFooter(localized("pgBasket_label_totInvestiment"), value: self.notManagedPortfolioTotal))
        )
    }
    
    func createManagedPortfolioSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_portfolioManaged"), open: self.configuration?.collapsed[.managedPortfolio] ?? true, .managedPortfolio, isCollapsable: self.filteredManagedPortfolioList?.isEmpty == false),
            sections: self.filteredManagedPortfolioList,
            pullOfferLocation: "",
            footer: .always(self.createFooter(localized("pgBasket_label_totInvestiment"), value: self.managedPortfolioTotal))
        )
    }
    
    func createFundSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_funds"), open: self.isOpen(filteredList: self.filteredFundsList, isCollapsed: self.configuration?.collapsed[.fund]), .fund, isCollapsable: self.filteredFundsList?.isEmpty == false),
            sections: self.filteredFundsList,
            pullOfferLocation: (self.filteredFundsList ?? []).isEmpty ? GlobalPositionPullOffers.pgFonNo : GlobalPositionPullOffers.pgFon,
            footer: self.hasFooter(filteredList: self.filteredFundsList, basketLabel: "pgBasket_label_totInvestiment", value: self.fundsTotal)
        )
    }
    
    func createPensionSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_plans"), open: self.isOpen(filteredList: self.filteredPensionList, isCollapsed: self.configuration?.collapsed[.pension]), .pension, isCollapsable: self.filteredPensionList?.isEmpty == false),
            sections: self.filteredPensionList,
            pullOfferLocation: (self.filteredPensionList ?? []).isEmpty ? GlobalPositionPullOffers.pgPlaNo : GlobalPositionPullOffers.pgPla,
            footer: self.hasFooter(filteredList: self.filteredPensionList, basketLabel: "pgBasket_label_totAmount", value: self.pensionTotal)
        )
    }
    
    func createDepositSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_deposits"), open: self.isOpen(filteredList: self.filteredDepositList, isCollapsed: self.configuration?.collapsed[.deposit]), .deposit, isCollapsable: self.filteredDepositList?.isEmpty == false),
            sections: self.filteredDepositList,
            pullOfferLocation: (self.filteredDepositList ?? []).isEmpty ? GlobalPositionPullOffers.pgDepNo : GlobalPositionPullOffers.pgDep,
            footer: self.hasFooter(filteredList: self.filteredDepositList, basketLabel: "pgBasket_label_totInvestiment", value: self.depositTotal)
        )
    }
    
    func createCardSection(in cells: inout [PGClassicTableViewCellInfo]) {
        var cards = self.filteredCardsList?.map({ self.cellInfo("ClassicCardProductCell", cellHeight: 96.0, info: $0) }) ?? []
        let cardsPlaceHolder = StringPlaceholder(.value, "\(cards.count)")
        let footerTitle: LocalizedStylableText = cards.count > 1 ? PGCommonTexts.localizableTextForElement(.classicCardFooterCell(.plural), placeHolder: cardsPlaceHolder) : PGCommonTexts.localizableTextForElement(.classicCardFooterCell(.singular), placeHolder: cardsPlaceHolder)
        if let pullOfferCell = self.createPullOffer((self.filteredCardsList ?? []).isEmpty ? GlobalPositionPullOffers.pgTarNo : GlobalPositionPullOffers.pgTar) {
            cards.append(pullOfferCell)
        }
        if !cards.isEmpty {
            var maxCardsStringUrls: [String]?
            if let cardsImgStringUrls = self.filteredCardsList?.flatMap({[$0.imgURL]}) {
                maxCardsStringUrls = cardsImgStringUrls.prefix(6).compactMap({$0})
            }
            let footerInfo = self.createFooter(footerTitle, value: nil, footerWhenExpanded: false, cardStringUrls: maxCardsStringUrls)
            cells.append(PGClassicTableViewCellInfo(
                            header: self.createHeader(localized("pgBasket_title_cards"),
                                                      notification: self.filteredCardsList?.reduce(0, { return (Int($0) + ($1.notification ?? 0)) }),
                                                      open: self.isOpen(filteredList: self.filteredCardsList, isCollapsed: self.configuration?.collapsed[.card]), .card, isCollapsable: self.filteredCardsList?.isEmpty == false),
                            cellInfos: cards,
                            footer: cardFooterType(filteredList: self.filteredCardsList, info: footerInfo),
                            underCell: self.createPullOffer(GlobalPositionPullOffers.pgTarBelow)))
            
            self.cardsSec = cells.count - 1
        }
    }
    
    func createAccountSection(in cells: inout [PGClassicTableViewCellInfo]) {
        _ = self.createSection(
            in: &cells,
            header: self.createHeader(localized("pgBasket_title_accounts"),
                                      img: "icnSantanderPg",
                                      notification: self.filteredAccountList?.reduce(0, { return $0 + ($1.notification ?? 0) }),
                                      open: self.isOpen(filteredList: self.filteredAccountList, isCollapsed: self.configuration?.collapsed[.account]),
                                      .account, isCollapsable: self.filteredAccountList?.isEmpty == false),
            sections: self.filteredAccountList,
            pullOfferLocation: (self.filteredAccountList ?? []).isEmpty ? GlobalPositionPullOffers.pgCtaNo : GlobalPositionPullOffers.pgCta,
            footer: self.hasFooter(filteredList: self.filteredAccountList, basketLabel: "pgBasket_label_balance", value: self.getAccountTotal()),
            bottomOffer: GlobalPositionPullOffers.pgCtaBelow) { [weak self] cells in
            self?.accountsSec = cells.count - 1
        }
    }
    
    func createAviosSection(in cells: inout [PGClassicTableViewCellInfo]) {
        guard shouldShowAviosBanner else { return }
        let cellHeight: CGFloat = 56
        let topSeparator: CGFloat = 8
        cells.append(PGClassicTableViewCellInfo(
            header: nil,
            cellInfos: [
                cellInfo(Constants.aviosBannerCell,
                         cellHeight: cellHeight + topSeparator,
                         info: nil)
            ],
            underCell: nil
        )
        )
    }
    
    func createSection(in cells: inout [PGClassicTableViewCellInfo], header: PGClassicGeneralHeaderInfo?, sections: [Any]?, pullOfferLocation: String, footer: PGClassicFooter, bottomOffer: String? = nil, position: Int? = nil, completion: (([PGClassicTableViewCellInfo]) -> Void)? = nil) -> Bool {
        var newSection = sections?.map({ cellInfo(cellHeight: 81.0, info: $0) }) ?? []
        if let pullOfferCell = createPullOffer(pullOfferLocation) {
            newSection.append(pullOfferCell)
        }
        let bottomOfferCell = createPullOffer(bottomOffer)
        guard !newSection.isEmpty else { return false }
        cells.insert(PGClassicTableViewCellInfo(header: header, cellInfos: newSection, footer: footer, underCell: bottomOfferCell), at: position ?? cells.endIndex)
        completion?(cells)
        return true
    }
    
    func cellInfo(_ className: String = "ClassicGeneralProductTableViewCell", cellHeight: CGFloat, info: Any?) -> PGCellInfo {
        return PGCellInfo(cellClass: className, cellHeight: cellHeight, info: info)
    }
    
    func createPullOffer(_ location: String?) -> PGCellInfo? {
        guard let location = location, let offer = pullOffersList[location], offer.location.hasBanner else { return nil }
        return PGCellInfo(cellClass: "OfferTableViewCell", cellHeight: offer.cellViewModel.height ?? 81.0, info: offer.cellViewModel)
    }
    
    func createHeader(_ title: String, img: String? = nil, notification: Int? = nil, open: Bool = true, _ productType: ProductTypeEntity, isCollapsable: Bool) -> PGClassicGeneralHeaderInfo {
        return PGClassicGeneralHeaderInfo(title: title,
                                          imgName: img,
                                          notification: open ? nil : notification,
                                          open: open,
                                          productType: productType,
                                          isCollapsable: isCollapsable
        )
    }
    
    func createFooter(_ title: LocalizedStylableText, value: Decimal?, footerWhenExpanded: Bool = true, cardStringUrls: [String]? = nil) -> GeneralFooterInfo {
        let amount = value != nil ? MoneyDecorator(AmountEntity(value: value ?? 0.0),
                                                   font: UIFont.santander(family: .text,
                                                                          type: .bold,
                                                                          size: 22.0), decimalFontSize: 16.0).formatAsMillions() : nil
        return GeneralFooterInfo(title: title,
                                 amount: amount,
                                 footerWhenExpanded: footerWhenExpanded,
                                 cardsStringURL: cardStringUrls)
    }
    
    func createSizeOfferViewModels() -> [SizeOfferViewModel] {
        let sizeViewModels = bookmarkPullOffers.map { (bookmarkEntity, offers) -> SizeOfferViewModel in
            return SizeOfferViewModel(title: bookmarkEntity.title ?? "", size: bookmarkEntity.size, offers: offers)
        }
        return sizeViewModels
    }
    
    func moneyDecoratorAbs(_ amount: AmountEntity?, fontSize: CGFloat = 22.0, decimalSize: CGFloat = 16.0) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        return MoneyDecorator(amount, font: UIFont.santander(family: .text, size: fontSize), decimalFontSize: decimalSize).getFormatedAbsWith1M()
    }
    
    func moneyDecorator(_ amount: AmountRepresentable?, fontSize: CGFloat = 22.0, decimalSize: CGFloat = 16.0) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        return MoneyDecorator(AmountEntity(amount), font: UIFont.santander(family: .text, size: fontSize), decimalFontSize: decimalSize).formatAsMillions()
    }
    
    func getAccountIndex(_ account: AccountEntity, filtered: Bool = false) -> Int? {
        return ((filtered ? filteredAccountList : visibleAccountList) ?? []).firstIndex(where: { ($0.elem as? AccountEntity) == account })
    }
    
    func getCardIndex(_ card: CardEntity, filtered: Bool = false) -> Int? {
        return ((filtered ? filteredCardsList : cardsList) ?? []).firstIndex(where: { ($0.elem as? CardEntity) == card })
    }
    
    func refreshFilteredSections() {
        let all = interventionFilterSelected.filter == .all
        filteredAccountList = all ? visibleAccountList : visibleAccountList?.compactMap({ return matches(($0.elem as? AccountEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredCardsList = all ? cardsList : cardsList?.compactMap({ return matches(($0.elem as? CardEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredSavingProductList = all ? savingProductList : savingProductList?.compactMap({ return matches(($0.elem as? SavingProductEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredStockAccountList = all ? stockAccountList : stockAccountList?.compactMap({ return matches(($0.elem as? StockAccountEntity)?.representable.ownershipTypeDesc) ? $0 : nil })
        filteredLoanList = all ? loanList : loanList?.compactMap({ return matches(($0.elem as? LoanEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredDepositList = all ? depositList : depositList?.compactMap({ return matches(($0.elem as? DepositEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredPensionList = all ? pensionList : pensionList?.compactMap({ return matches(($0.elem as? PensionEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredFundsList = all ? fundsList : fundsList?.compactMap({ return matches(($0.elem as? FundEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredNotManagedPortfolioList = all ? notManagedPortfolioList : notManagedPortfolioList?.compactMap({ return matches(($0.elem as? PortfolioEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredManagedPortfolioList = all ? managedPortfolioList : managedPortfolioList?.compactMap({ return matches(($0.elem as? PortfolioEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredInsuranceSavingsList = all ? insuranceSavingsList : insuranceSavingsList?.compactMap({ return matches(($0.elem as? InsuranceSavingEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
        filteredProtectionInsurancesList = all ? protectionInsurancesList : protectionInsurancesList?.compactMap({ return matches(($0.elem as? InsuranceProtectionEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
    }
    
    func refreshFilteredAccountSection() {
        let all = interventionFilterSelected.filter == .all
        filteredAccountList = all ? visibleAccountList : visibleAccountList?.compactMap({ return matches(($0.elem as? AccountEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
    }
    
    func refreshFilteredCardSection() {
        let all = interventionFilterSelected.filter == .all
        filteredCardsList = all ? cardsList : cardsList?.compactMap({ return matches(($0.elem as? CardEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
    }
    
    func matches(_ type: OwnershipTypeDesc?) -> Bool {
        return interventionFilterSelected.filter.matchesFor(type)
    }
    
    func analysisAreaState(_ userPref: UserPrefEntity?, analysisAreaEnabled: Bool) -> Bool {
        guard let userPref = userPref, analysisAreaEnabled == true else { return false }
        let accounts = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.account]?.products.map { $0.value }
        let accountsEmpty = (accounts ?? []).filter { $0.isVisible == true }.isEmpty
        let cards = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.card]?.products.map { $0.value }
        let cardsEmpty = (cards ?? []).filter { $0.isVisible == true }.isEmpty
        let loans = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.loan]?.products.map { $0.value }
        let loansEmpty = (loans ?? []).filter { $0.isVisible == true }.isEmpty
        let savingProducts = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.savingProduct]?.products.map { $0.value }
        let savingProductEmpty = (savingProducts ?? []).filter { $0.isVisible == true}.isEmpty
        return !accountsEmpty || !cardsEmpty || !loansEmpty || !savingProductEmpty
    }
    
    func hasFooter(filteredList: [PGGeneralCellViewModelProtocol]?, basketLabel: String, value: Decimal?) -> PGClassicFooter {
        if filteredList?.isEmpty == true {
            return .none
        } else {
            return .always(self.createFooter(localized(basketLabel), value: value))
        }
    }
    
    func isOpen(filteredList: [PGGeneralCellViewModelProtocol]?, isCollapsed: Bool?) -> Bool {
        if filteredList?.isEmpty == true {
            return true
        } else {
            return isCollapsed ?? true
        }
    }
    
    func cardFooterType(filteredList: [PGGeneralCellViewModelProtocol]?, info: GeneralFooterInfo) -> PGClassicFooter {
        if filteredList?.isEmpty == true {
            return .none
        } else {
            return .onlyWhenClosed(info)
        }
    }
    
    func selectLoanId(_ loan: LoanEntity) -> String {
        if let productIdDelegate = productIdDelegate {
            return productIdDelegate.showMaskedLoanId(loan)
        }
        return loan.contractDescription ?? ""
    }
    
    func getAccountIban(_ account: AccountEntity) -> String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return account.getIBANShort
        }
        return numberFormat.accountNumberShortFormat(account)
    }

    func getAccountTotal() -> Decimal? {
        return (filteredAccountList ?? []).reduce(0.0, { (res, elem) in
            guard let res = res else { return nil }
            guard let entity = elem.elem as? AccountEntity else { return res }
            let isAvailableBalanceEnabled = self.accountAvailableBalance?.isEnabled() ?? false
            if let value = entity.getCounterValueAmountValue(), self.isCounterValueEnabled {
                let amount = isAvailableBalanceEnabled ? entity.getCounterValueAvailableAmountValue() : value
                return res + (amount ?? 0.0)
            } else if entity.dto.currency?.currencyType == CoreCurrencyDefault.default {
                let amount = isAvailableBalanceEnabled ? entity.availableAmount?.value : entity.getAmount()?.value
                return res + (amount ?? 0.0)
            }
            return nil
        })
    }
}

// MARK: - OtherOperativesEvaluator
extension ClassicGlobalPositionWrapper {
    func isAnalysisDisabled() -> Bool { return !(configuration?.isAnalysisAreaEmpty ?? true) }
    
    func isFinancingZoneDisabled() -> Bool { return !(configuration?.isFinanzingZoneEnabled ?? false) }
    
    func isConsultPinEnabled() -> Bool { cardsList?.isEmpty ?? true}
    
    func isVisibleAccountsEmpty() -> Bool { visibleAccountList?.isEmpty ?? true }
    
    func isAllAccountsEmpty() -> Bool { allAccountList?.isEmpty ?? true }
    
    func isCardsMenuEmpty() -> Bool { cardsList?.isEmpty ?? true }
    
    func isSmartUser() -> Bool { configuration?.isSmartUser ?? false }
    
    func isEnableMarketplace() -> Bool { configuration?.enableMarketplace ?? false }
    
    func isLocationEnabled(_ location: String) -> Bool { pullOffersList[location] != nil }
    
    func isSanflixEnabled() -> Bool { configuration?.isSanflixEnabled ?? false }
    
    func isPublicProductEnable() -> Bool { configuration?.isPublicProductEnable == true }
    
    func isStockholdersEnable() -> Bool { configuration?.enableStockholders == true }
    
    func hasTwoOrMoreAccounts() -> Bool { visibleAccountList?.count ?? 0 >= 2 }
    
    func getOffer(forLocation location: String) -> PullOfferCompleteInfo? {
        return pullOffersList[location]?.cellViewModel.elem as? PullOfferCompleteInfo
    }
    
    func getFrequentOperatives() -> [PGFrequentOperativeOptionProtocol]? {
        return configuration?.frequentOperatives
    }
    
    func isCarbonFootprintDisable() -> Bool {
        !(configuration?.isCarbonFootprintEnabled ?? false)
    }
}
