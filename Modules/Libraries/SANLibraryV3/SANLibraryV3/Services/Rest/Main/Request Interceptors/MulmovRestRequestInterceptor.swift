//
//  MulmovRestRequestInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 27/5/21.
//
import SANServicesLibrary

public struct MulmovRestRequestInterceptor: NetworkRequestInterceptor {

    let urls: [String]
    
    public func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        var headers = request.headers
        if self.urls.contains(where: { request.url.contains($0) }) {
            headers["X-ClientId"] = "MULMOV"
        }
        return InterceptedRequest(serviceName: request.serviceName,
                                  url: request.url,
                                  headers: headers,
                                  method: request.method,
                                  body: request.body)
    }
}
