//
//  ContentTypeSoapInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 27/5/21.
//

import Foundation
import SANServicesLibrary

struct ContentTypeSoapInterceptor: NetworkRequestInterceptor {
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var headers = request.headers
        headers["Content-Type"] = "text/xml charset=utf-8"
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: headers,
            method: request.method,
            body: request.body
        )
    }
}
