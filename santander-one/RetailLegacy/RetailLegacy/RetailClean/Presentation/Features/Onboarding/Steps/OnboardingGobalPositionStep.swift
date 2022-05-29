//
//  OnboardingGobalPositionPagerStep.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 15/10/21.
//

final class OnboardingGobalPositionStep: OnBoardingStepConformable {
    var stepIdentifier: OnboardingStepIdentifier = .globalPosition
    var view: OnBoardingStepView?
    var verticalNavigation: Bool = false
}
