//
//  GlobalSearchSpyViewPresenterTests.swift
//  GlobalSearch_ExampleTests
//
//  Created by alvola on 23/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import UI
import CoreTestData
@testable import CoreFoundationLib
@testable import GlobalSearch

final class GlobalSearchSpyViewPresenterTests: XCTestCase {
    
    private var dependencies: DependenciesResolver!
    
    private let usecase: GlobalSearchUseCaseMock = GlobalSearchUseCaseMock()
    private var presenter: GlobalSearchPresenter!
    private var view = GlobalSearchViewSpy()
    
    override func setUp() {
        initDependeciesResolver()
        presenter = GlobalSearchPresenter(dependenciesResolver: dependencies)
        presenter.view = view
    }
    
    override func tearDown() {
        usecase.okResult = nil
        view.viewModel = nil
        view.showEmptyViewCalled = false
    }
    
    func test_whenUseCaseReturns2FAQs_ThenTheViewReceives2FAQs() {
        //Prepare
        let json = """
            {
             "question": "¿?",
            "answer": "answer",
            "icon": "icon",
            "keyWords": ["key0", "key1"]
            }
            """.data(using: .utf8)!
        let dto = try? JSONDecoder().decode(FaqDTO.self, from: json)
        usecase.okResult = GlobalSearchUseCaseOkOutput(cardsMovements: [],
                                                       accountsMovements: [],
                                                       faqs: [FaqsEntity(dto!),
                                                              FaqsEntity(dto!)],
                                                       globalFAQs: [],
                                                       actionTips: [],
                                                       actionTipsOffers: [:],
                                                       homeTips: [],
                                                       homeTipsOffers: [:],
                                                       interestTips: [],
                                                       interestTipsOffers: [:],
                                                       baseURL: nil)
        let predicate = NSPredicate { (view: Any?, _) in
            guard let view = view as? GlobalSearchViewSpy else { return false }
            return view.viewModel?.help.count == 2
        }
        
        //Test
        _ = self.expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter.textFieldDidSet(text: "test")
        
        //Consult
        waitForExpectations(timeout: 2.0, handler: .none)
    }
    
    func test_whenUseCaseReturnsSomething_ThenShowEmptyViewIsNotCalled() {
        //Prepare
        let json = """
            {
             "question": "¿?",
            "answer": "answer",
            "icon": "icon",
            "keyWords": ["key0", "key1"]
            }
            """.data(using: .utf8)!
        let dto = try? JSONDecoder().decode(FaqDTO.self, from: json)
        usecase.okResult = GlobalSearchUseCaseOkOutput(cardsMovements: [],
                                                       accountsMovements: [],
                                                       faqs: [FaqsEntity(dto!)],
                                                       globalFAQs: [],
                                                       actionTips: [],
                                                       actionTipsOffers: [:],
                                                       homeTips: [],
                                                       homeTipsOffers: [:],
                                                       interestTips: [],
                                                       interestTipsOffers: [:],
                                                       baseURL: nil)
        let predicate = NSPredicate { (view: Any?, _) in
            guard let view = view as? GlobalSearchViewSpy else { return false }
            return view.showEmptyViewCalled == false
        }
        
        //Test
        _ = self.expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter.textFieldDidSet(text: "test")
        
        //Consult
        waitForExpectations(timeout: 2.0, handler: .none)
    }
    
    func test_whenUseCaseReturnsNothing_ThenShowEmptyViewIsCalled() {
        //Prepare
        usecase.okResult = emptyGlobalSearchUseCaseOkOutput()
        let predicate = NSPredicate { (view: Any?, _) in
            guard let view = view as? GlobalSearchViewSpy else { return false }
            return view.showEmptyViewCalled == true
        }
        
        //Test
        _ = self.expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter.textFieldDidSet(text: "test")
        
        //Consult
        waitForExpectations(timeout: 2.0, handler: .none)
    }
    
    func test_whenUseCaseReturns1Action_ThenTheViewReceives1Action() {
        //Prepare
        let json = """
            {
             "title": "title"
            }
            """.data(using: .utf8)!
        let dto = try? JSONDecoder().decode(PullOffersConfigTipDTO.self, from: json)
        let entity = PullOfferTipEntity(dto!, offer: OfferDTO(product: OfferProductDTO(identifier: "",
                                                                                      neverExpires: false,
                                                                                      transparentClosure: nil,
                                                                                      description: nil,
                                                                                      rulesIds: [],
                                                                                      iterations: 0,
                                                                                      banners: [],
                                                                                      bannersContract: [],
                                                                                      action: nil,
                                                                                      startDateUTC: nil,
                                                                                      endDateUTC: nil)))
        usecase.okResult = GlobalSearchUseCaseOkOutput(cardsMovements: [],
                                                       accountsMovements: [],
                                                       faqs: [],
                                                       globalFAQs: [],
                                                       actionTips: [entity],
                                                       actionTipsOffers: [:],
                                                       homeTips: [],
                                                       homeTipsOffers: [:],
                                                       interestTips: [],
                                                       interestTipsOffers: [:],
                                                       baseURL: nil)
        let predicate = NSPredicate { (view: Any?, _) in
            guard let view = view as? GlobalSearchViewSpy else { return false }
            return view.viewModel?.actions.count == 1
        }
        
        //Test
        _ = self.expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter.textFieldDidSet(text: "test")
        
        //Consult
        waitForExpectations(timeout: 2.0, handler: .none)
    }
}

private extension GlobalSearchSpyViewPresenterTests {
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
        DefaultDependenciesInitializer(dependencies: dependenciesEngine).registerDefaultDependencies()
        dependenciesEngine.register(for: SearchKeywordsRepositoryProtocol.self) { _ in
            return SearchKeywordsRepositoryMock()
        }
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

final class GlobalSearchViewSpy: GlobalSearchViewDummy {
    var viewModel: GlobalSearchViewModel?
    var showEmptyViewCalled: Bool = false
    
    override func setSearchResultModel(from resultViewModels: GlobalSearchViewModel) {
        viewModel = resultViewModels
    }

    override func showEmptyView(term: String, suggestedTerm: String?) {
        showEmptyViewCalled = true
    }
}
