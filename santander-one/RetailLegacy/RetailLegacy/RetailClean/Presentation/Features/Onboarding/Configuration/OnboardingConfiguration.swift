//
//  OnboardingConfiguration.swift
//
//  Created by Boris Chirino Fernandez on 11/10/21.
//

import CoreFoundationLib

public typealias OnboardingCustomStep = (step: OnBoardingStepConformable, identifier: OnboardingStepIdentifier)?

struct SceneConfig {
    let view: OnBoardingStepView.Type
    let presenter: OnboardingStepPresenterConformable.Type
}

final class OnboardingConfiguration {
    var onboardingDelegate: OnboardingDelegate?
    var userData: OnboardingUserData?
    private (set) var steps: [OnboardingStepIdentifier] = OnboardingConfiguration.defaultSteps
    private (set) var allowOnboardingAbort: Bool = true
    private let dependencies: DependenciesResolver
    var customStepsValue: [OnboardingCustomStep]?
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.setupConfiguration()
    }
}

private extension OnboardingConfiguration {
    func setupConfiguration() {
        if let countryConfiguration = self.dependencies.resolve(forOptionalType: OnboardingConfigurationProtocol.self) {
            self.steps = countryConfiguration.steps
            self.allowOnboardingAbort = countryConfiguration.allowOnboardingAbort
            guard let customStepData = countryConfiguration.getCustomSteps() else {
                return
            }
            self.customStepsValue = customStepData
        }
    }
}

extension OnboardingConfiguration: OnboardingConfigurationProtocol {
    func getCustomSteps() -> [OnboardingCustomStep]? {
        return nil
    }
}

extension OnboardingConfiguration {
    static let defaultSteps: [OnboardingStepIdentifier] = [.welcome,
                                                  .language,
                                                  .options,
                                                  .globalPosition,
                                                  .photoTheme,
                                                  .final]
}
