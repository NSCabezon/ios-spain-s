//
//  Serializer.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public protocol Serializer {

    /**
     * Serialize an object to Json.
     *
     * @param object {@link Object} to serialize.
     */
    func serialize<T:Codable>(_ object: T) -> String?

    /**
     * Deserialize a json representation of an object.
     *
     * @param serializedJson A json string to deserialize.
     *
     * @return {@link T}
     */
    func deserialize<T:Codable>(_ serializedJson: String, _  type: T.Type) -> T?

    /**
     * Serialize a list to Json.
     *
     * @param ts {@link java.lang.Object} to serialize.
     */
    func serializeList<T:Encodable>(_ ts: [T]) -> String?

    /**
     * Deserialize a json to a list.
     *
     * @param serializedJson A json string to deserialize.
     *
     * @return {@link List<  T  >}
     */
    func deserializeList<T:Decodable>(_ serializedJson: String, _ type: T.Type) -> [T]?

    /**
     * Deserialize a DataWrapper<T>.
     *
     * @param serializedJson A json string to deserialize.
     *
     * @return {@link DataWrapper <T>}
     */
    func deserializeWrapper<T>(_ serializedJson: String, _ type: T.Type) -> DataWrapper<T>?


}
