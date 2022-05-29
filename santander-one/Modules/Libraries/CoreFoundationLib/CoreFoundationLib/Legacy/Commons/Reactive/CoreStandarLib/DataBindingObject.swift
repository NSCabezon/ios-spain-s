//
//  DataBinding.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 8/11/21.
//

import Foundation

public class DataBindingObject: DataBinding {
    private var values: [Any] = []
    
    public init() {}

    
    public func get<T>() -> T? {
        guard let index = values.firstIndex(where: { $0 is T }),
        let value = values[index] as? Optional<T> else {
           return nil
        }
        return value
    }
    
    public func set<T>(_ value: T) {
        defer { self.values.append(value) }
        guard let index = values.firstIndex(where: { $0 is T }) else { return }
        values.remove(at: index)
    }
    
    public func contains<T>(_ type: T.Type) -> Bool {
        return values.contains(where: { $0 is T })
    }
}
