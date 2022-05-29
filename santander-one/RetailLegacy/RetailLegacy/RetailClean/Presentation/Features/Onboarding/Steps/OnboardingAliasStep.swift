//
//  OnboardingAliasStep.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 14/10/21.
//

final class OnboardingAliasStep: OnBoardingStepConformable {
    var verticalNavigation: Bool = true
    var view: OnBoardingStepView?
    var stepIdentifier: OnboardingStepIdentifier = .alias
}
