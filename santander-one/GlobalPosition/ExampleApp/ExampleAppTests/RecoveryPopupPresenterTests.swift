
//  RecoveryPopupPresenterTests.swift
//  ExampleAppTests
//
//  Created by César González Palomino on 11/11/2020.
//  Copyright © 2020 Jose Carlos Estela Anguita. All rights reserved.


import XCTest
import QuickSetup
import UnitTestCommons
import SANLegacyLibrary
import CoreTestData
import UI
@testable import CoreFoundationLib

final class RecoveryPopupviewMock: RecoveryPopupProtocol {
    var viewModel: RecoveryViewModel?
    func setRecoveryViewModel(_ viewModel: RecoveryViewModel) {
        self.viewModel = viewModel
    }

    func reset() {
        viewModel = nil
    }
}

final class GetRecoveryLevelUseCaseMock: GetRecoveryLevelUseCase {
    private var okOutput: GetRecoveryLevelUseCaseOutput?

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRecoveryLevelUseCaseOutput, StringErrorOutput> {
        guard let output = okOutput else { return .error(StringErrorOutput("errorDescription"))}
        return .ok(output)
    }

    func updateOutput(debtCount: Int = 1, debtTitle: String = "", amount: Double, level: Int = 3) {
        self.okOutput = GetRecoveryLevelUseCaseOutput(debtCount: debtCount,
                                                      debtTitle: debtTitle,
                                                      amount: amount,
                                                      level: level)
    }
}

class RecoveryPopupPresenterTests: XCTestCase {

    private let resolver: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private let view: RecoveryPopupviewMock = RecoveryPopupviewMock()
    private let mockDataInjector = MockDataInjector()
    private var sut: RecoveryPopupPresenterProtocol!
    private let usecaseHandler: UseCaseHandler = UseCaseHandler()
    private var useCaseMock: GetRecoveryLevelUseCaseMock!

    override func setUp() {
        registerDependencies()
        sut = RecoveryPopupPresenter(dependenciesResolver: resolver)
        useCaseMock = GetRecoveryLevelUseCaseMock(dependenciesResolver: resolver)
        sut.view = view
    }
    
    func test_Recovery_shouldSetCorrectAmountFormat() {
        //mock use case
        useCaseMock?.updateOutput(amount: 234.06)
        let exp = self.expectation(description: "test")

        sut.shouldShow { show in
            self.sut.viewDidLoad()
            guard let viewModel = self.view.viewModel else { XCTFail(); return }
            let correctAmountString = "−234,06€"
            XCTAssert(viewModel.amount == correctAmountString, "\(viewModel.amount) is not equal to:  \(viewModel.amount)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: .none)
    }


    func test_Recovery_shouldSetCorrectAmountFormat1() {
        //mock use case
        useCaseMock?.updateOutput(amount: 1234.06)
        let exp = self.expectation(description: "test")

        sut.shouldShow { show in
            self.sut.viewDidLoad()
            guard let viewModel = self.view.viewModel else { XCTFail(); return }
            let correctAmountString = "−1.234,06€"
            XCTAssert(viewModel.amount == correctAmountString, "\(viewModel.amount) is not equal to:  \(viewModel.amount)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: .none)
    }

    func test_Recovery_shouldSetCorrectAmountFormat2() {
        //mock use case
        useCaseMock?.updateOutput(amount: 12034.06)
        let exp = self.expectation(description: "test")

        sut.shouldShow { show in
            self.sut.viewDidLoad()
            guard let viewModel = self.view.viewModel else { XCTFail(); return }
            let correctAmountString = "−12.034,06€"
            XCTAssert(viewModel.amount == correctAmountString, "\(viewModel.amount) is not equal to:  \(viewModel.amount)")
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: .none)
    }
}

extension RecoveryPopupPresenterTests {
    func registerDependencies() {

        resolver.register(for: RecoveryPopupProtocol.self, with: { _ in
            return self.view
        })
        resolver.register(for: UseCaseHandler.self, with: { _ in
            return self.usecaseHandler
        })
        
        resolver.register(for: AppConfigRepositoryProtocol.self) { resolver in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        
        resolver.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }

        resolver.register(for: GetPullOffersUseCase.self, with: { res in
            return GetPullOffersUseCase.init(dependenciesResolver: res)
        })
        
        resolver.register(for: GlobalPositionRepresentable.self) { _ in
            self.mockDataInjector.register(
                for: \.gpData.getGlobalPositionMock,
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
        
        resolver.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        
        resolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver,
                                                         globalPosition: globalPosition,
                                                         saveUserPreferences: true)
            return merger
        }

        resolver.register(for: GetRecoveryLevelUseCase.self) { res in
            if self.useCaseMock == nil {
                self.useCaseMock =  GetRecoveryLevelUseCaseMock(dependenciesResolver: res)
            }

            return self.useCaseMock
        }
        resolver.register(for: TrackerManager.self) { res in
            return TrackerManagerMock()
        }
    }
}

class PullOffersInterpreterMock: PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }

    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }

    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return OfferDTO.init(product: OfferProductDTO(identifier: "",
                                                      neverExpires: false,
                                                      transparentClosure: nil,
                                                      description: nil,
                                                      rulesIds: [],
                                                      iterations: 0,
                                                      banners: [],
                                                      bannersContract: [],
                                                      action: nil,
                                                      startDateUTC: nil,
                                                      endDateUTC: nil))
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

    func disableOffer(identifier: String?) {
    }

    func reset() {

    }

    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}
