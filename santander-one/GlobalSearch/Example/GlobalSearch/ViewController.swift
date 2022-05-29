import UIKit
import QuickSetup
import GlobalSearch
import CoreFoundationLib
import Localization
import CoreTestData
import SANServicesLibrary
import CoreDomain
import OpenCombine

class ViewController: UIViewController {
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = GlobalSearchModuleCoordinator(dependenciesResolver: dependenciesResolver, navigationController: navigationController)
        coordinator.start(.main)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return [GlobalSearchServiceInjector()]
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        defaultResolver.register(for: SearchKeywordsRepositoryProtocol.self) { _ in
            return SearchKeywordsRepositoryMock()
        }
        return defaultResolver
    }()
    
    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: self.dependenciesResolver)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()
    
}

public final class GlobalSearchServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        injector.register(
            for: \.pullOffersConfig.getPullOffersConfig,
            filename: "pull_offers_configV4_without_cushion"
        )
    }
}

final class GlobalSearchMainModuleCoordinatorImp: GlobalSearchMainModuleCoordinatorDelegate {
    func executeDeepLink(_ deepLinkIdentifier: String) {}
    func executeDeepLink(_ deepLink: DeepLink) { }
    func didSelectAccountMovement(_ movement: AccountTransactionEntity,
                                  in transactions: [AccountTransactionWithAccountEntity],
                                  for account: AccountEntity) { }
    func didSelectCardMovement(_ movement: CardTransactionEntity,
                               in transactions: [CardTransactionWithCardEntity],
                               for card: CardEntity) { }
    func goToBills() { }
    
    func goToTransfers() {}
    
    func goToSwitchOffCard() { }
    
    func open(url: String) { }
    
    func showAlertDialog(acceptTitle: LocalizedStylableText,
                         cancelTitle: LocalizedStylableText?,
                         title: LocalizedStylableText?,
                         body: LocalizedStylableText,
                         acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        
    }
    
    func executeOffer(_ offer: OfferRepresentable) { }
    
    func didSelectDismiss() { }
    
    func didSelectMenu() { }
}

final class PfmController: PfmControllerProtocol {
    func cancelAll() {}
    
    var isFinish: Bool = false
    var monthsHistory: [MonthlyBalanceRepresentable]? = nil
    
    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        
    }
    
    func isPFMAccountReady(account: AccountEntity) -> Bool {
        return true
    }
    
    func isPFMCardReady(card: CardEntity) -> Bool {
        return true
    }
    
    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {
        
    }
}

final class PullOffersInterpreterMock: PullOffersInterpreter {
    func disableOffer(identifier: String?) {
        
    }
    
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }
    
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }
    
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return nil
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

final class SearchKeywordsRepositoryMock: SearchKeywordsRepositoryProtocol {
    func getKeywords() -> SearchKeywordListDTO? {
        return getFakeKeywords()
    }
    
    func load(baseUrl: String, publicLanguage: PublicLanguage) {
        
    }
    
    private func getFakeKeywords() -> SearchKeywordListDTO? {
        guard let data = self.loadFromFile(for: "searchKeywords") else { return nil }
        let decoder = JSONDecoder()
        do {
            let keywords = try decoder.decode(SearchKeywordListDTO.self, from: data)
            return keywords
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func loadFromFile(for path: String) -> Data? {
        do {
            guard let jsonPath = Bundle.main.path(forResource: path, ofType: ".json") else {
                return nil
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath), options: .mappedIfSafe)
            return data
        } catch {
            return nil
        }
    }
}

final class AppConfigRepositoryMock: AppConfigRepositoryProtocol {
    func value<Value>(for key: String) -> AnyPublisher<Value?, Never> where Value : LosslessStringConvertible {
        Empty().eraseToAnyPublisher()
    }
    
    func value<Value>(for key: String, defaultValue: Value) -> AnyPublisher<Value, Never> where Value : LosslessStringConvertible {
        Empty().eraseToAnyPublisher()
    }
    
    public func values<Value: LosslessStringConvertible>(for keys: [String: Value]) -> AnyPublisher<[String: Value], Never> {
        return Empty().eraseToAnyPublisher()
    }
    
    public func values<Value: LosslessStringConvertible>(for keys: [String]) -> AnyPublisher<[Value?], Never> {
        return Empty().eraseToAnyPublisher()
    }
    
    func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T : Decodable {
        return nil
    }
    
    func getInt(_ nodeName: String) -> Int? {
        return nil
    }
    
    func getAppConfigListNode(_ nodeName: String) -> [String]? {
        return nil
    }
    
    func getString(_ nodeName: String) -> String? {
        return nil
    }
    
    func getBool(_ nodeName: String) -> Bool? { return true }
    func getDecimal(_ nodeName: String) -> Decimal? {
        switch nodeName {
        case "accountEasyPayMinAmount": return 300
        case "accountEasyPayLowAmountLimit": return 2500
        default: return nil
        }
    }
}

final class FaqsRepositoryMock: FaqsRepositoryProtocol {
    
    func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        return getFakeFaqs()?.transferOperative ?? []
    }
    
    func getFaqsList() -> FaqsListDTO? {
        return getFakeFaqs()
    }
    
    private func getFakeFaqs() -> FaqsListDTO? {
        guard let data = self.loadFromFile(for: "faqs") else { return nil }
        let decoder = JSONDecoder()
        do {
            let keywords = try decoder.decode(FaqsListDTO.self, from: data)
            return keywords
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func loadFromFile(for path: String) -> Data? {
        do {
            guard let jsonPath = Bundle.main.path(forResource: path, ofType: ".json") else {
                return nil
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath), options: .mappedIfSafe)
            return data
        } catch {
            return nil
        }
    }
}

struct PullOffersConfigRepository: PullOffersConfigRepositoryProtocol {
    func getTips() -> [PullOffersConfigTipDTO]? {
        return []
    }
    
    func getSecurityTips() -> [PullOffersConfigTipDTO]? {
        return []
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
    func execute() {}
    
    func finishSession(_ reason: SessionFinishedReason?) {}
    
    
    func getAccountTopOffers() -> [CarouselOffersInfoDTO]? {
        return nil
    }
    
    func getAnalysisFinancialBudgetHelp() -> [PullOffersConfigBudgetDTO]? {
        return nil
    }
    
    func getAnalysisFinancialCushionHelp() -> [PullOffersConfigRangesDTO]? {
        return nil
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
    
    func getPGTopOffers() -> [CarouselOffersInfoDTO]? {
        return nil
    }
    
    func getFinancingCommercialOffers() -> PullOffersFinanceableCommercialOfferDTO? {
        return nil
    }
}

class PfmHelper: PfmHelperProtocol {
    func execute() {}
    
    func finishSession(_ reason: SessionFinishedReason?) {}
    
    func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity] {
        return []
    }
    
    func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity] {
        return []
    }
    
    func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity] {
        return []
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity] {
        return []
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity] {
        return []
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date?) -> [CardTransactionEntity] {
        return []
    }
    
    func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int? {
        return nil
    }
    
    func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int? {
        return nil
    }
    
    func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity {
        return .empty
    }
    
    func setReadMovements(for userId: String, account: AccountEntity) {}
    
    func setReadMovements(for userId: String, card: CardEntity) {}
    
    func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date?) -> [AccountTransactionEntity] {
        return []
    }
    
    func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        return []
    }
    
    func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity] {
        return []
    }
    
    func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity] {
        return []
    }
}
