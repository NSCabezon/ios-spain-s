//
//  PGSmartWrapper.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 19/12/2019.
//

import CoreFoundationLib
import SANLegacyLibrary
import OfferCarousel
import CoreDomain
import Cards

protocol SmartGlobalPositionWrapperProtocol: OtherOperativesEvaluator, OfferCarouselBuilderDelegate {
    var configuration: SmartConfiguration? { get }
    var interventionFilterSelected: PGInterventionFilter { get }
    var pullOfferCandidates: [PullOfferLocation: OfferEntity] { get }
    func setGPValues(_ gpw: GetPGUseCaseOkOutput, filter: PGInterventionFilter)
    func toCellsDictionary() -> [PGCellInfo]
    func getTopOfferCells() -> [PGCellInfo]
    func setNotification(_ num: Int?, in account: AccountEntity) -> Int?
    func setNotification(_ num: Int?, in account: CardEntity) -> Int?
    func filterDidSelect(_ filter: PGInterventionFilter) -> Bool
    func refreshUserPref(_ userPref: GetPGUseCaseOkOutput?)
    func removePullOffer(_ pullOffer: PullOfferCompleteInfo)
    func setLoanSimulatorLimits(limits: LoanSimulationLimitsEntity?)
    func setLoanBannerLimits(limits: LoanBannerLimitsEntity)
}

private typealias PullOfferLocationViewModel = (location: PullOfferLocation, cellViewModel: CarouselOfferViewModel)

final class SmartGlobalPositionWrapper {
    
    // MARK: - Attributes
    
    private let dependenciesResolver: DependenciesResolver
    private let accountAvailableBalance: AccountAvailableBalanceDelegate?
    private var productIdDelegate: ProductIdDelegateProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: ProductIdDelegateProtocol.self)
    }
    var gpw: GetPGUseCaseOkOutput?
    var configuration: SmartConfiguration?
    var isSmartGP: Bool?
    var visibleAccountList: [PGGenericNotificationCellViewModel]?
    var allAccountList: [PGGenericNotificationCellViewModel]?
    var cardsList: [PGCardCellViewModel]?
    var stockAccountList: [PGSmartGenericCellViewModel]?
    var loanList: [PGSmartGenericCellViewModel]?
    var depositList: [PGSmartGenericCellViewModel]?
    var pensionList: [PGSmartGenericCellViewModel]?
    var fundsList: [PGSmartGenericCellViewModel]?
    var notManagedPortfolioList: [PGSmartGenericCellViewModel]?
    var managedPortfolioList: [PGSmartGenericCellViewModel]?
    var insuranceSavingsList: [PGSmartGenericCellViewModel]?
    var protectionInsurancesList: [PGSmartGenericCellViewModel]?
    var savingsList: [PGSmartGenericCellViewModel]?
    
    var filteredAccountList: [PGGenericNotificationCellViewModel]?
    var filteredCardsList: [PGCardCellViewModel]?
    var filteredStockAccountList: [PGSmartGenericCellViewModel]?
    var filteredLoanList: [PGSmartGenericCellViewModel]?
    var filteredDepositList: [PGSmartGenericCellViewModel]?
    var filteredPensionList: [PGSmartGenericCellViewModel]?
    var filteredFundsList: [PGSmartGenericCellViewModel]?
    var filteredNotManagedPortfolioList: [PGSmartGenericCellViewModel]?
    var filteredManagedPortfolioList: [PGSmartGenericCellViewModel]?
    var filteredInsuranceSavingsList: [PGSmartGenericCellViewModel]?
    var filteredSavingsList: [PGSmartGenericCellViewModel]?
    var filteredProtectionInsurancesList: [PGSmartGenericCellViewModel]?
    var interventionFilterSelected: PGInterventionFilter = PGInterventionFilter.all
    var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    fileprivate var pullOffersList: [AnyHashable: PullOfferLocationViewModel] = [:]
    private var lastAccountPosition: Int?
    private var accountsSec: Int?
    private var cardsSec: Int?
    private let heightCell: CGFloat = 81.0
    private var carouselOfferBuilder: OfferCarouselBuilderProtocol?
    private var isTopPG: Bool = false
    private var loanSimulatorViewModel: LoanSimulatorViewModel?
    private var pregrantedViewModel: PregrantedViewModel?
    private lazy var productModifierUserCase = dependenciesResolver.resolve(forOptionalType: PGGeneralCellViewConfigUseCase.self)
    
    // MARK: - Initializers
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver =  dependenciesResolver
        self.accountAvailableBalance = self.dependenciesResolver.resolve(forOptionalType: AccountAvailableBalanceDelegate.self)
        self.carouselOfferBuilder = self.dependenciesResolver.resolve(forOptionalType: OfferCarouselBuilderProtocol.self)
    }
    
    // MARK: - Public methods
    
    func initLists() {
        initAccountList()
        initCardList()
        initStockAccountList()
        initLoanList()
        initDepositList()
        initPensionList()
        initFundsList()
        initNotManagedPortfolioList()
        initManagedPortfolioList()
        initInsuranceSavingsList()
        initProtectionInsurancesList()
        initSavingsList()
        refreshFilteredSections()
    }
    
    func initAccountList() {
        var notificationsList = [AccountEntity: Int]()
        if let accountList = visibleAccountList {
            accountList.forEach {
                guard let account = $0.elem as? AccountEntity else { return }
                notificationsList[account] = $0.notification
            }
        }
        visibleAccountList = gpw?.visibleAccounts.map { [weak self] in
            let notification = notificationsList[$0] ?? 0
            let amount: NSAttributedString?
            if let availableBalance = self?.accountAvailableBalance, availableBalance.isEnabled() {
                amount = self?.moneyDecorator($0.dto.availableNoAutAmount)
            } else {
                amount = self?.moneyDecorator($0.dto.currentBalance)
            }
            return PGGenericNotificationCellViewModel(title: $0.alias,
                                                      subtitle: self?.getAccountIban($0),
                                                      ammount: amount,
                                                      elem: $0,
                                                      notification: notification,
                                                      discreteMode: gpw?.userPref?.isDiscretModeActivated())
        }
        
        allAccountList = gpw?.allAccounts.map { [weak self] in
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
    }
    
    func initCardList() {
        var notificationsList = [CardEntity: Int]()
        if let cardsList = cardsList {
            cardsList.forEach {
                guard let card = $0.elem as? CardEntity else { return }
                notificationsList[card] = $0.notification
            }
        }
        cardsList = gpw?.cards.map {
            let notification = notificationsList[$0]
            let typeCard = $0.cardType.keyGP
            let placeholder: StringPlaceholder = StringPlaceholder(.value, $0.shortContract)
            let amnount = $0.cardType == .prepaid ? moneyDecorator($0.amount?.dto) : moneyDecoratorAbs($0.amount)
            return PGCardCellViewModel(
                title: $0.alias,
                subtitle: localized(typeCard, [placeholder]).text,
                ammount: amnount,
                notification: notification,
                imgURL: (gpw?.baseURL ?? "") + $0.buildImageRelativeUrl(miniature: true),
                customFallbackImage: self.dependenciesResolver.resolve(forOptionalType: CardDefaultFallbackImageModifierProtocol.self)?.defaultGPFallbackImage(card: $0),
                balanceTitle: localized($0.cardHeaderAmountInfoKey),
                disabled: $0.isDisabled,
                toActivate: $0.isInactive,
                elem: $0,
                discreteMode: gpw?.userPref?.isDiscretModeActivated(),
                cardType: CardType(cardType: $0.cardType)
            )
        }
    }
    
    func initStockAccountList() {
        stockAccountList = gpw?.stockAccount.map {
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.representable.valueAmountRepresentable, $0, "pgProduct_title_stock", localized("pgBasket_label_totInvestiment"))
        }
    }
    
    func initLoanList() {
        loanList = gpw?.loans.map {
            return createGenericCellViewModel($0.alias, self.selectLoanId($0), $0.dto.currentBalance, $0, "pgProduct_title_loan", localized("pgBasket_label_totPending"))
        }
    }
    
    func initDepositList() {
        depositList = gpw?.deposits.map {
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.balance, $0, "pgProduct_title_deposit", localized("pgBasket_label_totInvestiment"))
        }
    }
    func initPensionList() {
        pensionList = gpw?.pensions.map {
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.valueAmount, $0, "pgProduct_title_plan", localized("pgBasket_label_totAmount"))
        }
    }
    func initFundsList() {
        fundsList = gpw?.funds.map {
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.valueAmount, $0, "pgProduct_title_fund", localized("pgBasket_label_totInvestiment"))
        }
    }
    func initNotManagedPortfolioList() {
        notManagedPortfolioList = gpw?.notManagedPortfolio.map {
            $0.productId = "NotManagedPortfolio"
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.consolidatedBalance, $0, "pgProduct_title_portfolioNotManaged", localized("pgBasket_label_totInvestiment"))
        }
    }
    func initManagedPortfolioList() {
        managedPortfolioList = gpw?.managedPortfolio.map {
            $0.productId = "ManagedPortfolio"
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.consolidatedBalance, $0, "pgProduct_title_portfolioManaged", localized("pgBasket_label_totInvestiment"))
        }
    }
    
    func initInsuranceSavingsList() {
        insuranceSavingsList = gpw?.insuranceSavings.map {
            return createGenericCellViewModel($0.alias, $0.detailUI, (gpw?.isSavingInsuranceBalanceAvailable ?? false) ? $0.dto.importeSaldoActual : nil, $0, "pgProduct_title_insuranceSaving", localized("pgBasket_label_totInvestiment"))
        }
    }
    
    func initProtectionInsurancesList() {
        protectionInsurancesList = gpw?.protectionInsurances.map {
            return createGenericCellViewModel($0.alias, $0.detailUI, nil, $0, "pgProduct_title_insurance", nil)
        }
    }
    
    func initSavingsList() {
        savingsList = gpw?.savingProducts.map {
            if let productModifierUserCase = self.productModifierUserCase,
               let result = try? productModifierUserCase.executeUseCase(requestValues: $0).getOkResult() {
                return createGenericCellViewModel(result.title, result.subtitle, $0.dto.currentBalance, $0, "pgProduct_title_saving", localized("pgBasket_label_totInvestiment"))
            }
            return createGenericCellViewModel($0.alias, $0.shortContract, $0.dto.currentBalance, $0, "pgProduct_title_saving", localized("pgBasket_label_totInvestiment"))
        }
    }
    
    func initConfiguration() {
        let totalFinance: NSAttributedString? = {
            guard let totalFinance = gpw?.totalFinance else {
                let differentCurrenciesText: String = localized("pgBasket_label_differentCurrency")
                let builder = TextStylizer.Builder(fullText: differentCurrenciesText)
                let styled = TextStylizer.Builder.TextStyle(word: differentCurrenciesText).setStyle(UIFont.santander(family: .text, type: .bold, size: 32.0))
                return builder.addPartStyle(part: styled).build()
            }
            return MoneyDecorator(AmountEntity(value: totalFinance),
                                  font: UIFont.santander(family: .text, type: .bold, size: 32.0)).formatAsMillions()
        }()
        
        let availableName: String = {
            let alias = gpw?.userPref?.getUserAlias() ?? ""
            guard alias.isEmpty else { return alias }
            guard let name: String = gpw?.clientNameWithoutSurname, !name.isEmpty else {
                return gpw?.clientName?.camelCasedString ?? ""
            }
            return name.camelCasedString
        }()
        self.isSmartGP = gpw?.userPref?.globalPositionOnboardingSelected() == GlobalPositionOptionEntity.smart
        configuration = SmartConfiguration(
            isPb: gpw?.isPb ?? false,
            userName: availableName,
            userId: gpw?.userPref?.userId,
            isYourMoneyVisible: true,
            userMoney: totalFinance,
            userBirthday: gpw?.clientBirthDate,
            pgColorMode: gpw?.userPref?.userPrefDTOEntity.pgUserPrefDTO.pgColorMode ?? .red,
            discreteMode: gpw?.userPref?.isDiscretModeActivated() ?? false,
            isMarketPlaceEnabled: gpw?.enableMarketplace ?? false,
            isAnalysisAreaEmpty: isAnalysisAreaEmpty(gpw?.userPref,
                                                     analysisAreaEnabled: gpw?.isAnalysisAreaEnabled ?? false),
            isSmartOnePayCarouselEnabled: gpw?.isSmartOnePayCarouselEnabled ?? false,
            isSanflixEnabled: gpw?.isSanflixEnabled ?? false,
            isPublicProductEnabled: gpw?.isPublicProductEnable ?? false,
            isFinanzingZoneEnabled: gpw?.isFinancingZoneEnabled ?? false,
            frequentOperatives: gpw?.frequentOperatives,
            isWhatsNewZoneEnabled: gpw?.isWhatsNewZoneEnabled,
            shouldShowAviosBanner: gpw?.isEnabledAviosZone == true && gpw?.hasAviosProduct == true,
            enableStockholders: gpw?.enableStockholders ?? false,
            isCarbonFootprintEnabled: gpw?.isCarbonFootprintEnabled ?? false
        )
    }
}

private extension SmartGlobalPositionWrapper {
    func getAccountIndex(_ account: AccountEntity, filtered: Bool = false) -> Int? {
        return ((filtered ? filteredAccountList : visibleAccountList) ?? []).firstIndex(where: { ($0.elem as? AccountEntity) == account })
    }
    
    func getCardIndex(_ card: CardEntity, filtered: Bool = false) -> Int? {
        return ((filtered ? filteredCardsList : cardsList) ?? []).firstIndex(where: { ($0.elem as? CardEntity) == card })
    }
    
    func createGenericCellViewModel(_ title: String?,
                                    _ subtitle: String?,
                                    _ amount: AmountRepresentable?,
                                    _ elem: Any?,
                                    _ producName: String?,
                                    _ basketName: String?) -> PGSmartGenericCellViewModel {
        return PGSmartGenericCellViewModel(title: title,
                                           subtitle: subtitle,
                                           ammount: moneyDecorator(amount),
                                           elem: elem,
                                           producName: producName,
                                           basketName: basketName,
                                           discreteMode: gpw?.userPref?.isDiscretModeActivated())
    }
    
    func moneyDecoratorAbs(_ amount: AmountEntity?, fontSize: CGFloat = 20.0, decimalSize: CGFloat = 13.0, inAbs: Bool = false) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        return MoneyDecorator(amount, font: UIFont.santander(family: .text, type: .bold, size: fontSize), decimalFontSize: decimalSize).getFormatedAbsWith1M()
    }
    
    func moneyDecorator(_ amount: AmountRepresentable?, fontSize: CGFloat = 24.0, decimalSize: CGFloat = 16.0, inAbs: Bool = false) -> NSAttributedString? {
        guard let amount = amount else { return nil }
        return MoneyDecorator(AmountEntity(amount), font: UIFont.santander(family: .text, type: .bold, size: fontSize), decimalFontSize: decimalSize).formatAsMillions()
    }
    
    func refreshFilteredSections() {
        let all = interventionFilterSelected == .all
        filteredAccountList = all ? visibleAccountList : visibleAccountList?.compactMap { return matches(($0.elem as? AccountEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredCardsList = all ? cardsList : cardsList?.compactMap { return matches(($0.elem as? CardEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredStockAccountList = all ? stockAccountList : stockAccountList?.compactMap { return matches(($0.elem as? StockAccountEntity)?.representable.ownershipTypeDesc) ? $0 : nil }
        filteredLoanList = all ? loanList : loanList?.compactMap { return matches(($0.elem as? LoanEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredDepositList = all ? depositList : depositList?.compactMap { return matches(($0.elem as? DepositEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredPensionList = all ? pensionList : pensionList?.compactMap { return matches(($0.elem as? PensionEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredFundsList = all ? fundsList : fundsList?.compactMap { return matches(($0.elem as? FundEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredNotManagedPortfolioList = all ? notManagedPortfolioList : notManagedPortfolioList?.compactMap { return matches(($0.elem as? PortfolioEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredManagedPortfolioList = all ? managedPortfolioList : managedPortfolioList?.compactMap { return matches(($0.elem as? PortfolioEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredInsuranceSavingsList = all ? insuranceSavingsList : insuranceSavingsList?.compactMap { return matches(($0.elem as? InsuranceSavingEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredProtectionInsurancesList = all ? protectionInsurancesList : protectionInsurancesList?.compactMap { return matches(($0.elem as? InsuranceProtectionEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
        filteredSavingsList = all ? savingsList : savingsList?.compactMap { return matches(($0.elem as? SavingProductEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
    }
    
    func refreshFilteredAccountSection() {
        let all = interventionFilterSelected == .all
        filteredAccountList = all ? visibleAccountList : visibleAccountList?.compactMap { return matches(($0.elem as? AccountEntity)?.dto.ownershipTypeDesc) ? $0 : nil }
    }
    
    func refreshFilteredCardSection() {
        let all = interventionFilterSelected == .all
        filteredCardsList = all ? cardsList : cardsList?.compactMap({ return matches(($0.elem as? CardEntity)?.dto.ownershipTypeDesc) ? $0 : nil })
    }
    
    func matches(_ type: OwnershipTypeDesc?) -> Bool {
        return interventionFilterSelected.matchesFor(type)
    }
    
    func isAnalysisAreaEmpty(_ userPref: UserPrefEntity?, analysisAreaEnabled: Bool) -> Bool {
        guard let userPref = userPref, analysisAreaEnabled == true else { return false }
        
        let accounts = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.account]?.products.map { $0.value }
        let accountsEmpty = (accounts ?? []).filter { $0.isVisible == true }.isEmpty
        
        let cards = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.card]?.products.map { $0.value }
        let cardsEmpty = (cards ?? []).filter { $0.isVisible == true }.isEmpty
        
        let loans = userPref.userPrefDTOEntity.pgUserPrefDTO.boxes[.loan]?.products.map { $0.value }
        let loansEmpty = (loans ?? []).filter { $0.isVisible == true }.isEmpty
        
        return !accountsEmpty || !cardsEmpty || !loansEmpty
    }
    
    func initPGTopCarouselModule(_ gpw: GetPGUseCaseOkOutput) {
        // Create PGTopConfiguration
        let pregrantedConfiguration = PregrantedConfiguration(
            isVisible: true,
            isPGTopPregrantedBannerEnable: gpw.isPGTopPregrantedBannerEnable,
            pregrantedBannerColor: PregrantedBannerColor.smart,
            pregrantedBannerText: gpw.pregrantedBannerText,
            pgTopPregrantedBannerStartedText: gpw.pgTopPregrantedBannerStartedText
        )// Create PGTopCarrouselOffers
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
    
    func cellInfo(_ className: String = "SmartGenericProductCollectionViewCell", cellHeight: CGFloat, info: Any?) -> PGCellInfo {
        return PGCellInfo(cellClass: className, cellHeight: cellHeight, info: info)
    }
    
    func createSection(in cells: inout [PGCellInfo], sections: [Any]?, pullOfferLocation: String? = nil) -> Bool {
        var newSection = sections?.map({ cellInfo(cellHeight: heightCell, info: $0) }) ?? []
        if let pullOfferCell = createPullOffer(pullOfferLocation) {
            newSection.append(pullOfferCell)
        }
        guard !newSection.isEmpty else { return false }
        cells.append(contentsOf: newSection)
        return true
    }
    
    func createPullOffer(_ location: String?) -> PGCellInfo? {
        guard let location = location, let offer = pullOffersList[location], offer.location.hasBanner else { return nil }
        return PGCellInfo(cellClass: "SmartOfferCollectionViewCell", cellHeight: heightCell, info: offer.cellViewModel)
    }
    
    func createInsuranceProtection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredProtectionInsurancesList, pullOfferLocation: (self.filteredProtectionInsurancesList ?? []).isEmpty ? "PG_SPR_NO": "PG_SPR_BELOW")
    }
    
    func createInsuranceSavingSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredInsuranceSavingsList, pullOfferLocation: (self.filteredInsuranceSavingsList ?? []).isEmpty ? "PG_SAI_NO": "PG_SAI_BELOW")
    }
    
    func createSavingSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredSavingsList, pullOfferLocation: (self.filteredSavingsList ?? []).isEmpty ? GlobalPositionPullOffers.pgSaiNo: GlobalPositionPullOffers.pgSaiBelow)
    }
    
    func createLoanSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredLoanList, pullOfferLocation: (self.filteredLoanList ?? []).isEmpty ? "PG_PRE_NO": "PG_PRE_BELOW")
    }
    
    func createStockAccountSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredStockAccountList, pullOfferLocation: (self.filteredStockAccountList ?? []).isEmpty ? "PG_VAL_NO": "PG_VAL_BELOW")
    }
    
    func createNotManagedPortfolioSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredNotManagedPortfolioList)
    }
    
    func createManagedPortfolioSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredManagedPortfolioList)
    }
    
    func createFundSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredFundsList, pullOfferLocation: (self.filteredFundsList ?? []).isEmpty ? "PG_FON_NO": "PG_FON_BELOW")
    }
    
    func createPensionSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredPensionList, pullOfferLocation: (self.filteredPensionList ?? []).isEmpty ? "PG_PLA_NO": "PG_PLA_BELOW")
    }
    
    func createDepositSection(in cells: inout [PGCellInfo]) {
        _ = self.createSection(in: &cells, sections: self.filteredDepositList, pullOfferLocation: (self.filteredDepositList ?? []).isEmpty ? "PG_DEP_NO": "PG_DEP_BELOW")
    }
    
    func createCardSection(in cells: inout [PGCellInfo]) {
        if let cards = self.filteredCardsList {
            self.cardsSec = max(cells.count, 0)
            cells.append(contentsOf: cards.map({ cellInfo("SmartCardCollectionViewCell", cellHeight: 96.0, info: $0) }))
        }
        if let pullOfferCell = self.createPullOffer((self.filteredCardsList ?? []).isEmpty ? "PG_TAR_NO": "PG_TAR_BELOW") {
            cells.append(pullOfferCell)
        }
    }
    
    func createAccountSection(in cells: inout [PGCellInfo]) {
        if let accounts = self.filteredAccountList {
            self.lastAccountPosition = cells.count
            self.accountsSec = max(cells.count, 0)
            cells.append(contentsOf: accounts.map({
                return cellInfo("SmartAccountCollectionViewCell", cellHeight: heightCell, info: $0)
            }))
        }
        if let pullOfferCell = self.createPullOffer((self.filteredAccountList ?? []).isEmpty ? "PG_CTA_NO": "PG_CTA_BELOW") {
            cells.append(pullOfferCell)
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
}

extension SmartGlobalPositionWrapper: SmartGlobalPositionWrapperProtocol {
    func setGPValues(_ gpw: GetPGUseCaseOkOutput, filter: PGInterventionFilter) {
        self.gpw = gpw
        self.interventionFilterSelected = filter
        self.pullOfferCandidates = gpw.pullOfferCandidates
        self.pullOffersList = gpw.pullOfferCandidates.reduce([:], { (res, elem) in
            var resCpy = res
            resCpy[elem.key.stringTag] = (elem.key, CarouselOfferViewModel(
                imgURL: elem.value.banner?.url,
                height: elem.value.banner?.height,
                elem: PullOfferCompleteInfo(location: elem.key, entity: elem.value),
                transparentClosure: elem.value.transparentClosure))
            return resCpy
        })
        self.initLists()
        self.initConfiguration()
        self.initPGTopCarouselModule(gpw)
    }
    
    func toCellsDictionary() -> [PGCellInfo] {
        var cells = [PGCellInfo]()
        self.lastAccountPosition = nil
        self.accountsSec = nil
        self.cardsSec = nil
        let boxes = self.gpw?.userPref?.getBoxesOrder() ?? []
        let sectionActions: [ProductTypeEntity: (inout [PGCellInfo]) -> Void] = [
            .account: self.createAccountSection,
            .card: self.createCardSection,
            .deposit: self.createDepositSection,
            .pension: self.createPensionSection,
            .fund: self.createFundSection,
            .managedPortfolio: self.createManagedPortfolioSection,
            .notManagedPortfolio: self.createNotManagedPortfolioSection,
            .stockAccount: self.createStockAccountSection,
            .loan: self.createLoanSection,
            .insuranceSaving: self.createInsuranceSavingSection,
            .insuranceProtection: self.createInsuranceProtection,
            .savingProduct: self.createSavingSection
        ]
        boxes.forEach { sectionActions[$0.asProductType]?(&cells) }
        if cells.isEmpty {
            cells.append(self.cellInfo("SmartNoProductsCollectionViewCell", cellHeight: self.heightCell, info: nil))
        }
        return cells
    }
    
    func getTopOfferCells() -> [PGCellInfo] {
        var cells = [PGCellInfo]()
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
            cells.insert(contentsOf: infoCells, at: 0)
        }
        return cells
    }
    
    func setNotification(_ num: Int?, in account: AccountEntity) -> Int? {
        if let row = self.getAccountIndex(account), self.visibleAccountList?[row].notification != num {
            self.visibleAccountList?[row].notification = num
            self.refreshFilteredAccountSection()
            return (self.getAccountIndex(account, filtered: true) ?? 0) + (self.accountsSec ?? 0)
        }
        return nil
    }
    
    func setNotification(_ num: Int?, in card: CardEntity) -> Int? {
        if let row = self.getCardIndex(card), self.cardsList?[row].notification != num {
            self.cardsList?[row].notification = num
            self.refreshFilteredCardSection()
            return (self.getCardIndex(card, filtered: true) ?? 0) + (cardsSec ?? 0)
        }
        return nil
    }
    
    func filterDidSelect(_ filter: PGInterventionFilter) -> Bool {
        if self.interventionFilterSelected != filter {
            self.interventionFilterSelected = filter
            self.refreshFilteredSections()
            return true
        }
        return false
    }
    
    func refreshUserPref(_ userPref: GetPGUseCaseOkOutput?) {
        self.gpw = userPref
        let availableName: String = {
            let alias = gpw?.userPref?.getUserAlias() ?? ""
            guard alias.isEmpty else { return alias }
            guard let name: String = gpw?.clientNameWithoutSurname, !name.isEmpty else {
                return gpw?.clientName?.camelCasedString ?? ""
            }
            return name.camelCasedString
        }()
        self.configuration?.userName = availableName
    }
    
    func removePullOffer(_ pullOffer: PullOfferCompleteInfo) {
        self.pullOffersList.removeValue(forKey: pullOffer.location.stringTag)
    }
    
    func isPregrantedOfferExpired(_ offerId: String) -> Bool {
        return self.carouselOfferBuilder?.isPregrantedOfferExpired(offerId) ?? true
    }
    
    func setLoanSimulatorLimits(limits: LoanSimulationLimitsEntity?) {
        guard let simulatorLocation = self.pullOfferCandidates.filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator }).first, let limits = limits else {
            self.isTopPG = true
            return
        }
        self.loanSimulatorViewModel = LoanSimulatorViewModel(entity: limits,
                                                             offerLocation: simulatorLocation.key,
                                                             offerEntity: simulatorLocation.value)
        self.isTopPG = self.loanSimulatorViewModel?.amountMaximum == nil
    }
    
    func setLoanBannerLimits(limits: LoanBannerLimitsEntity) {
        carouselOfferBuilder?.setPregrantedBanner(display: true)
        guard let location = self.pullOfferCandidates
            .filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator }).first
        else { return }
        self.pregrantedViewModel = PregrantedViewModel(entity: limits,
                                                       offerLocation: location.key,
                                                       offerEntity: location.value)
    }
    
}

// MARK: - OtherOperativesEvaluator
extension SmartGlobalPositionWrapper {
    func isAnalysisDisabled() -> Bool { return !(configuration?.isAnalysisAreaEmpty ?? true) }
    func isFinancingZoneDisabled() -> Bool { !(configuration?.isFinanzingZoneEnabled ?? false) }
    func isConsultPinEnabled() -> Bool { cardsList?.isEmpty ?? true}
    func isVisibleAccountsEmpty() -> Bool { visibleAccountList?.isEmpty ?? true }
    func isAllAccountsEmpty() -> Bool { allAccountList?.isEmpty ?? true }
    func isCardsMenuEmpty() -> Bool { cardsList?.isEmpty ?? true }
    func isSmartUser() -> Bool { return gpw?.userPref?.isSmartUser() ?? false }
    func isEnableMarketplace() -> Bool { return configuration?.isMarketPlaceEnabled ?? false }
    func isLocationEnabled(_ location: String) -> Bool { pullOfferCandidates.contains(location: location) }
    func isSanflixEnabled() -> Bool { return configuration?.isSanflixEnabled ?? false }
    func isPublicProductEnable() -> Bool {
        return configuration?.isPublicProductEnabled == true
    }
    func getOffer(forLocation location: String) -> PullOfferCompleteInfo? {
        guard let info = pullOfferCandidates.location(key: location) else { return nil }
        return PullOfferCompleteInfo(location: info.location, entity: info.offer)
    }
    func getFrequentOperatives() -> [PGFrequentOperativeOptionProtocol]? {
        return configuration?.frequentOperatives
    }
    func isStockholdersEnable() -> Bool {
        configuration?.enableStockholders == true
    }
    func hasTwoOrMoreAccounts() -> Bool { visibleAccountList?.count ?? 0 >= 2 }
    
    func isCarbonFootprintDisable() -> Bool {
        !(configuration?.isCarbonFootprintEnabled ?? false)
    }
}
