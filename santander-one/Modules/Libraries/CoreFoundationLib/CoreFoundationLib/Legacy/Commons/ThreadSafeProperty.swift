//
//  ThreadSafeProperty.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 04/02/2020.
//

import Foundation

public class ThreadSafeProperty<T> {
    
    private var _property: T
    private let semaphore: DispatchSemaphore
    
    public var value: T {
        get {
            var result: T!
            self.semaphore.wait()
            result = _property
            self.semaphore.signal()
            return result
        }
        set {
            self.semaphore.wait()
            self._property = newValue
            self.semaphore.signal()
        }
    }
    
    public init(_ value: T) {
        self._property = value
        self.semaphore = DispatchSemaphore(value: 1)
    }
}
