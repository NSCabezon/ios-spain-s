
//  StepInteractor.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation

final class StepInteractor {
    private var steps: [OnBoardingStepConformable]
    private var position: Int = -1
    private var stepBeforeCandidate: OnBoardingStepConformable?
    private var bypassingStep: Bool = false
    private var candidatePosition: Int = 0
    init(steps: [OnBoardingStepConformable]) {
        self.steps = steps
    }
    
    func getCurrentPosition() -> Int {
        return self.position
    }
    
    func isLastStep() -> Bool {
        return self.position == self.steps.count-1
    }
    
    func resetCurrentPosition() {
        self.position = -1
    }
    
    var count: Int {
        return self.steps.count
    }
    
    var nonZeroIndexCount: Int {
        guard self.steps.count > 0 else {
            return 0
        }
        return self.steps.count - 1
    }
    
    func popStep() {
        let index = position - 1
        guard index >= 0 else { return }
        self.position -= 1
    }
    
    @discardableResult
    func next() -> OnBoardingStepConformable? {
        guard self.position != self.steps.count-1 else {
            return nil
        }
        if !canGoNext() {
            self.position += 1
            next()
        }
        guard self.bypassingStep == false else {
            self.position = candidatePosition
            return self.steps[position]
        }
        self.bypassingStep = false
        let index = position + 1
        guard index >= 0, index <= (self.steps.count) else { return nil }
        self.position += 1
        return self.steps[position]
    }
    
    func getStepWithIdentifier(_ identifier: OnboardingStepIdentifier) -> OnBoardingStepConformable? {
        guard let stepIndex = self.steps.firstIndex(where: {$0.stepIdentifier == identifier}) else {
            return nil
        }
        guard stepIndex+1 < steps.count else { return nil }
        self.position = stepIndex
        return steps[stepIndex]
    }
    
    func insertStep(_ step: OnBoardingStepConformable, afterStepIdentifier identifier: OnboardingStepIdentifier) {
        if let stepIndex = self.steps.firstIndex(where: {$0.stepIdentifier == identifier}),
           stepIndex < self.steps.count {
            self.steps.insert(step, at: stepIndex+1)
        }
    }
}

private extension StepInteractor {
    func canGoNext() -> Bool {
        if self.position < 0 { return true }
        let currentStep = self.stepBeforeCandidate ?? self.steps[self.position]
        self.candidatePosition = (self.position == self.steps.count-1) ? self.position :  self.position+1
        let nextStep = self.steps[candidatePosition]
        
        if currentStep.verticalNavigation == false && nextStep.verticalNavigation == true {
            self.stepBeforeCandidate = self.steps[self.position]
            self.bypassingStep = true
            return false
        }
        self.stepBeforeCandidate = nil
        return true
    }
}
