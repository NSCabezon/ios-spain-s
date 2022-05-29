//
//  GlobalSearchPresenterTests.swift
//  GlobalSearch_ExampleTests
//
//  Created by alvola on 20/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import QuickSetup
import UI
import CoreDomain
import CoreTestData
@testable import CoreFoundationLib
@testable import GlobalSearch

final class GlobalSearchPresenterTests: XCTestCase {
    
    private var dependencies: DependenciesResolver!
    private let usecase: GlobalSearchUseCaseMock = GlobalSearchUseCaseMock()
    private var presenter: GlobalSearchPresenter!
    private let view: GlobalSearchViewProtocol = GlobalSearchViewDummy()
    
    override func setUp() {
        initDependeciesResolver()
        presenter = GlobalSearchPresenter(dependenciesResolver: dependencies)
        presenter.view = view
    }
    
    override func tearDown() {
        usecase.okResult = nil
    }
}

private extension GlobalSearchPresenterTests {
    func initDependeciesResolver() {
        let dependenciesEngine = DependenciesDefault()
        dependenciesEngine.register(for: SearchKeywordsRepositoryProtocol.self) { _ in
            return SearchKeywordsRepositoryMock()
        }
        dependenciesEngine.register(for: GlobalSearchUseCase.self) { _ in
            return self.usecase
        }
        dependenciesEngine.register(for: GetReportMovementsPhoneNumberUseCase.self) { _ in
            return GetReportMovementsPhoneNumberUseCaseMock()
        }
        dependenciesEngine.register(for: GetGlobalSearchFAQsUseCase.self) { dependenciesResolver in
            return GetGlobalSearchFAQsUseCaseMock(dependenciesResolver: dependenciesResolver)
        }
        dependenciesEngine.register(for: GetSearchKeywordsUseCase.self) { dependenciesResolver in
            return GetSearchKeywordsUseCaseMock(dependenciesResolver: dependenciesResolver)
        }
        dependenciesEngine.register(for: GlobalSearchCheckProductsUseCase.self) { dependenciesResolver in
            return GlobalSearchCheckProductsUseCaseMock()
        }
        dependenciesEngine.register(for: GlobalSearchMainModuleCoordinatorDelegate.self) { _ in
            return GlobalSearchMainModuleCoordinatorDummy()
        }
        dependenciesEngine.register(for: BaseURLProvider.self, with: { _ in
            return BaseURLProvider(baseURL: "")
        })
        dependenciesEngine.register(for: UseCaseHandler.self, with: { _ in
            return UseCaseHandler()
        })
        dependenciesEngine.register(for: TrackerManager.self, with: { _ in
            return TrackerManagerMock()
        })
        self.dependencies = dependenciesEngine
    }
    
    func emptyGlobalSearchUseCaseOkOutput() -> GlobalSearchUseCaseOkOutput{
        return GlobalSearchUseCaseOkOutput(cardsMovements: [],
                                           accountsMovements: [],
                                           faqs: [],
                                           globalFAQs: [],
                                           actionTips: [],
                                           actionTipsOffers: [:],
                                           homeTips: [],
                                           homeTipsOffers: [:],
                                           interestTips: [],
                                           interestTipsOffers: [:],
                                           baseURL: nil)
    }
}

class GlobalSearchViewDummy: GlobalSearchViewProtocol {
    func showInitialHomeTips(_ homeTips: [HelpCenterTipViewModel]) {}
    func showInitialInterestsTips(_ interestsTips: [HelpCenterTipViewModel]) { }
    func setSearchResultModel(from resultViewModels: GlobalSearchViewModel) { }
    func setReportNumber(_ number: String) { }
    func showNeedHelpForFAQs(_ viewModel: [TripFaqViewModel]) { }
    func showEmptyView(term: String, suggestedTerm: String?) { }
    func executeDeepLink(_ deepLinkIdentifier: String) {}
}

final class GlobalSearchMainModuleCoordinatorDummy: GlobalSearchMainModuleCoordinatorDelegate {
    func executeDeepLink(_ deepLinkIdentifier: String) {}
    
    func executeDeepLink(_ deepLink: DeepLink) { }
    func didSelectDismiss() { }
    func didSelectAccountMovement(_ movement: AccountTransactionEntity,
                                  in transactions: [AccountTransactionWithAccountEntity],
                                  for account: AccountEntity) { }
    func didSelectCardMovement(_ movement: CardTransactionEntity,
                               in transactions: [CardTransactionWithCardEntity],
                               for card: CardEntity) { }
    func goToBills() { }
    func goToTransfers() { }
    func goToSwitchOffCard() { }
    func open(url: String) { }
    func showAlertDialog(acceptTitle: LocalizedStylableText,
                         cancelTitle: LocalizedStylableText?,
                         title: LocalizedStylableText?,
                         body: LocalizedStylableText,
                         acceptAction: (() -> Void)?,
                         cancelAction: (() -> Void)?) { }
    func executeOffer(_ offer: OfferRepresentable) { }
}

final class GlobalSearchUseCaseMock: GlobalSearchUseCase {
    
    var okResult: GlobalSearchUseCaseOkOutput?
    
    override func executeUseCase(requestValues: GlobalSearchUseCaseInput) throws -> UseCaseResponse<GlobalSearchUseCaseOkOutput, StringErrorOutput> {
        guard let okResult = okResult else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        return UseCaseResponse.ok(okResult)
    }
}

final class GetReportMovementsPhoneNumberUseCaseMock: GetReportMovementsPhoneNumberUseCase {
    override func executeUseCase(requestValues: GetReportMovementsPhoneNumberUseCaseInput) throws -> UseCaseResponse<GetReportMovementsPhoneNumberUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetReportMovementsPhoneNumberUseCaseOkOutput(phone: nil))
    }
}

final class GetGlobalSearchFAQsUseCaseMock: GetGlobalSearchFAQsUseCase {
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetGlobalSearchFAQsUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetGlobalSearchFAQsUseCaseOkOutput(faqs: nil))
    }
}

final class GetSearchKeywordsUseCaseMock: GetSearchKeywordsUseCase {
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSearchKeywordsUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(GetSearchKeywordsUseCaseOkOutput(keywords: [],
                                                                   globalAppKeywords: [],
                                                                   operativesOnShorcutsAppKeywords: [],
                                                                   actionOnShorcutsAppKeywords: []))
    }
}

final class GlobalSearchCheckProductsUseCaseMock: GlobalSearchCheckProductsUseCase {
    override func executeUseCase(requestValues: GlobalSearchCheckProductsUseCaseInput) throws -> UseCaseResponse<GlobalSearchCheckProductsUseCaseOkOutput, StringErrorOutput> {
        return .ok(GlobalSearchCheckProductsUseCaseOkOutput(userAccounts: GlobalPositionProductList(products: []),
                                                            userCards: GlobalPositionProductList(products: [])))
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
