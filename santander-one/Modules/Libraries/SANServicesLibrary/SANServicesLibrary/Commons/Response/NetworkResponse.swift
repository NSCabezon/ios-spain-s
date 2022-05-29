//
//  ResponseProtocol.swift
//  SANServicesLibrary
//
//  Created by Hernán Villamil on 30/11/21.
//

import Foundation

public protocol NetworkResponse {
    var body: String { get }
    var data: Data { get }
    var status: Int { get }
}

public protocol XMLDecodable {
    init?(decoder: XMLDecoder)
}
