//
//  StubConvertible.swift
//  UnitTestCommons
//
//  Created by José Carlos Estela Anguita on 23/12/21.
//

import Foundation

public protocol StubConvertible {
    static var stub: Self { get }
}

extension String: StubConvertible {
    public static var stub: String {
        return ""
    }
}

extension Bool: StubConvertible {
    public static var stub: Bool {
        return false
    }
}

extension Optional: StubConvertible {
    public static var stub: Optional<Wrapped> {
        return nil
    }
}

extension Array: StubConvertible {
    public static var stub: Array<Element> {
        return []
    }
}

extension Dictionary: StubConvertible {
    public static var stub: Dictionary<Key, Value> {
        return [:]
    }
}

/// Use this propertyWraper for creating a Stub for a property that conforms `StubConvertible`
/// - Note:
///  Usage:
///  `@Stub var string: String`
@propertyWrapper
public struct Stub<Value: StubConvertible> {
    
    private var defaultValue: Value?
    
    public init(_ wrappedValue: Value? = nil) {
        self.defaultValue = wrappedValue
    }
    
    public var wrappedValue: Value {
        get {
            return defaultValue ?? Value.stub
        } set {
            defaultValue = newValue
        }
    }
}

/// Use this propertyWraper for creating a Stub for a protocol that doesn't inherit from `StubConvertible`
/// - Note:
/// An example of usage (when `Location` conforms `PullOfferLocationRepresentable`)
/// `@ProtocolStub(to: Location.self) var location: PullOfferLocationRepresentable`
/// `@ProtocolStub(Location()) var location: PullOfferLocationRepresentable`
@propertyWrapper
public struct ProtocolStub<StubProtocol, StubType: StubConvertible> {
    
    private var defaultValue: StubProtocol?
    
    public init(to type: StubType.Type) {
        guard let value = StubType.stub as? StubProtocol else { fatalError("Compiler can not help us in this point. So please, remember that \(StubType.self) has to conforms \(StubProtocol.self)") }
        self.defaultValue = value
    }
    
    public init(_ wrappedValue: StubType) {
        guard let value = wrappedValue as? StubProtocol else { fatalError("Compiler can not help us in this point. So please, remember that \(StubType.self) has to conforms \(StubProtocol.self)") }
        self.defaultValue = value
    }
    
    public var wrappedValue: StubProtocol {
        get {
            return defaultValue!
        } set {
            defaultValue = newValue
        }
    }
}
