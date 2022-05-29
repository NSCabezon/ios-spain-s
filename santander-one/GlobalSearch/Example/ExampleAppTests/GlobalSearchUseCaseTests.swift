//
//  GlobalSearchUseCaseTests.swift
//  GlobalSearch_ExampleTests
//
//  Created by alvola on 23/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import QuickSetup
import SANLegacyLibrary
import CoreTestData
@testable import GlobalSearch

final class GlobalSearchUseCaseTests: XCTestCase {
    
    private var dependencies: DependenciesResolver!
    private var faqsRepository = FaqsRepositoryStub()
    
    override func setUp() {
        super.setUp()
        initDependeciesResolver()
    }
    
    override func tearDown() {
        super.tearDown()
        dependencies = nil
    }
    
    func test_returnsOnlyFAQMatchesFromGenericNode() {
        //Prepare
        faqsRepository.setAllNodesResults()
        let input = GlobalSearchUseCaseInput(dependenciesResolver: dependencies, substring: "test")
        
        //Test
        let useCase = dependencies.resolve(for: GlobalSearchUseCase.self)
        let response = try? useCase.executeUseCase(requestValues: input)
        guard let okResult = try? response?.getOkResult() else { return XCTFail() }
        
        //Consult
        guard faqsRepository.faqList?.generic?.count == okResult.faqs.count else { return XCTFail() }
        let sameElems = okResult.faqs.elementsEqual(faqsRepository.faqList!.generic!) {
            return $0.answer == $1.answer && $0.question == $1.question && $0.icon == $1.icon
        }
        
        XCTAssert(sameElems)
    }
}

private extension GlobalSearchUseCaseTests {
    func initDependeciesResolver() {
        let dependenciesEngine = DependenciesDefault()
        dependenciesEngine.register(for: [CustomServiceInjector].self) { _ in
            return [GlobalSearchServiceInjector()]
        }
        QuickSetupForCoreTestData().registerDependencies(in: dependenciesEngine)
        dependenciesEngine.register(for: SearchKeywordsRepositoryProtocol.self) { _ in
            return SearchKeywordsRepositoryMock()
        }
        dependenciesEngine.register(for: GlobalSearchUseCase.self) { _ in
            return GlobalSearchUseCase()
        }
        dependenciesEngine.register(for: BaseURLProvider.self) { _ in
            return BaseURLProvider(baseURL: nil)
        }
        dependenciesEngine.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = try! resolver.resolve(for: BSANManagersProvider.self).getBsanPGManager().getGlobalPosition().getResponseData()!
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: GlobalPositionEntity(isPb: false, dto: globalPosition), saveUserPreferences: false)
        }
        dependenciesEngine.register(for: PullOffersConfigRepositoryProtocol.self) { _ in
            return PullOffersConfigRepositoryDummy()
        }
        dependenciesEngine.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterDummy()
        }
        dependenciesEngine.register(for: PfmHelperProtocol.self) { _ in
            return PfmHelperProtocolDummy()
        }
        dependenciesEngine.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        dependenciesEngine.register(for: FaqsRepositoryProtocol.self) { _ in
            return self.faqsRepository
        }
        self.dependencies = dependenciesEngine
    }
}

final class PullOffersConfigRepositoryDummy: PullOffersConfigRepositoryProtocol {
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
    
    func getAccountTopOffers() -> [CarouselOffersInfoDTO]? {
        return []
    }
    
    func getAnalysisFinancialBudgetHelp() -> [PullOffersConfigBudgetDTO]? {
        return []
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

    func getFinancingCommercialOffers() -> PullOffersFinanceableCommercialOfferDTO? {
        return nil
    }
}

final class PullOffersInterpreterDummy: PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return true
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
    
    func setCandidates(locations: [String : [String]], userId: String, reload: Bool) {
        
    }
    
    func expireOffer(userId: String, offerDTO: OfferDTO) {
        
    }
    
    func removeOffer(location: String) {
        
    }
    
    func disableOffer(identifier: String?) {
        
    }
    
    func reset() {
        
    }
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}

final class PfmHelperProtocolDummy: PfmHelperProtocol {
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
        AmountEntity(value: 1.0)
    }
    
    func setReadMovements(for userId: String, account: AccountEntity) {
        
    }
    
    func setReadMovements(for userId: String, card: CardEntity) {
        
    }
    
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

final class FaqsRepositoryStub: FaqsRepositoryProtocol {
    func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        return getFaqsList()?.transferOperative ?? []
    }
    
    var faqList: FaqsListDTO?
    func getFaqsList() -> FaqsListDTO? {
        return faqList
    }
    
    func setAllNodesResults() {
        let json = """
        {
            "generic": [{
                "question": "¿test?",
                "answer": "answer",
                "icon": "icon",
                "keyWords": ["key0", "key1"]
            },
            {
                "question": "¿?",
                "answer": "test",
                "icon": "icon",
                "keyWords": ["key0", "key1"]
            }],
            "transfersHome": [{
                "question": "¿test?",
                "answer": "answer",
                "icon": "icon",
                "keyWords": ["key0", "key1"]
            },
            {
                "question": "¿?",
                "answer": "test",
                "icon": "icon",
                "keyWords": ["key0", "key1"]
            }],
            "helpCenter": [{
                "question": "¿test?",
                "answer": "answer",
                "icon": "icon",
                "keyWords": ["key0", "key1"]
            },
            {
                "question": "¿?",
                "answer": "test",
                "icon": "icon",
                "keyWords": ["key0", "key1"]
            }]
        }
        """.data(using: .utf8)!
        let dto = try? JSONDecoder().decode(FaqsListDTO.self, from: json)
        self.faqList = dto
    }
}

final class GlobalSearchServiceInjector: CustomServiceInjector {
    func inject(injector: MockDataInjector) {
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
