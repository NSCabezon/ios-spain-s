//
//  ViewController.swift
//  ExampleApp
//
//  Created by Jose Carlos Estela Anguita on 24/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreFoundationLib
import SANLegacyLibrary
import GlobalPosition
import CoreTestData
import Localization
import CoreDomain
import QuickSetup
import UIKit
import CoreDomain

class MockPullOffersConfigRepository: PullOffersConfigRepositoryProtocol {
    func getFinancingCommercialOffers() -> PullOffersFinanceableCommercialOfferDTO? {
        return nil
    }
    
    func getTips() -> [PullOffersConfigTipDTO]? {
        return nil
    }
    
    func getSecurityTips() -> [PullOffersConfigTipDTO]? {
        return nil
    }
    
    func getSecurityTravelTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getHelpCenterTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getAtmTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getActivateCreditCardTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getActivateDebitCardTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getCardBoardingWelcomeCreditCardTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getCardBoardingWelcomeDebitCardTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getSantanderExperiences() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getCardBoardingAlmostDoneCreditTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getCardBoardingAlmostDoneDebitTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getAccountTopOffers() -> [CarouselOffersInfoDTO]? {
        return nil
    }
    
    func getAnalysisFinancialBudgetHelp() -> [PullOffersConfigBudgetDTO]? {
        return nil
    }
    
    func getAnalysisFinancialCushionHelp() -> [PullOffersConfigRangesDTO]? {
        return nil
    }
    
    func getPGTopOffers() -> [CarouselOffersInfoDTO]? {
        return []
    }
    
    func getPublicCarouselOffers() -> [PullOffersConfigTipDTO] {
        return []
    }

    func getActionTipsOffers() -> [PullOffersConfigTipDTO]? {
        return nil
    }

    func getHomeTipsOffers() -> [PullOfferHomeTipDTO]? {
        return nil
    }

    func getLocations() -> [String : [String]]? {
        return nil
    }

    func getBookmarkOffers() -> [PullOffersConfigBookmarkDTO] {
        return []
    }

    func getHomeTips() -> [PullOffersHomeTipsDTO]? {
        return nil
    }

    func getInterestTipsOffers() -> [PullOffersConfigTipDTO]? {
        return nil
    }
}

class MockAccountDescriptorRepository: AccountDescriptorRepositoryProtocol {
    func getAccountDescriptor() -> AccountDescriptorArrayDTO? {
        return nil
    }
}

class GlobalPositionModuleCoordinatorDelegateImpl: GlobalPositionModuleCoordinatorDelegate {
    func openAppStore() {
        
    }
    
    func goToWebView(configuration: WebViewConfiguration) {
        
    }
    
    func didSelectMBWay() {
        
    }
    
    func didSelectSendMoneyPortugal() {
        
    }
    
    func didSelectBillTaxPortugal() {
        
    }
    
    func didSelectOperatePortugal() {
        
    }
    
    func didSelectConsultPin() { }

    func didTapInHistoricSendMoney() {}

    func openAppStore(appId: Int) { }

    func didSelectFutureBill(_ bill: AccountFutureBillRepresentable, in bills: [AccountFutureBillRepresentable], for entity: AccountEntity) { }

    func gotoCardTransactionDetail(transactionEntity: CardTransactionEntity,
                                   in transactionList: [CardTransactionWithCardEntity],
                                   cardEntity: CardEntity) { }

    func gotoAccountTransactionDetail(transactionEntity: AccountTransactionEntity, in transactionList: [AccountTransactionWithAccountEntity], accountEntity: AccountEntity) { }

    func didSelectFavouriteContact(_ contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) { }
    func didSelectOffer(_ offer: OfferRepresentable?) { }
    func didSelectFinancing() { }
    func didSelectAction(_ action: Any, _ entity: AllOperatives, _ offers: [PullOfferLocation: OfferEntity]?) { }
    func globalPositionDidDisappear() { }
    func didSelectConfigureGP() { }
    func didSelectConfigureGPProducts() {}
    func goToNewShipment() { }
    func globalPositionDidReload() {}
    func didSelectAnalysisArea() { }
    func didSelectAction(_ action: Any, _ entity: AllOperatives, _ locations: [PullOfferLocation]) {}
    func didSelectTimeLine() {}
    func globalPositionDidAppear() { }
    func didSelectBizum() {}
    func didActivateCard(_ card: Any?) { }
    func didTurnOnCard(_ card: Any?) { }
    func didSelectImpruve() {}
    func didSelectTips() { }
    func didSelectStockholders() { }
    func didSelectCustomerService() { }
    func didSelectManager() {}
    func didSelectPersonalArea() { }
    func didSelectMarketplace() { }
    func didSelectATM() { }
    func didSelectMoreOptions() { }
    func didSelectBox(isCollapsed: Bool, id: String) {}
    func didSelectDeposit(deposit: DepositEntity) {}
    func addFavourite() { }
    func didSelectBudgetLimit() { }
    func didSelectBalance() { }
    func goToTransfers() { }
    func globalPositionDidLoad() { }
    func cancelAll() {}
    func didSelectOperate() { }
    func didSelectContract() { }
    func didSelectReceipt() { }
    func didSelectSendMoney() { }
    func didSelectSearch() { }
    func didSelectMail() { }
    func didSelectAccount(account: AccountEntity) {}
    func didSelectAccountMovement(movement: AccountTransactionEntity, in account: AccountEntity) {}
    func didSelectCard(card: CardEntity) {}
    func didSelectFund(fund: FundEntity) {}
    func didSelectInsuranceSaving(insurance: InsuranceSavingEntity) {}
    func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity) {}
    func execute() {}
    func finishSession(_ reason: SessionFinishedReason?) {}
    func didSelectLoan(loan: LoanEntity) {}
    func didSelectPension(pension: PensionEntity) {}
    func didSelectPortfolio(portfolio: PortfolioEntity) {}
    func didSelectManagedPortfolio(portfolio: PortfolioEntity) {}
    func didSelectNotManagedPortfolio(portfolio: PortfolioEntity) {}
    func didSelectStockAccount(stockAccount: StockAccountEntity) {}
    func didSelectSavingProduct(savingProduct: SavingProductEntity) {}
    func didSelectOffer(offer: OfferEntity, in location: PullOfferLocation) {}
    func didSelectMenu() {}
    func didSelectInCarbonFootprint() { }
}

class PfmController: PfmControllerProtocol {
    var isFinish: Bool = false
    var monthsHistory: [MonthlyBalanceRepresentable]? = nil

    
    func cancelAll() {
    }
    func finishedPFM(months: [MonthlyBalanceRepresentable]) {
    }

    func isPFMCardReady(card: CardEntity) -> Bool {
        return true
    }

    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {}

    func isPFMAccountReady(account: AccountEntity) -> Bool {
        return true
    }

    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            subscriber.finishedPFM(months: [])
        }
    }
}

class PfmHelperController: PfmHelperProtocol {
    func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date?) -> [AccountTransactionEntity] {
        return []
    }
                            
    func execute() {}
    
    func finishSession(_ reason: SessionFinishedReason?) {}
    
    func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        return []
    }

    func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date?) -> [CardTransactionEntity] {
        return []
    }

    func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity] {
        return []
    }

    func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity] {
        return []
    }

    func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity] {
        return []
    }

    func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity] {
        return []
    }

    func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity] {
        return []
    }

    func getLastMovementsFor(userId: String, card: CardEntity, searchText: String) -> [CardTransactionEntity] {
        return []
    }

    func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String) -> [AccountTransactionEntity] {
        return []
    }

    func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity] {
        return []
    }

    func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity] {
        return []
    }

    func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int? {
        return nil
    }

    func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int? {
        return nil
    }

    func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity {
        return AmountEntity(value: 0)
    }

    func setReadMovements(for userId: String, account: AccountEntity) {
    }

    func setReadMovements(for userId: String, card: CardEntity) {
    }
}

struct EmmaTrackEventList: EmmaTrackEventListProtocol {
    var globalPositionEventID: String
    var accountsEventID: String
    var cardsEventID: String
    var transfersEventID: String
    var billAndTaxesEventID: String
    var personalAreaEventID: String
    var managerEventID: String
    var customerServiceEventID: String
}

class LocalResponse<ResponseType>: RepositoryResponse<ResponseType> {
    override func getResponseData() throws -> ResponseType? {
        return nil
    }
}

class PullOffersInterpreterMock: PullOffersInterpreter {
    func disableOffer(identifier id: String?) {
    }

    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }

    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }

    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return OfferDTO(product: OfferProductDTO(identifier: "", neverExpires: false, transparentClosure: false, description: nil, rulesIds: [], iterations: 10000, banners: [], bannersContract: [], action: nil, startDateUTC: nil, endDateUTC: nil))
    }

    func getValidOffer(offerId: String) -> OfferDTO? {
        return nil
    }

    func getOffer(offerId: String) -> OfferDTO? {
        return nil
    }

    func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {

    }

    func expireOffer(userId: String, offerDTO: OfferDTO) {

    }

    func removeOffer(location: String) {

    }

    func reset() {

    }

    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}

class DeepLinkManagerProtocolFake: DeepLinkManagerProtocol {
    func registerDeepLink(_ deeplink: DeepLinkEnumerationCapable) {}
    
    func getScheduledDeepLinkTracker() -> String? {
        return nil
    }
    
    func isDeepLinkScheduled() -> Bool {
        return true
    }
}

class ViewController: UIViewController {
    private lazy var servicesProvider: QuickSetupForCoreTestData = {
        return QuickSetupForCoreTestData()
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: self.dependenciesResolver)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()

    private var mockDataInjector = MockDataInjector()
    private var loadingTipsRepository: LoadingTipsRepositoryProtocol!

    private lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        defaultResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        defaultResolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        defaultResolver.register(for: PfmControllerProtocol.self) { _ in
            return PfmController()
        }
        defaultResolver.register(for: PfmHelperProtocol.self) { _ in
            return PfmHelperController()
        }
        defaultResolver.register(for: BaseURLProvider.self) { _ in
            return BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
        }
        
        defaultResolver.register(for: LoadingTipsRepositoryProtocol.self) { _ in
            return self.loadingTipsRepository
        }
        defaultResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        defaultResolver.register(for: AppInfoRepositoryProtocol.self) { _ in
            return AppInfoRepositoryMock()
        }

        defaultResolver.register(for: AccountDescriptorRepositoryProtocol.self) { _ in
            return MockAccountDescriptorRepository()
        }
        defaultResolver.register(for: PullOffersConfigRepositoryProtocol.self) { _ in
            return MockPullOffersConfigRepository()
        }
        defaultResolver.register(for: GlobalPositionRepresentable.self) { _ in
            self.mockDataInjector.register(
                for: \.accountData.getAccountDetailMock,
                filename: "obtenerPosGlobal"
            )
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        defaultResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        defaultResolver.register(for: TimeManager.self) { _ in
            return self.localeManager
        }
        defaultResolver.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        defaultResolver.register(for: GlobalPositionConfiguration.self) { _ in
            return GlobalPositionConfiguration(isInsuranceBalanceEnabled: false, isCounterValueEnabled: false)
        }
        defaultResolver.register(for: [AccountDescriptorEntity].self) { _ in
            return []
        }
        defaultResolver.register(for: GlobalPositionModuleCoordinatorDelegate.self) { _ in
            return GlobalPositionModuleCoordinatorDelegateImpl()
        }
        defaultResolver.register(for: GlobalPositionReloadEngine.self) { _ in
            return self.globalPositionEngine
        }

        defaultResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }

        defaultResolver.register(for: EmmaTrackEventListProtocol.self) { _ in
            return EmmaTrackEventList(globalPositionEventID: "", accountsEventID: "", cardsEventID: "", transfersEventID: "", billAndTaxesEventID: "", personalAreaEventID: "", managerEventID: "", customerServiceEventID: "")
        }
        defaultResolver.register(for: DeepLinkManagerProtocol.self) { _  in
            return DeepLinkManagerProtocolFake()
        }
        defaultResolver.register(for: GetLoadingTipsUseCase.self) { resolver in
            return GetLoadingTipsUseCase(dependenciesResolver: resolver)
        }
        defaultResolver.register(for: DepositModifier.self) { resolver in
            return DepositModifier(dependenciesResolver: resolver)
        }
        defaultResolver.register(for: FundModifier.self) { resolver in
            return FundModifier(dependenciesResolver: resolver)
        }
        defaultResolver.register(for: LocalAppConfig.self) { resolver in
            return LocalAppConfigMock()
        }
        defaultResolver.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return GetLanguagesSelectionUseCaseMock()
        }
        Localized.shared.setup(dependenciesResolver: defaultResolver)
        return defaultResolver
    }()

    private lazy var globalPositionEngine: GlobalPositionReloadEngine = {
        return GlobalPositionReloadEngine()
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
