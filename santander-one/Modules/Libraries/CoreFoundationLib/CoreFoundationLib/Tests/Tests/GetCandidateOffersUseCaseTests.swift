//
//  GetCandidateOffersUseCaseTests.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 20/12/21.
//

import Foundation
import XCTest
import UnitTestCommons
import CoreTestData
import CoreDomain
import OpenCombine
import SANLegacyLibrary
import CoreFoundationLib

final class GetCandidateOffersUseCaseTests: XCTestCase {
    
    var dataInjector: MockDataInjector!
    var useCase: GetCandidateOfferUseCase!
    var trackerManager: TrackerManagerMock!
    var dependencies: Dependencies!
    var offersRepository: MockOffersRepository!
    var pullOffersRepository: MockPullOffersRespository!
    var globalPosition: GlobalPosition!

    override func setUpWithError() throws {
        globalPosition = GlobalPosition()
        trackerManager = TrackerManagerMock()
        dataInjector = MockDataInjector()
        offersRepository = MockOffersRepository(mockDataInjector: dataInjector)
        pullOffersRepository = MockPullOffersRespository(mockDataInjector: dataInjector)
        dependencies = Dependencies(trackerManager: trackerManager, offersRepository: offersRepository, pullOffersRepository: pullOffersRepository, globalPosition: globalPosition)
        useCase = DefaultGetCandidateOfferUseCase(dependenciesResolver: dependencies)
    }

    override func tearDownWithError() throws {
        globalPosition = nil
        offersRepository = nil
        pullOffersRepository = nil
        useCase = nil
        trackerManager = nil
        dependencies = nil
    }
    
    func test_getCandidateOfferUseCase_shouldReturnAnError_whenThereAreOffers_andTheGlobalPositionDoesntHaveUserId() throws {
        // G
        let offer = Offer(productDescription: Stub("offer_id"))
        dataInjector.register(for: \.reactivePullOffers.fetchOfferPublisher, element: CurrentValueSubject(offer.identifier).eraseToAnyPublisher())
        dataInjector.register(for: \.reactiveOffers.fetchOffersPublisher, element: Just([offer]).eraseToAnyPublisher())
        globalPosition.userId = nil
        dependencies = Dependencies(trackerManager: trackerManager, offersRepository: offersRepository, pullOffersRepository: pullOffersRepository, globalPosition: globalPosition)
        // W
        let response = try useCase.fetchCandidateOfferPublisher(location: Location.stub).sinkAwaitError()
        // T
        XCTAssert(response.localizedDescription == "no-user-id", response.localizedDescription)
    }

    func test_getCandidateOfferUseCase_shouldReturnAnError_whenThereAreNotOffersForLocation() throws {
        // G
        let error = NSError(description: "no-offer")
        dataInjector.register(for: \.reactivePullOffers.fetchOfferPublisher, element: Fail(error: error).eraseToAnyPublisher())
        // W
        let response = try useCase.fetchCandidateOfferPublisher(location: Location.stub).sinkAwaitError()
        // T
        XCTAssert(response.localizedDescription == "no-offer", response.localizedDescription)
    }
    
    func test_getCandidateOfferUseCase_shouldReturnAnOffer_whenThereAreOffersForLocation() throws {
        // G
        let offer = Offer(productDescription: Stub("offer_id"))
        dataInjector.register(for: \.reactivePullOffers.fetchOfferPublisher, element: CurrentValueSubject(offer.identifier).eraseToAnyPublisher())
        dataInjector.register(for: \.reactiveOffers.fetchOffersPublisher, element: Just([offer]).eraseToAnyPublisher())
        // W
        let response = try useCase.fetchCandidateOfferPublisher(location: Location.stub).sinkAwait()
        // T
        XCTAssert(response.productDescription == "offer_id")
    }
    
    func test_getCandidateOfferUseCase_shouldReturnAnError_whenTheOfferIsDisabledForThisSession() throws {
        // G
        let offer = Offer(productDescription: Stub("offer_id"))
        dataInjector.register(for: \.reactivePullOffers.fetchOfferPublisher, element: CurrentValueSubject(offer.identifier).eraseToAnyPublisher())
        dataInjector.register(for: \.reactiveOffers.fetchOffersPublisher, element: Just([offer]).eraseToAnyPublisher())
        dataInjector.register(for: \.reactivePullOffers.fetchSessionDisabledOffers, element: Just([offer.identifier]).eraseToAnyPublisher())
        // W
        let response = try useCase.fetchCandidateOfferPublisher(location: Location.stub).sinkAwaitError()
        // T
        XCTAssert(response.localizedDescription == "no-offer", response.localizedDescription)
    }
    
    func test_getCandidateOfferUseCase_shouldSaveTheLocationAsVisited_whenThereAreOffersForLocation() throws {
        // G
        let offer = Offer(productDescription: Stub("offer_id"))
        let pullOffersRepository = MockSpyablePullOffersRepository(mockDataInjector: dataInjector)
        dependencies = Dependencies(trackerManager: trackerManager, offersRepository: offersRepository, pullOffersRepository: pullOffersRepository, globalPosition: globalPosition)
        useCase = DefaultGetCandidateOfferUseCase(dependenciesResolver: dependencies)
        dataInjector.register(for: \.reactivePullOffers.fetchOfferPublisher, element: CurrentValueSubject(offer.identifier).eraseToAnyPublisher())
        dataInjector.register(for: \.reactiveOffers.fetchOffersPublisher, element: Just([offer]).eraseToAnyPublisher())
        // W
        _ = try useCase.fetchCandidateOfferPublisher(location: Location(stringTag: Stub("PG_TOP"), pageForMetrics: Stub("GlobalPosition"))).sinkAwait()
        // T
        XCTAssert(pullOffersRepository.spyVisitLocation == "PG_TOP")
    }
    
    func test_getCandidateOfferUseCase_shouldTrackEventOfLocationVisited_whenThereAreOffersForLocation() throws {
        // G
        let offer = Offer(identifier: Stub("1001"))
        dataInjector.register(for: \.reactivePullOffers.fetchOfferPublisher, element: CurrentValueSubject(offer.identifier).eraseToAnyPublisher())
        dataInjector.register(for: \.reactiveOffers.fetchOffersPublisher, element: Just([offer]).eraseToAnyPublisher())
        // W
        _ = try useCase.fetchCandidateOfferPublisher(location: Location(stringTag: Stub("PG_TOP"), pageForMetrics: Stub("GlobalPosition"))).sinkAwait()
        // T
        XCTAssert(trackerManager.spyTrackEvent?.screenId == "GlobalPosition")
        XCTAssert(trackerManager.spyTrackEvent?.eventId == "oferta_visualizacion")
        XCTAssert(trackerManager.spyTrackEvent?.extraParameters["location"] == "PG_TOP")
        XCTAssert(trackerManager.spyTrackEvent?.extraParameters["offerId"] == "1001")
    }
}

extension GetCandidateOffersUseCaseTests {
    struct Dependencies: OffersDependenciesResolver {
        let coreDependencies = DefaultCoreDependencies()
        let trackerManager: TrackerManager
        let offersRepository: ReactiveOffersRepository
        let pullOffersRepository: ReactivePullOffersRepository
        let globalPosition: GlobalPosition
        
        func resolve() -> ReactivePullOffersRepository {
            return pullOffersRepository
        }
        
        func resolve() -> ReactiveOffersRepository {
            return offersRepository
        }
        
        func resolve() -> CoreDependencies {
            return coreDependencies
        }
        
        func resolve() -> TrackerManager {
            return trackerManager
        }
        
        func resolve() -> GlobalPositionDataRepository {
            return MockGlobalPositionRepository(globalPosition: globalPosition)
        }
        
        func resolve() -> PullOffersConfigRepositoryProtocol {
            fatalError()
        }
        
        func resolve() -> PullOffersInterpreter {
            fatalError()
        }
        
        func resolve() -> EngineInterface {
            fatalError()
        }
    }
}

private struct MockGlobalPositionRepository: GlobalPositionDataRepository {
    let globalPosition: GlobalPositionDataRepresentable
    
    func getMergedGlobalPosition() -> AnyPublisher<GlobalPositionAndUserPrefMergedRepresentable, Never> {
        fatalError()
    }
    
    func getGlobalPosition() -> AnyPublisher<GlobalPositionDataRepresentable, Never> {
        return Just(globalPosition).eraseToAnyPublisher()
    }
    
    func send(_ isPb: Bool) { }
    
    func getIsPb() -> AnyPublisher<Bool, Never> {
        return Just(true).eraseToAnyPublisher()
    }
}

class GlobalPosition: GlobalPositionDataRepresentable {
    var userId: String? = "123456"
    @Stub var accountRepresentables: [AccountRepresentable]
    @Stub var stockAccountRepresentables: [StockAccountRepresentable]
    @Stub var cardRepresentables: [CardRepresentable]
    @Stub var depositRepresentables: [DepositRepresentable]
    @Stub var fundRepresentables: [FundRepresentable]
    @Stub var managedPortfoliosRepresentables: [PortfolioRepresentable]
    @Stub var notManagedPortfoliosRepresentables: [PortfolioRepresentable]
    @Stub var managedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable]
    @Stub var notManagedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable]
    @Stub var pensionRepresentables: [PensionRepresentable]
    @Stub var savingsInsuranceRepresentables: [InsuranceRepresentable]
    @Stub var protectionInsuranceRepresentables: [InsuranceRepresentable]
    @Stub var savingProductRepresentables: [SavingProductRepresentable]
    @Stub var userDataRepresentable: UserDataRepresentable?
    @Stub var isPb: Bool?
    @Stub var clientNameWithoutSurname: String?
    @Stub var clientName: String?
    @Stub var clientFirstSurnameRepresentable: String?
    @Stub var clientSecondSurnameRepresentable: String?
    @Stub var loanRepresentables: [LoanRepresentable]
}

struct Location: PullOfferLocationRepresentable, StubConvertible {
    @Stub var stringTag: String
    @Stub var hasBanner: Bool
    @Stub var pageForMetrics: String?
    
    static var stub: Location {
        return Location()
    }
}

struct Offer: OfferRepresentable, StubConvertible {
    @Stub var rulesIds: [String]
    @Stub var startDateUTC: Date?
    @Stub var endDateUTC: Date?
    @Stub var pullOfferLocation: PullOfferLocationRepresentable?
    @Stub var bannerRepresentable: BannerRepresentable?
    @Stub var action: OfferActionRepresentable?
    @Stub var id: String?
    @Stub var identifier: String
    @Stub var transparentClosure: Bool
    @Stub var productDescription: String
    
    static var stub: Offer {
        return Offer()
    }
}

final class MockSpyablePullOffersRepository: MockPullOffersRespository {
    
    var spyVisitLocation: String?
    
    override func visitLocation(_ location: String) {
        self.spyVisitLocation = location
    }
}

final public class TrackerManagerMock: TrackerManager {
    
    var spyTrackEvent: (screenId: String, eventId: String, extraParameters: [String : String])? = nil
    
    public func trackScreen(screenId: String, extraParameters: [String : String]) {
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String : String]) {
        spyTrackEvent = (screenId: screenId, eventId: eventId, extraParameters: extraParameters)
    }
    
    public func trackEmma(token: String) {
    }
}
