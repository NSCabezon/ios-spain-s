//
//  OnboardingLanguageStep.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 14/10/21.
//

final class OnboardingLanguageStep: OnBoardingStepConformable {
    var stepIdentifier: OnboardingStepIdentifier = .language
    var view: OnBoardingStepView?
    var verticalNavigation: Bool = false
}
