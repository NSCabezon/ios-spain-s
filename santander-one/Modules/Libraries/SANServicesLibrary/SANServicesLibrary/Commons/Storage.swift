//
//  Storage.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import Foundation

public protocol Storage {
    func clean()
    func store<Data>(_ data: Data)
    func store<Data>(_ data: Data, type: Data.Type)
    func store<Data>(_ data: Data, id: String)
    func get<Data>(id: String) -> Data?
    func get<Data>(_ type: Data.Type) -> Data?
    func get<Data>() -> Data?
}
