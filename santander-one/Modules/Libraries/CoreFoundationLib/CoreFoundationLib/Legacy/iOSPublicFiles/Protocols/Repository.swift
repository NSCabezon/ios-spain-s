//
//  DataSource.swift
//  iOS-Public-Files
//
//  Created by Johann Casique on 07/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

public protocol Repository {
    associatedtype T
    mutating func get() -> T?
    mutating func load(withBaseUrl url: String)
    mutating func load(baseUrl: String, publicLanguage: PublicLanguage)
    func remove()
}
