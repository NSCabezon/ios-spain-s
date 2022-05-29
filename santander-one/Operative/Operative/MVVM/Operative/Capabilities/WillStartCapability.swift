//
//  WillStartCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import Foundation
import OpenCombine
import UI

/// Conforms this protocol if you want to add a `condition` on `willStart` event of the operative.
public protocol WillStartCapability: Capability {
    var willStartPublisher: AnyPublisher<ConditionState, Never> { get }
}

extension WillStartCapability {
    
    var publisher: AnyPublisher<ConditionState, Never> {
        return Deferred {
            self.willStartPublisher
        }.eraseToAnyPublisher()
    }

    public func configure() {
        operative.willStartConditions.append(publisher.eraseToAnyPublisher())
    }
}
