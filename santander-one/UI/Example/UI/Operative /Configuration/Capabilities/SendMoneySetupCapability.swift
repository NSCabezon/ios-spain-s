//
//  SendMoneySetupCapability.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Operative
import OpenCombine

struct SendMoneySetupCapability: WillStartCapability {
    let operative: SendMoneyOperative
    var willStartPublisher: AnyPublisher<ConditionState, Never> {
        return Just(.success).eraseToAnyPublisher()
    }
}
