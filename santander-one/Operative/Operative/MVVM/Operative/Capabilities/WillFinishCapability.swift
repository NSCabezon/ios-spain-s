//
//  WillFinishCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import Foundation
import OpenCombine

/// Conforms this protocol if you want to add a `condition` on `willFinish` event of the operative.
public protocol WillFinishCapability: Capability {
    var willFinishPublisher: AnyPublisher<ConditionState, Never> { get }
}

extension WillFinishCapability {
    
    var publisher: AnyPublisher<ConditionState, Never> {
        return Deferred {
            self.willFinishPublisher
        }.eraseToAnyPublisher()
    }
    
    public func configure() {
        operative.willFinishConditions.append(publisher.eraseToAnyPublisher())
    }
}
