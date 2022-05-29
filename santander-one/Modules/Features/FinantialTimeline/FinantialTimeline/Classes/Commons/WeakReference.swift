//
//  WeakReference.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 11/07/2019.
//

import Foundation

class WeakReference<Type> {
    
    private weak var value: AnyObject?
    
    init(value: Type) {
        self.value = value as AnyObject
    }
    
    func get() -> Type? {
        return value as? Type
    }
}
