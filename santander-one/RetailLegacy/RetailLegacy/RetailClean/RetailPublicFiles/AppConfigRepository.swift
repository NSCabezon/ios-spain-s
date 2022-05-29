import CoreFoundationLib
import Foundation
import OpenCombine

class AppConfigRepository: BaseRepository {
    var logTag: String {
        return String(describing: type(of: self))
    }
    typealias T = AppConfigDTO
    let datasource: AppConfigDataSource
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient, versionName: String) {
        datasource = AppConfigDataSource(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, versionName: versionName)
    }
    
    func getAppConfigNode<T>(nodeName: String) -> T? {
        if let appConfigDTO = get(), let defaultConfig = appConfigDTO.defaultConfig, let value = defaultConfig[nodeName] {
            return value as? T
        }
        return nil
    }
    
    func getAppConfigBooleanNode(nodeName: String) -> Bool? {
        if let nodeValue: String = getAppConfigNode(nodeName: nodeName) {
            return nodeValue.toBool()
        } else {
            return nil
        }
    }
    
    func getAppConfigDecimalNode(nodeName: String) -> Decimal? {
        if let nodeValue: String = getAppConfigNode(nodeName: nodeName) {
            return nodeValue.stringToDecimal
        } else {
            return nil
        }
    }
    
    func getAppConfigListNode(_ nodeName: String) -> [String]? {
        guard var literalString: String = getAppConfigNode(nodeName: nodeName) else {
            return nil
        }
        if literalString.first == "[" {
            literalString = String(literalString.dropFirst())
        }
        if literalString.last == "]" {
            literalString = String(literalString.dropLast())
        }
        let tempArray = literalString.components(separatedBy: ", ")
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

extension AppConfigRepository: AppConfigRepositoryProtocol {
    
    func getString(_ nodeName: String) -> String? {
        return self.getAppConfigNode(nodeName: nodeName)
    }
    
    func getBool(_ nodeName: String) -> Bool? {
        return self.getAppConfigBooleanNode(nodeName: nodeName)
    }
    
    func getDecimal(_ nodeName: String) -> Decimal? {
        return self.getAppConfigDecimalNode(nodeName: nodeName)
    }
    
    func getInt(_ nodeName: String) -> Int? {
        guard let string = self.getString(nodeName) else { return nil }
        return Int(string)
    }
    
    func getAppConfigListNode<T: Decodable>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? {
        guard var string: String = getAppConfigNode(nodeName: nodeName) else { return nil }
        switch options {
        case .json5Allowed:
            string = string.replace("'", "\"")
        default: break
        }
        guard let data = string.data(using: .utf8),
              let object = try? JSONDecoder().decode([T].self, from: data) else { return nil }
        return object
    }
}

extension AppConfigRepository {
    func value<Value: LosslessStringConvertible>(for key: String) -> AnyPublisher<Value?, Never> {
        let node = self.getAppConfigNode(nodeName: key).flatMap(Value.init)
        return Just(node).eraseToAnyPublisher()
    }
    
    func value<Value: LosslessStringConvertible>(for key: String, defaultValue: Value) -> AnyPublisher<Value, Never> {
        return value(for: key).compactMap { $0 ?? defaultValue }
        .eraseToAnyPublisher()
    }
    
    func values<Value: LosslessStringConvertible>(for keys: [String: Value]) -> AnyPublisher<[String: Value], Never> {
        let values = keys.reduce(into: [String: Value]()) { (accumulator, next) in
            let node: String? = getAppConfigNode(nodeName: next.key)
            accumulator[next.key] = stringToValue(node) ?? (next.value as Value)
        }
        return Just(values).eraseToAnyPublisher()
    }
    
    func values<Value: LosslessStringConvertible>(for keys: [String]) -> AnyPublisher<[Value?], Never> {
        let values = keys.reduce(into: [Value?]()) { (accumulator, next) in
            let node: String? = getAppConfigNode(nodeName: next)
            accumulator.append(stringToValue(node) ?? nil)
        }
        return Just(values).eraseToAnyPublisher()
    }
}

extension AppConfigRepository {
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
