//
//  TestSKFirstStepViewModel.swift
//  ExampleAppTests
//
//  Created by Ali Ghanbari Dolatshahi on 15/2/22.
//

import XCTest
import CoreDomain
import CoreFoundationLib
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import SantanderKey

class TestSKFirstStepViewModel: XCTestCase {
    
    lazy var dependencies: SKFirstStepOnboardingDependenciesResolverMock = {
        let external = SKFirstStepOnboardingExternalDependenciesResolverMock()
        return SKFirstStepOnboardingDependenciesResolverMock(injector: self.mockDataInjector, externalDependencies: external)
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        return injector
    }()
    
    func test_When_didTapOnVideo_Expect_GoToPublicOfferIsCalledInCoordinator() throws {
        let sut = SKFirstStepOnboardingViewModel(dependencies: dependencies)
        let trigger = {
            sut.didTapVideo()
        }
        let isFirstCallLoading = try sut.state
            .case { OnboardingState.isFirstCallLoading }
            .sinkAwait(beforeWait: trigger)
        let externalDependencies = self.dependencies.external as! SKFirstStepOnboardingExternalDependenciesResolverMock
        XCTAssertTrue(externalDependencies.getCandidateOfferUseCase.fetchCandidateOfferPublisherCalled)
        XCTAssertTrue(isFirstCallLoading)
    }
    
    func test_When_didTapOnContinue_Expect_GoToSecondStepIsCalledInCoordinator() throws {
        let sut = SKFirstStepOnboardingViewModel(dependencies: dependencies)
        sut.didTapContinueButton()
        XCTAssertTrue(self.dependencies.coordinator.goToSecondStepCalled)
    }
}

class GetCandidateOfferUseCaseSpy: GetCandidateOfferUseCase {
    var fetchCandidateOfferPublisherCalled: Bool = false
    
    func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        fetchCandidateOfferPublisherCalled = true
        let offer = OfferRepresentableMock(id: "", transparentClosure: true, productDescription: "", rulesIds: [""])
        return Just(offer).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    struct OfferRepresentableMock: OfferRepresentable {
        var pullOfferLocation: PullOfferLocationRepresentable?
        var bannerRepresentable: BannerRepresentable?
        var action: OfferActionRepresentable?
        var id: String?
        var identifier: String
        var transparentClosure: Bool
        var productDescription: String
        var rulesIds: [String]
        var startDateUTC: Date?
        var endDateUTC: Date?
        
        init(id: String, transparentClosure: Bool, productDescription: String, rulesIds: [String]) {
            self.identifier = id
            self.transparentClosure = transparentClosure
            self.productDescription = productDescription
            self.rulesIds = rulesIds
        }
    }
}
