//
//  MockOperativeWithGiveUpOpinator.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 20/1/22.
//

import Foundation
import Operative
import OpenCombine
import UI

final class MockOperativeWithGiveUpOpinator: ReactiveOperative {
    
    var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    var coordinator: OperativeCoordinator
    var opinatorCoordinator: BindableCoordinator
    var subscriptions: Set<AnyCancellable> = []
    var stepsCoordinator: StepsCoordinator<MockStep>
    
    lazy var capabilities: [AnyCapability] = {
        return [
            DefaultGiveUpOpinatorCapability(operative: self, opinatorCoordinator: opinatorCoordinator, giveUpOpinator: GiveUpOpinatorInfoEntity(path: "mock")).asAnyCapability()
        ]
    }()
    
    init(coordinator: OperativeCoordinator, opinatorCoordinator: BindableCoordinator, stepsCoordinator: StepsCoordinator<MockStep>) {
        self.coordinator = coordinator
        self.opinatorCoordinator = opinatorCoordinator
        self.stepsCoordinator = stepsCoordinator
    }
}
