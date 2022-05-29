//
//  CardBoardingStepBuilder.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/5/20.
//

import Foundation
import CoreFoundationLib

final class CardBoardingStepBuilder {
    private var steps: [CardBoardingStep] = []
    private let dependenciesResolver: DependenciesResolver
    private let configuration: CardboardingConfiguration
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = self.dependenciesResolver.resolve(for: CardboardingConfiguration.self)
    }
    
    func build() -> [CardBoardingStep] {
        self.addChangeCardAliasStep()
        self.addApplePayStep()
        self.addChangePaymentMethodStep()
        self.addNotificationsStep()
        self.addGeolocationStep()
        self.addAlmostDoneStep()
        self.addSummaryStep()
        self.steps.first?.setAsFirstStep()
        return self.steps
    }
    
    func addChangeCardAliasStep() {
        guard configuration.allowSteps.contains(.changeAlias) else { return }
        let step = ChangeCardAliasStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
    
    func addNotificationsStep() {
        guard configuration.allowSteps.contains(.notifications) else { return }
        guard !configuration.pushNotificationEnabled else { return }
        let step = NotificationsStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
    
    func addApplePayStep() {
        guard configuration.allowSteps.contains(.inApp) else { return }
        guard configuration.applePayState == .inactive else { return }
        let step = ApplePayEnrollmentStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
    
    func addChangePaymentMethodStep() {
        guard configuration.allowSteps.contains(.changePaymentType) else { return }
        guard configuration.paymentMethod != nil else { return }
        let step = ChangePaymentMethodStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
    
    func addGeolocationStep() {
        guard configuration.allowSteps.contains(.geolocation) else { return }
        guard !configuration.geolocationEnabled else { return }
        let step = CardBoardingGeolocationStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
    
    func addSummaryStep() {
        let step = CardBoardingSummaryStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
    
    func addAlmostDoneStep() {
        let step = AlmostDoneStep(dependenciesResolver: dependenciesResolver)
        self.steps.append(step)
    }
}
