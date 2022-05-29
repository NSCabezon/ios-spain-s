//
//  Publishers.Optional.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/7/21.
//

import Foundation
import OpenCombine

extension OpenCombine.Publisher {
    public func optional() -> Publishers.Map<Self, Output?> {
        return Publishers.Map(upstream: self, transform: { $0 })
    }
}
