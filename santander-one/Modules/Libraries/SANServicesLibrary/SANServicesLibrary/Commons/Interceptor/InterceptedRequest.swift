//
//  InterceptedRequest.swift
//  SANServicesLibrary
//
//  Created by Hernán Villamil on 30/11/21.
//

import Foundation

public struct InterceptedRequest: NetworkRequest {
    public var method: String
    public var body: String
    public let serviceName: String
    public let url: String
    public let headers: [String : String]
    
    public init(serviceName: String,
                url: String,
                headers: [String : String],
                method: String,
                body: String) {
        self.serviceName = serviceName
        self.url = url
        self.headers = headers
        self.body = body
        self.method = method
    }
}
