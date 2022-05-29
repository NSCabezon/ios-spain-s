//
//  GetStepperValuesUseCase.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 11/2/22.
//

import Foundation
import OpenCombine
import UI
import CoreFoundationLib

public protocol OnboardingStepperValuesRepresentable {
    var currentPosition: Int? { get }
    var totalSteps: Int { get }
}

protocol GetStepperValuesUseCase {
    func fetch() -> AnyPublisher<OnboardingStepperValuesRepresentable, Never>
}

public struct DefaultGetStepperValuesUseCase {
    let stepsCoordinator: StepsCoordinator<OnboardingStep>
    let onboardingConfiguration: OnboardingConfiguration
    
    public init(stepsCoordinator: StepsCoordinator<OnboardingStep>, onboardingConfiguration: OnboardingConfiguration) {
        self.stepsCoordinator = stepsCoordinator
        self.onboardingConfiguration = onboardingConfiguration
    }
}

extension DefaultGetStepperValuesUseCase: GetStepperValuesUseCase {
    public func fetch() -> AnyPublisher<OnboardingStepperValuesRepresentable, Never> {
        return Just(getStepperValues())
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetStepperValuesUseCase {
    
    struct StepperValues: OnboardingStepperValuesRepresentable {
        let currentPosition: Int?
        let totalSteps: Int
    }
    
    func getStepperValues() -> OnboardingStepperValuesRepresentable {
        guard let index = getActiveCountableSteps().firstIndex(of: stepsCoordinator.current.type) else {
            return StepperValues(currentPosition: nil, totalSteps: getActiveCountableSteps().count)
        }
        return StepperValues(currentPosition: index + 1, totalSteps: getActiveCountableSteps().count)
    }
    
    func getActiveCountableSteps() -> [OnboardingStep] {
        let activeSteps = stepsCoordinator.steps
            .filter({ $0.state == .enabled })
            .map { $0.type }
        var activeContableSteps: [OnboardingStep] = []
        activeSteps.forEach {
            if onboardingConfiguration.countableSteps.contains($0) { activeContableSteps.append($0) }
        }
        return activeContableSteps
    }
}
