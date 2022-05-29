//
//  SoapParser.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 20/5/21.
//

import Foundation

public protocol StringInstantiable {
    init?(from string: String)
}

extension String: StringInstantiable {
    public init?(from string: String) {
        self.init(string)
    }
}

extension Int: StringInstantiable {
    public init?(from string: String) {
        self.init(string)
    }
}

extension Decimal: StringInstantiable {
    public init?(from string: String) {
        self.init(string: string)
    }
}

public final class XMLDecoder: NSObject, XMLParserDelegate {
    
    private let data: Data
    private var decodingData: DecodingData?
    private var deep: Int = 0
    
    public init(data: Data) {
        self.data = data
    }
    
    public func xml() -> String? {
        return String(data: data, encoding: .utf8)
    }
    
    public func decode(key: String) -> [XMLDecoder] {
        return ArrayXMLDecoder(data: self.data).decode(key: key)
    }
    
    public func decode(key: String) -> XMLDecoder? {
        return ArrayXMLDecoder(data: self.data).decode(key: key).first
    }
    
    public func decode(key: String, format: String) -> Date? {
        self.decodingData = DecodingData(key: key)
        let parser = XMLParser(data: self.data)
        parser.delegate = self
        parser.parse()
        guard let input = self.decodingData?.value else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.date(from: input)
    }
    
    public func decode(key: String) -> Bool? {
        self.decodingData = DecodingData(key: key)
        let parser = XMLParser(data: self.data)
        parser.delegate = self
        parser.parse()
        guard let input = self.decodingData?.value else { return nil }
        switch input {
        case "S":
            return true
        case "TRUE":
            return true
        case "N":
            return false
        default:
            return nil
        }
    }
    
    public func decode<Value: StringInstantiable>(key: String) -> Value? {
        self.decodingData = DecodingData(key: key)
        let parser = XMLParser(data: self.data)
        parser.delegate = self
        parser.parse()
        return self.decodingData?.value.flatMap({ Value(from: $0) })
    }
    
    public func decode<Value: StringInstantiable>(key: String, separatedBy: String) -> [Value]? {
        self.decodingData = DecodingData(key: key)
        let parser = XMLParser(data: self.data)
        parser.delegate = self
        parser.parse()
        return decodePositions(self.decodingData?.value, separatedBy: separatedBy)
    }
    
    func decodePositions<Value: StringInstantiable>(_ positions: String?, separatedBy: String) -> [Value]? {
        if let positions = positions, !positions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let arrayPositions: [String] = positions.components(separatedBy: separatedBy)
            var arrayValuePositions: [Value] = []
            for s in arrayPositions {
                guard let posicion = Value(from: s) else { continue }
                arrayValuePositions.append(posicion)
            }
            return arrayValuePositions
        }
        return nil
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        guard let key = self.decodingData?.key, elementName == key else { return }
        self.deep += 1
        if deep > 1 {
            self.decodingData?.value = ""
        }
        self.decodingData?.state = .modifing
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard self.decodingData?.state == .modifing else { return }
        let currentValue = self.decodingData?.value ?? ""
        self.decodingData?.value = currentValue + string
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let key = self.decodingData?.key, elementName == key else { return }
        if self.deep == 1 {
            self.decodingData?.state = .finished
        }
        self.deep-=1
    }
}

private final class DecodingData {
    
    enum State {
        case withoutValue
        case modifing
        case finished
    }
    
    let key: String
    var value: String?
    var state: State = .withoutValue
    
    init(key: String) {
        self.key = key
    }
}

private final class ArrayXMLDecoder: NSObject, XMLParserDelegate {
    
    private let data: Data
    private var decodingData: DecodingData?
    private var elements: [XMLDecoder] = []
    private var deep = 0
    private var deepForKey: [String:Int] = [:]
    
    init(data: Data) {
        self.data = data
    }
    
    func decode(key: String) -> [XMLDecoder] {
        self.decodingData = DecodingData(key: key)
        let parser = XMLParser(data: self.data)
        parser.delegate = self
        parser.parse()
        return self.elements
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let key = self.decodingData?.key, elementName == key {
            self.decodingData?.state = .modifing
            addDeep(key)
        }
        guard self.decodingData?.state == .modifing else { return }
        let value = self.decodingData?.value ?? ""
        if let key = self.decodingData?.key, elementName == key, deepForKey[key] == 1 {
            
        }
        self.decodingData?.value = value + "<\(elementName)>"
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard self.decodingData?.state == .modifing else { return }
        let value = self.decodingData?.value ?? ""
        self.decodingData?.value = value + "</\(elementName)>"
        if let key = self.decodingData?.key, elementName == key {
            if deepEnded(key) {
                self.decodingData?.state = .finished
            }
            subDeep(key)
        }
        guard self.decodingData?.state == .finished, let data = self.decodingData?.value.flatMap({ $0.data(using: .utf8) }) else { return }
        self.elements.append(XMLDecoder(data: data))
        self.decodingData?.value = nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let xml = self.decodingData?.value else { return }
        self.decodingData?.value = xml + string
    }
    
    private func addDeep(_ key: String) {
        var deep: Int = deepForKey[key] ?? 0
        deep += 1
        deepForKey[key] = deep
    }
    
    private func subDeep(_ key: String) {
        var deep: Int = deepForKey[key] ?? 0
        deep -= 1
        deepForKey[key] = deep
    }
    
    private func deepEnded(_ key: String) -> Bool {
        (deepForKey[key] ?? 0 ) <= 1
    }
}

public protocol SoapBodyConvertible {
    var body: String { get }
}
