//
//  MockOperativeWithProgressBar.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 20/1/22.
//

import Foundation
import Operative
import OpenCombine
import UI

final class MockOperativeWithProgressBar: ReactiveOperative {
    
    var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    var coordinator: OperativeCoordinator
    var subscriptions: Set<AnyCancellable> = []
    var stepsCoordinator: StepsCoordinator<MockStep>
    var shouldShowProgress: (StepType) -> Bool
    lazy var capability = {
        return DefaultProgressBarCapability(operative: self, progressBarType: .stepped, shouldShowProgress: shouldShowProgress)
    }()
    
    lazy var capabilities: [AnyCapability] = {
        return [
            capability.asAnyCapability()
        ]
    }()
    
    init(coordinator: OperativeCoordinator, stepsCoordinator: StepsCoordinator<MockStep>, shouldShowProgress: @escaping (StepType) -> Bool) {
        self.coordinator = coordinator
        self.stepsCoordinator = stepsCoordinator
        self.shouldShowProgress = shouldShowProgress
    }
}
