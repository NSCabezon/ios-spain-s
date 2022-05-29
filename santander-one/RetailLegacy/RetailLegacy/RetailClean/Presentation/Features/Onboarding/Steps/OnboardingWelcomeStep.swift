//
//  OnboardingAliasWelcomeStep.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 15/10/21.
//

final class OnboardingWelcomeStep: OnBoardingStepConformable {
    var view: OnBoardingStepView?
    var stepIdentifier: OnboardingStepIdentifier = .welcome
    var verticalNavigation: Bool = false
}
