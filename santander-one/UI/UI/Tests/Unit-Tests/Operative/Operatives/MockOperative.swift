//
//  MockOperative.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 21/1/22.
//

import Foundation
import Operative
import OpenCombine
import UI

final class MockOperative: ReactiveOperative {
    
    var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    var coordinator: OperativeCoordinator
    var subscriptions: Set<AnyCancellable> = []
    var stepsCoordinator: StepsCoordinator<MockStep>
    var capabiliesProvider: (MockOperative) -> [AnyCapability]
    lazy var capabilities: [AnyCapability] = {
        return capabiliesProvider(self)
    }()
    
    init(coordinator: OperativeCoordinator, stepsCoordinator: StepsCoordinator<MockStep>, capabiliesProvider: @escaping (MockOperative) -> [AnyCapability]) {
        self.coordinator = coordinator
        self.stepsCoordinator = stepsCoordinator
        self.capabiliesProvider = capabiliesProvider
    }
}
