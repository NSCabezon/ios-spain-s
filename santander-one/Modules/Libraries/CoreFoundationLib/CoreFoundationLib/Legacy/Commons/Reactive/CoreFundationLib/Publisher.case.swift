//
//  Publisher.case.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/16/21.
//

import Foundation
import OpenCombine

public extension OpenCombine.Publisher where Output: State {
    
    func `case`<ElementOfResult>(_ closure: @escaping (ElementOfResult) -> Output) -> OpenCombine.Publishers.CompactMap<Self, ElementOfResult> {
        return OpenCombine.Publishers.CompactMap(upstream: self, transform: {
            $0.associatedValue(mathing: closure)
        })
    }
    
    func `case`(_ output: Output) -> OpenCombine.Publishers.Map<Publishers.Filter<Self>, Void> {
        return OpenCombine.Publishers.Filter(upstream: self, isIncluded: {
            String(describing: $0) == String(describing: output)
        }).map({ _ in return () })
    }
    
    @available(*, deprecated, message: "Use the `case(Enum.case)` method instead. Simply change `case { Enum.case }` with `case(Enum.case)`")
    func `case`<ElementOfResult>(closure: @escaping () -> (ElementOfResult) -> Output) -> OpenCombine.Publishers.CompactMap<Self, ElementOfResult> {
        return OpenCombine.Publishers.CompactMap(upstream: self, transform: {
            $0.associatedValue(mathing: closure())
        })
    }
    
    @available(*, deprecated, message: "Use the `case(Enum.case)` method instead. Simply change `case { Enum.case }` with `case(Enum.case)`")
    func `case`(closure: @escaping () -> Output) -> OpenCombine.Publishers.Filter<Self> {
        return OpenCombine.Publishers.Filter(upstream: self, isIncluded: {
            String(describing: $0) == String(describing: closure())
        })
    }
}
