//
//  DataRepository.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public protocol DataRepository {

    func store<T>(_ t: T) where T: Codable
    func store<T>(_ t: T,_ dataRepositoryPolicy: DataRepositoryPolicy) where T: Codable
    func store<T>(_ t: T, _ key: String) where T : Codable
    func store<T>(_ t: T,_ key: String,_ dataRepositoryPolicy: DataRepositoryPolicy) where T: Codable
    
    func get<T>(_ type: T.Type) -> T? where T: Codable
    func get<T>(_ type: T.Type,_ dataRepositoryPolicy: DataRepositoryPolicy) -> T? where T: Codable
    func get<T>(_ type: T.Type,_ key: String) -> T? where T: Codable
    func get<T>(_ type: T.Type,_ key: String,_ dataRepositoryPolicy: DataRepositoryPolicy) -> T? where T: Codable

    func remove<T>(_ type: T.Type)
    func remove<T>(_ type: T.Type,_ dataRepositoryPolicy: DataRepositoryPolicy)
    func remove<T>(_ type: T.Type,_ key: String)
    func remove<T>(_ type: T.Type,_ key: String,_ dataRepositoryPolicy: DataRepositoryPolicy)

}
