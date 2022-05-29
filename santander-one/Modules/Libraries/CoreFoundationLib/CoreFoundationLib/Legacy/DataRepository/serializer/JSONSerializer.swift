//
//  JSONSerializer.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class JSONSerializer: Serializer {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(){}

    public func serialize<T: Codable>(_ object: T) -> String? {
        do {
            let data = try encoder.encode(object)
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    public func serializeList<T: Encodable>(_ ts: [T]) -> String? {
        do {
            let data = try encoder.encode(ts)
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    public func deserialize<T: Codable>(_ serializedJson: String, _ type: T.Type) -> T? {
        guard let serializedJsonData = serializedJson.data(using: .utf8) else {
            return nil
        }
        
        return try? decoder.decode(T.self, from: serializedJsonData)
    }

    public func deserializeList<T: Decodable>(_ serializedJson: String, _ type: T.Type) -> [T]? {
        guard let serializedJsonData = serializedJson.data(using: .utf8) else {
            return nil
        }
        
        return try? decoder.decode([T].self, from: serializedJsonData)
    }

    public func deserializeWrapper<T>(_ serializedJson: String, _ type: T.Type) -> DataWrapper<T>? {
        guard let serializedJsonData = serializedJson.data(using: .utf8) else {
            return nil
        }
        
        return try? decoder.decode(DataWrapper<T>.self, from: serializedJsonData)
    }


}
