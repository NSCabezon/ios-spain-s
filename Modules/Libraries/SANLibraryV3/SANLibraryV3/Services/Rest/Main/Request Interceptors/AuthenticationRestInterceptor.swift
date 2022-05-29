//
//  AuthorizationRestInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import Foundation
import SANServicesLibrary

public struct AuthorizationRestInterceptor: NetworkRequestInterceptor {
    
    let token: String
    
    public func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var headers = request.headers
        headers["Authorization"] = "Bearer " + token
        return InterceptedRequest(serviceName: request.serviceName,
                                  url: request.url,
                                  headers: headers,
                                  method: request.method,
                                  body: request.body)
    }
}
