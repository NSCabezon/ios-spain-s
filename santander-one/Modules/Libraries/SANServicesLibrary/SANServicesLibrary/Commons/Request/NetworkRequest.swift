//
//  RequestProtocol.swift
//  Account
//
//  Created by Hernán Villamil on 30/11/21.
//

import Foundation

public protocol NetworkRequest {
    var method: String { get }
    var serviceName: String { get }
    var url: String { get }
    var headers: [String: String] { get }
    var body: String { get }
}
