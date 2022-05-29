//
//  OnBoardingDependencies.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 13/12/21.
//

import Foundation
import UI
import CoreFoundationLib

public protocol OnBoardingExternalDependencies {
    func resolve() -> UINavigationController
    func resolveOnBoardingCustomStepView(for identifier: String, coordinator: StepsCoordinator<OnBoardingStep>) -> StepIdentifiable
}

protocol OnBoardingDependencies {
    var external: OnBoardingExternalDependencies { get }
    func resolve() -> StepsCoordinator<OnBoardingStep>
    func resolve() -> DataBinding
    func resolve() -> OnBoardingStep1ViewController
    func resolve() -> OnBoardingStep2ViewController
}

extension OnBoardingDependencies {
    
    func resolve() -> OnBoardingStep1ViewController {
        return Step1Dependencies(depencies: self).resolve()
    }
    
    func resolve() -> OnBoardingStep2ViewController {
        return Step2Dependencies(depencies: self).resolve()
    }
}
