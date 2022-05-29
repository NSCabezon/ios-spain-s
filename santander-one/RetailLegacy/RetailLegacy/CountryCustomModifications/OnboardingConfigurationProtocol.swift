//
//  OnboardingOptionsProtocol.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 19/10/21.
//

public enum OnboardingStepIdentifier: Equatable {
    case welcome
    case language
    case alias
    case options
    case globalPosition
    case photoTheme
    case final
    case custom
}

public protocol OnboardingConfigurationProtocol {
    var onboardingDelegate: OnboardingDelegate? { get set }
    var userData: OnboardingUserData? { get set }
    var allowOnboardingAbort: Bool { get }
    var steps: [OnboardingStepIdentifier] { get }
    func getCustomSteps() -> [OnboardingCustomStep]?
}
