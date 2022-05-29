import CoreFoundationLib
import OpenCombine

public final class AppConfigRepositoryMock: AppConfigRepositoryProtocol {
    public func getBool(_ nodeName: String) -> Bool? {
        return true
    }
    
    public func getDecimal(_ nodeName: String) -> Decimal? {
        nil
    }
    
    public func getInt(_ nodeName: String) -> Int? {
        nil
    }
    
    public func getString(_ nodeName: String) -> String? {
        nil
    }
    
    public func getAppConfigListNode(_ nodeName: String) -> [String]? {
        nil
    }
    
    public func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T : Decodable {
        nil
    }
    
    public func value<Value: LosslessStringConvertible>(for key: String) -> AnyPublisher<Value?, Never> {
        return Empty().eraseToAnyPublisher()
    }
    
    public func value<Value: LosslessStringConvertible>(for key: String, defaultValue: Value) -> AnyPublisher<Value, Never> {
        return Just(defaultValue).eraseToAnyPublisher()
    }
    
    public func values<Value: LosslessStringConvertible>(for keys: [String: Value]) -> AnyPublisher<[String: Value], Never> {
        return Just(keys).eraseToAnyPublisher()
    }
    
    public func values<Value: LosslessStringConvertible>(for keys: [String]) -> AnyPublisher<[Value?], Never> {
        return Empty().eraseToAnyPublisher()
    }
    
    public init() {
    }
}
