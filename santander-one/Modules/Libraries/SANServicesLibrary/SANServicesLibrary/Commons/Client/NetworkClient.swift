//
//  WSClient.swift
//  SANServicesLibrary
//
//  Created by Hernán Villamil on 30/11/21.
//

import Foundation

public protocol NetworkClient {
    func request(_ request: NetworkRequest) throws -> Result<NetworkResponse, Error>
}
