import OpenCombine
import CoreFoundationLib
import OpenCombine

public final class MockAppConfigRepository: AppConfigRepositoryProtocol {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getConfiguration() -> [String: String] {
        let dto =  self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData
        return dto?.defaultConfig ?? [:]
    }
    
    public func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T : Decodable {
        guard var string: String = self.getConfiguration()[nodeName] else { return nil }
        switch options {
        case .json5Allowed:
            string = string.replace("'", "\"")
        default: break
        }
        guard let data = string.data(using: .utf8),
              let object = try? JSONDecoder().decode([T].self, from: data) else { return nil }
        return object
    }
    
    public func getBool(_ nodeName: String) -> Bool? {
        guard let stringValue = self.getConfiguration()[nodeName] else { return nil }
        return Bool(stringValue)
    }
    
    public func getDecimal(_ nodeName: String) -> Decimal? {
        guard let stringValue = self.getConfiguration()[nodeName] else { return nil }
        return Decimal(string: stringValue)
    }
    
    public func getInt(_ nodeName: String) -> Int? {
        guard let stringValue = self.getConfiguration()[nodeName] else { return nil }
        return Int(stringValue)
        
    }
    
    public func getString(_ nodeName: String) -> String? {
        return self.getConfiguration()[nodeName]
    }
    
    public func getAppConfigListNode(_ nodeName: String) -> [String]? {
        guard var listString = self.getConfiguration()[nodeName] else { return nil }
        if listString.first == "[" {
            listString = String(listString.dropFirst())
        }
        if listString.last == "]" {
            listString = String(listString.dropLast())
        }
        let tempArray = listString.components(separatedBy: ", ")
        let convertedArray = tempArray.map({ (text) -> String in
            var convertedText = text
            if text.first == "'" {
                convertedText = String(convertedText.dropFirst())
            }
            if text.last == "'" {
                convertedText = String(convertedText.dropLast())
            }
            return convertedText
        })
        return convertedArray
    }
}

public extension MockAppConfigRepository {
    func value<Value: LosslessStringConvertible>(for key: String) -> AnyPublisher<Value?, Never> {
        let value = self.getConfiguration()[key].flatMap(Value.init)
        return Just(value).eraseToAnyPublisher()
    }
    
    public func value<Value: LosslessStringConvertible>(for key: String, defaultValue: Value) -> AnyPublisher<Value, Never> {
        return value(for: key).compactMap({ $0 ?? defaultValue }).eraseToAnyPublisher()
    }
    
    public func values<Value: LosslessStringConvertible>(for keys: [String: Value]) -> AnyPublisher<[String: Value], Never> {
        let values = keys.reduce(into: [String: Value]()) { (acc, next) in
            let node: String? = getConfiguration()[next.key]
            acc[next.key] = stringToValue(node) ?? (next.value as Value)
        }
        return Just(values).eraseToAnyPublisher()
    }
    
    public func values<Value: LosslessStringConvertible>(for keys: [String]) -> AnyPublisher<[Value?], Never> {
        let values = keys.reduce(into: [Value?]()) { (acc, next) in
            let node: String? = getConfiguration()[next]
            acc.append(stringToValue(node) ?? nil)
        }
        return Just(values).eraseToAnyPublisher()
    }
}

public struct AppConfigDTOMock: Decodable {
    public var defaultConfig: [String: String]?
    
    public init(defaultConfig: [String: String]) {
        self.defaultConfig = defaultConfig
    }
}

extension MockAppConfigRepository {
    func stringToValue<Value: LosslessStringConvertible>(_ node: String?) -> Value? {
        guard let node = node else { return nil }
        if Value.self == Bool.self {
            return node.toBool() as? Value
        }
        if Value.self == Int.self {
            return Int(node) as? Value
        }
        if Value.self == Decimal.self {
            return node.stringToDecimal as? Value
        }
        return node as? Value
    }
}
