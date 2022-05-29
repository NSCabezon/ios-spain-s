//
//  OnboardingOptionsStep.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 15/10/21.
//

final class OnboardingOptionsStep: OnBoardingStepConformable {
    var stepIdentifier: OnboardingStepIdentifier = .options
    var view: OnBoardingStepView?
    var verticalNavigation: Bool = false
}

