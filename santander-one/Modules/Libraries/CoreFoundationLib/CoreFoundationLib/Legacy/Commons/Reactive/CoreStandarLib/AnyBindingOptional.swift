//
//  AnyBindingOptional.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/16/21.
//

import Foundation

@propertyWrapper
public struct AnyBindingOptional<EnclosingType: DataBindable, Value: ExpressibleByNilLiteral> {
    
    public static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingType, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingType, Self>
    ) -> Value {
        get {
            return instance.dataBinding.get() ?? Value(nilLiteral: ())
        }
        @available(*, unavailable)
        set {
            // Not available since we just want to get values from DataBinding, not to saving it
            fatalError()
        }
    }

    @available(*, unavailable)
    public var wrappedValue: Value {
        // Not available since we are accessing through the static subscript
        get { fatalError() }
        set { fatalError() }
    }
    
    public init() {}
}
