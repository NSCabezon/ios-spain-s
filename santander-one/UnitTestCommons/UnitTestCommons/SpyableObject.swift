//
//  SpyableObject.swift
//  UnitTestCommons
//
//  Created by Boris Chirino Fernandez on 20/11/2020.
//

import Foundation

public final class SpyableObject<T: Equatable> {
    var onChange: ((T) -> Void)?
    
    public var value: T {
        willSet {
            onChange?(newValue)
        }
    }
    
    public init(value: T) {
        self.value = value
    }
}
