//
//  ContentTypeRestInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 27/5/21.
//

import Foundation
import SANServicesLibrary

struct ContentTypeRestInterceptor: NetworkRequestInterceptor {
    
    enum ContentType {
        case json
        
        var value: String {
            switch self {
            case .json:
                return "application/json"
            }
        }
    }
    
    let type: ContentType
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var headers = request.headers
        headers["Content-Type"] = self.type.value
        return InterceptedRequest(serviceName: request.serviceName,
                                  url: request.url,
                                  headers: headers,
                                  method: request.method,
                                  body: request.body)
    }
}
