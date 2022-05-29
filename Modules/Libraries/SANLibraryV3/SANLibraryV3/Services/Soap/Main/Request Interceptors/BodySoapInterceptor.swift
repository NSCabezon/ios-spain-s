//
//  BodySoapInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import Foundation
import SANServicesLibrary

struct BodySoapInterceptor: NetworkRequestInterceptor {
    
    enum Body {
        case soapenv
        case vBody
        
        func opening(withRequest request: NetworkRequest) -> String {
            switch self {
            case .soapenv:
                return "<soapenv:Body>"
            case .vBody:
                return "<v:Body>"
            }
        }
        
        func close(withRequest request: NetworkRequest) -> String {
            switch self {
            case .soapenv:
                return "</soapenv:Body>"
            case .vBody:
                return "</v:Body>"
            }
        }
    }
    
    enum Version {
        case n0
        case v1
        
        func opening(withRequest request: NetworkRequest, facade: String, nameSpace: String) -> String {
            switch self {
            case .n0:
                return "<n0:\(request.serviceName) xmlns:n0=\"\(nameSpace)\(facade)/v1\" facade=\"\(facade)\">"
            case .v1:
                return "<v1:\(request.serviceName) facade=\"\(facade)\">"
            }
        }
        
        func close(withRequest request: NetworkRequest) -> String {
            switch self {
            case .n0:
                return "</n0:\(request.serviceName)>"
            case .v1:
                return "</v1:\(request.serviceName)>"
            }
        }
    }
    
    let type: Body
    let version: Version
    let nameSpace: String
    let facade: String
    
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest {
        return InterceptedRequest(
            serviceName: request.serviceName,
            url: request.url,
            headers: request.headers,
            method: request.method,
            body: """
            \(type.opening(withRequest: request))
                \(version.opening(withRequest: request, facade: facade, nameSpace: nameSpace))
                \(request.body)
                \(version.close(withRequest: request))
            \(type.close(withRequest: request))
            """
        )
    }
}
