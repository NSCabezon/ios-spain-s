//
//  SantanderChannelRestInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 31/5/21.
//

import Foundation
import SANServicesLibrary

public struct SantanderChannelRestInterceptor: NetworkRequestInterceptor {
    
    public init() { }
    
    public func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var headers = request.headers
        headers["X-Santander-Channel"] = "RML"
        return InterceptedRequest(serviceName: request.serviceName,
                                  url: request.url,
                                  headers: headers,
                                  method: request.method,
                                  body: request.body)
    }
}
