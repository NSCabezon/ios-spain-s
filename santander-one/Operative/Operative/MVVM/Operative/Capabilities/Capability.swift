//
//  OperativeCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import Foundation

public protocol Configurable {
    func configure()
}

public protocol Capability: Configurable {
    associatedtype Operative: ReactiveOperative
    var operative: Operative { get }
    func asAnyCapability() -> AnyCapability
}

extension Capability {
    
    public func asAnyCapability() -> AnyCapability {
        return AnyCapability(capability: self)
    }
}

public struct AnyCapability: Configurable {
    
    private let base: Configurable
    
    public init<C: Capability>(capability: C) {
        base = capability
    }
    
    public func configure() {
        base.configure()
    }
}
