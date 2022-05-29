//
//  AppConfigRepositoryProtocol.swift
//  Commons
//
//  Created by Jose Carlos Estela Anguita on 27/11/2019.
//

import Foundation
import OpenCombine

public enum AppConfigDecodeOptions {
    case json5Allowed
    case none
}

public protocol AppConfigRepositoryProtocol {
    func getBool(_ nodeName: String) -> Bool?
    func getDecimal(_ nodeName: String) -> Decimal?
    func getInt(_ nodeName: String) -> Int?
    func getString(_ nodeName: String) -> String?
    func getAppConfigListNode(_ nodeName: String) -> [String]?
    func getAppConfigListNode<T: Decodable>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]?
    func value<Value: LosslessStringConvertible>(for key: String) -> AnyPublisher<Value?, Never>
    func value<Value: LosslessStringConvertible>(for key: String, defaultValue: Value) -> AnyPublisher<Value, Never>
    func values<Value: LosslessStringConvertible>(for keys: [String: Value]) -> AnyPublisher<[String: Value], Never>
    func values<Value: LosslessStringConvertible>(for keys: [String]) -> AnyPublisher<[Value?], Never>
}
