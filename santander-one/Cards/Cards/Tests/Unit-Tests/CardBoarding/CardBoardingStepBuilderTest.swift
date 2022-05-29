//
//  CardBoardingStepBuilderTest.swift
//  Cards_ExampleTests
//
//  Created by Juan Carlos López Robles on 10/26/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class CardBoardingStepBuilderTest: XCTestCase {
    var mockDataInjector = MockDataInjector()
    var dependenciesResolver = DependenciesDefault()
    var cardsServiceInjector = CardsServiceInjector()
    
    lazy var cardEntity: CardEntity = {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        return globalPosition.cards.first!
    }()
    
    override func setUp() {
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setDependencies()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }
    
    func test_build_default_steps() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.cardEntity)
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        XCTAssertEqual(stepBuilder.build().count, 2)
    }
    
    func test_add_summary_step() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.cardEntity)
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let step = stepBuilder.build().last
        XCTAssert(step?.view is CardBoardingSummaryViewProtocol)
    }
    
    func test_add_almost_done_step() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.cardEntity)
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        var steps = stepBuilder.build()
        _ = steps.popLast()
        let step = steps.last
        XCTAssert(step?.view is AlmostDoneViewProtocol)
    }
    
    func test_mark_as_first_Step() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.cardEntity)
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let step = stepBuilder.build().first
        XCTAssertEqual(step?.view?.isFirstStep, true)
    }
    
    func test_add_applePay_step() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            let configuration = CardboardingConfiguration(card: self.cardEntity)
            configuration.allowSteps = [.inApp]
            configuration.applePayState = .inactive
            return configuration
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let step = stepBuilder.build().first
        XCTAssert(step?.view is ApplePayEnrollmentViewProtocol)
    }
    
    func test_add_applePay_step_with_invalid_applePayState() {
        let applePayStates: [CardApplePayState] = [.active, .inactiveAndDisabled, .notSupported]
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            let configuration = CardboardingConfiguration(card: self.cardEntity)
            configuration.allowSteps = [.inApp]
            configuration.applePayState = applePayStates.randomElement() ?? .notSupported
            return configuration
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let steps = stepBuilder.build()
        let step = steps.first(where: {$0.view is ApplePayEnrollmentViewProtocol })
        XCTAssertNil(step)
    }
    
    func test_add_paymentMethod_step() {
        self.dependenciesResolver.register(for: CardEntity.self) { _ in
            return self.cardEntity
        }
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            let configuration = CardboardingConfiguration(card: self.cardEntity)
            configuration.allowSteps = [.changePaymentType]
            configuration.paymentMethod = try? self.loadPayments()
            return configuration
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let step = stepBuilder.build().first
        XCTAssert(step?.view is ChangePaymentMethodViewProtocol)
    }
    
    func test_add_geolocation_step_when_userLocation_is_enabled() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            let configuration = CardboardingConfiguration(card: self.cardEntity)
            configuration.allowSteps = [.geolocation]
            configuration.geolocationEnabled = false
            return configuration
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let step = stepBuilder.build().first
        XCTAssertTrue(step?.view is CardBoardingGeolocationViewProtocol)
    }
    
    func test_try_to_add_geolocation_step_when_userLocation_is_disabled() {
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            let configuration = CardboardingConfiguration(card: self.cardEntity)
            configuration.allowSteps = [.geolocation]
            configuration.geolocationEnabled = true
            return configuration
        }
        let stepBuilder = CardBoardingStepBuilder(dependenciesResolver: dependenciesResolver)
        let step = stepBuilder.build().first
        XCTAssertFalse(step?.view is CardBoardingGeolocationViewProtocol)
    }
}

private extension CardBoardingStepBuilderTest {
    
    func setDependencies() {
        self.setupCommonsDependencies()
        self.dependenciesResolver.register(for: GetCreditCardPaymentMethodUseCase.self) { resolver in
           return GetCreditCardPaymentMethodUseCase(dependenciesResolver: resolver)
        }
    }
    
    func loadPayments() throws -> ChangePaymentEntity {
        let paymentUseCase = self.dependenciesResolver.resolve(for: GetCreditCardPaymentMethodUseCase.self)
        let card = dependenciesResolver.resolve(for: CardEntity.self)
        let input = GetCreditCardPaymentMethodUseCaseInput(card: card)
        return try paymentUseCase.executeUseCase(requestValues: input)
            .getOkResult()
            .changePayment
    }
}

extension CardBoardingStepBuilderTest: RegisterCommonDependenciesProtocol {}
