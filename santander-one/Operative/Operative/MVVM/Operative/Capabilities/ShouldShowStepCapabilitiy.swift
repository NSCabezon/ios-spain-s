//
//  ShouldShowStepCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 21/1/22.
//

import Foundation

/// A capability that receives a block that allows you to define in some step shouldn't be shown in some particular scenario.
public struct ShouldShowStepCapability<Operative: ReactiveOperative>: Capability {
    
    public let operative: Operative
    private let shouldShowStep: (Operative.StepType) -> Bool
    
    public init(operative: Operative, shouldShowStep: @escaping (Operative.StepType) -> Bool) {
        self.operative = operative
        self.shouldShowStep = shouldShowStep
    }
    
    public func configure() {
        operative.stepsCoordinator.shouldShowStep = shouldShowStep
    }
}
