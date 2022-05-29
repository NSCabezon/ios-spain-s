//
//  OnboardingStep.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 14/10/21.
//

import Foundation

public protocol OnBoardingStepView: AnyObject {}

public protocol OnBoardingStepConformable: AnyObject {
    var view: OnBoardingStepView? { get set}
    var stepIdentifier: OnboardingStepIdentifier { get }
    var verticalNavigation: Bool { get }
    init()
}

public protocol OnboardingStepPresenterConformable: AnyObject {
    var delegate: OnboardingDelegate? { get set }
    var onboardingUserData: OnboardingUserData? { get set }
    var viewController: OnBoardingStepView? { get }
}

protocol StepCreatable: AnyObject {
    associatedtype Presenter: OnboardingStepPresenterConformable
    associatedtype View
}
